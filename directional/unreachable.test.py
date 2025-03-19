#!/usr/bin/python3

import io
import itertools
import json
import math
import multiprocessing
import os
import random
import re
import selectors
import signal
import subprocess
import threading

import big_o
import networkx
import numpy
import pandas as pd
import tabulate
import tqdm

DEBUG = False

# SOLVER = "gecode"
SOLVER = "chuffed"

# `link_set_to_booleans` does not like empty ranges.
MIN_NODES = 2
MIN_EDGES = 1


class WaitableEvent:
    def __init__(self):
        self._read_fd, self._write_fd = os.pipe()

    def wait(self, timeout=None):
        rfds, wfds, efds = selectors.select.select(
            [self._read_fd], [], [], timeout
        )
        return self._read_fd in rfds

    def is_set(self):
        return self.wait(0)

    def clear(self):
        if self.is_set():
            os.read(self._read_fd, 1)

    def set(self):
        if not self.is_set():
            os.write(self._write_fd, b"1")

    def fileno(self):
        return self._read_fd

    def __del__(self):
        os.close(self._read_fd)
        os.close(self._write_fd)


class GracefulInterruptHandler(object):
    def __init__(self, sig=signal.SIGINT):
        self.sig = sig

    def __enter__(self):
        self.interrupted = False
        self.interrupted_event = WaitableEvent()
        self.released = False
        self.original_handler = signal.getsignal(self.sig)

        def handler(signum, frame):
            self.release()
            self.interrupted = True
            self.interrupted_event.set()

        signal.signal(self.sig, handler)
        return self

    def __exit__(self, type, value, tb):
        self.release()

    def interrupted(self):
        return self.interrupted

    def release(self):
        if self.released:
            return False
        signal.signal(self.sig, self.original_handler)
        self.released = True
        return True


def GraphToMatrix(data):
    m = numpy.zeros((data.NumNodes, data.NumNodes), dtype=bool)
    for edgeIndice, edgeValue in enumerate(data.GraphEdges):
        sourceNode = data.NodePairs[edgeIndice][0]
        targetNode = data.NodePairs[edgeIndice][1]
        m[sourceNode - 1, targetNode - 1] = edgeValue
    return m


def ComputeReachabilityMatrix(data):
    m = GraphToMatrix(data)
    for c in range(1, data.NumNodes + 1):
        m[c - 1, c - 1] = 1
    R = numpy.linalg.matrix_power(m, max(data.NumNodes - 1, 1))
    assert numpy.array_equal(R, numpy.linalg.matrix_power(R, 2))
    return R


def ComputeReachabilityMatrix_RefImpl(data):
    G = networkx.DiGraph(GraphToMatrix(data))
    R = numpy.zeros((data.NumNodes, data.NumNodes), dtype=bool)
    for j in range(data.NumNodes):
        for i in range(data.NumNodes):
            if networkx.has_path(G, i, j):
                R[i, j] = True
    return R


class TestData:
    def __init__(self, NumNodes, NumEdges, NodePairs, GraphEdges):
        self.NumNodes = NumNodes
        self.NumEdges = NumEdges
        self.NodePairs = NodePairs
        self.GraphEdges = GraphEdges
        assert self.NumNodes >= 0
        assert self.NumEdges >= 0
        assert self.NumEdges == len(self.GraphEdges)
        for sourceNode, targetNode in NodePairs:
            assert (
                sourceNode >= 1
                and sourceNode <= NumNodes
                and targetNode >= 1
                and targetNode <= NumNodes
            )
        assert len(set(self.NodePairs)) == len(self.NodePairs)

    def __repr__(self):
        return "TestData(NumNodes={}, NumEdges={}, NodePairs={}, GraphEdges={})".format(
            self.NumNodes,
            self.NumEdges,
            self.NodePairs,
            self.GraphEdges,
        )

    def __str__(self):
        return self.__repr__()


def worker_thread(res, subprocess_event):
    res.wait()
    subprocess_event.set()


def runner(test):
    if ihl.interrupted:
        return
    ReachabilityMatrixRef = ComputeReachabilityMatrix(test)
    if DEBUG:
        print("\n\n\n\n")
        print("==================")
        print(test)
    if True:
        assert numpy.array_equal(
            ReachabilityMatrixRef,
            ComputeReachabilityMatrix_RefImpl(test),
        )
    if DEBUG:
        print("ReachabilityMatrixRef:")
        print(ReachabilityMatrixRef)

    subprocess_event = WaitableEvent()

    sel = selectors.DefaultSelector()
    sel.register(
        ihl.interrupted_event, selectors.EVENT_READ, "interruption event"
    )
    sel.register(subprocess_event, selectors.EVENT_READ, "completetion event")

    jsonInput = {}
    jsonInput["NUM_GRAPH_NODES"] = test.NumNodes
    jsonInput["NUM_GRAPH_EDGES"] = test.NumEdges
    jsonInput["GRAPH_NODE_PAIRS_par"] = test.NodePairs
    jsonInput["GraphEdges_par"] = test.GraphEdges

    stdout = ""
    res = subprocess.Popen(
        [
            "minizinc",
            "--statistics",
            "--solver",
            SOLVER,
            "-O1",
            "--all-solutions",
            "--json-stream",
            "--only-sections",
            "bogus",
            "unreachable.script-entry-point.json.mzn",
            "--cmdline-json-data",
            json.dumps(jsonInput),
        ],
        start_new_session=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    threading.Thread(target=worker_thread, args=(res, subprocess_event)).start()

    events = sel.select()
    for key, mask in events:
        if key.fileobj == ihl.interrupted_event:
            assert ihl.interrupted_event.is_set()
            res.terminate()
            return
        if key.fileobj == subprocess_event:
            continue
        assert False

    if DEBUG:
        print(res)
    if res.returncode != 0:
        print(res.stdout.read())
        print(res.stderr.read())
        raise subprocess.CalledProcessError(returncode=res.returncode, cmd='')
    stdout = res.stdout
    if DEBUG:
        print(stdout)

    res = {}
    for s in stdout.read().splitlines():
        section = json.loads(s)
        if not section["type"] in res:
            res[section["type"]] = []
        res[section["type"]].append(section)
    for s in res:
        if s == "statistics":
            continue
        if s == "status":
            assert len(res[s]) == 1
            res[s] = res[s][0]
            continue
        if s == "solution":
            if DEBUG:
                print(s)
            for ss in res[s]:
                # print(ss)
                assert ss["type"] == "solution"
                ReachabilityMatrix = ss["output"]["ReachabilityMatrix"]
                # ReachabilityMatrix = NodeDisjointSubgraphIndexToReachabilityMatrix(test, ss["output"]["ClusterIndex"])
                ReachabilityMatrix = numpy.asarray(ReachabilityMatrix)
                if DEBUG:
                    print("ReachabilityMatrix:")
                    print(ReachabilityMatrix)
                assert numpy.array_equal(
                    ReachabilityMatrix, ReachabilityMatrixRef
                )
    assert res["status"]["status"] == "ALL_SOLUTIONS"
    assert res["statistics"][2]["statistics"]["nSolutions"] >= 1
    assert res["statistics"][2]["statistics"]["nSolutions"] == 1

    stats = dict()
    stats["NumNodes"] = test.NumNodes
    stats["NumEdges"] = test.NumEdges
    for k, v in res["statistics"][0]["statistics"].items():
        k = "(flat) " + k
        assert not (k in stats)
        stats[k] = v
    for k, v in res["statistics"][1]["statistics"].items():
        k = "(solve) " + k
        assert not (k in stats)
        stats[k] = v
    if DEBUG:
        print("==================")
    bar_queue.put_nowait(1)
    return stats


def sampling_runner(i, num_nodes, num_nodes_is_upper_limit):
    if ihl.interrupted:
        return
    if num_nodes_is_upper_limit:
        NumNodes = random.randint(MIN_NODES, num_nodes)
    else:
        NumNodes = num_nodes
    assert NumNodes >= 0
    MAX_EDGES = (NumNodes**2) - NumNodes
    ALL_NODE_PAIRS = itertools.permutations(range(1, NumNodes + 1), r=2)
    ALL_NODE_PAIRS = [(e[0], e[1]) for e in ALL_NODE_PAIRS]
    assert len(ALL_NODE_PAIRS) == MAX_EDGES
    assert MAX_EDGES > MIN_EDGES
    NumEdges = random.randint(MIN_EDGES, len(ALL_NODE_PAIRS))
    NodePairs = random.sample(ALL_NODE_PAIRS, k=NumEdges)
    GraphEdges = random.choices([False, True], k=NumEdges)
    test = TestData(
        NumNodes=NumNodes,
        NumEdges=NumEdges,
        NodePairs=NodePairs,
        GraphEdges=GraphEdges,
    )
    # # test = TestData(
    # #     NumNodes=1,
    # #     NumEdges=0,
    # #     NodePairs=(),
    # #     GraphEdges=())
    return runner(test)


class SamplingRunner(object):
    def __init__(self, num_nodes, num_nodes_is_upper_limit):
        self.num_nodes = num_nodes
        self.num_nodes_is_upper_limit = num_nodes_is_upper_limit

    def __call__(self, i):
        return sampling_runner(i, self.num_nodes, self.num_nodes_is_upper_limit)


def generate_exhaustive_tests_for_graph(NumNodes, NumEdges):
    tests = []
    MAX_EDGES = (NumNodes**2) - NumNodes
    ALL_NODE_PAIRS = itertools.permutations(range(1, NumNodes + 1), r=2)
    ALL_NODE_PAIRS = [(e[0], e[1]) for e in ALL_NODE_PAIRS]
    assert len(ALL_NODE_PAIRS) == MAX_EDGES
    for NodePairs in itertools.combinations(ALL_NODE_PAIRS, NumEdges):
        for GraphEdges in itertools.product([False, True], repeat=NumEdges):
            tests.append(
                TestData(
                    NumNodes=NumNodes,
                    NumEdges=NumEdges,
                    NodePairs=NodePairs,
                    GraphEdges=GraphEdges,
                )
            )
    return tests


def generate_exhaustive_tests(MAX_NODES):
    tests = {}
    for NumNodes in range(MIN_NODES, MAX_NODES + 1):
        if not NumNodes in tests:
            tests[NumNodes] = []
        MAX_EDGES = (NumNodes**2) - NumNodes
        for NumEdges in range(MIN_EDGES, MAX_EDGES + 1):
            tests[NumNodes].extend(
                generate_exhaustive_tests_for_graph(NumNodes, NumEdges)
            )
    return tests


class RepeatTimer(threading.Timer):
    def run(self):
        while not self.finished.wait(self.interval):
            self.function(*self.args, **self.kwargs)


def refresh_bar(pbar):
    pbar.refresh()


def update_bar(total):
    pbar = tqdm.tqdm(
        total=total,
        mininterval=math.inf,
        maxinterval=math.inf,
        miniters=math.inf,
    )
    pbar.monitor_interval = 0
    bar_timer = RepeatTimer(1, refresh_bar, args=(pbar,))
    bar_timer.start()
    for step in iter(bar_queue.get, None):
        pbar.update(step)
    bar_timer.cancel()
    pbar.close()


def entry_with_large_num_nodes(MAX_NODES):
    NUM_TESTS = 32 * 400
    chunksize = math.ceil(NUM_TESTS / multiprocessing.cpu_count())
    NUM_TESTS = multiprocessing.cpu_count() * chunksize
    print("Running tests (random, N=0..{})...".format(MAX_NODES))

    global bar_queue
    bar_queue = multiprocessing.Queue()
    bar_process = multiprocessing.Process(target=update_bar, args=(NUM_TESTS,))
    bar_process.start()

    if DEBUG:
        r = list(
            map(
                SamplingRunner(MAX_NODES, num_nodes_is_upper_limit=True),
                range(NUM_TESTS),
            )
        )
    else:
        with multiprocessing.Pool() as pool:
            r = list(
                pool.imap_unordered(
                    SamplingRunner(MAX_NODES, num_nodes_is_upper_limit=True),
                    range(NUM_TESTS),
                    chunksize=chunksize,
                )
            )
        pool.close()
        pool.join()

    bar_queue.put(None)
    bar_process.join()

    return r


def entry_with_small_num_nodes(MAX_NODES):
    print("Generating tests (exhaustive, N=0..{})...".format(MAX_NODES))
    tests = generate_exhaustive_tests(MAX_NODES)
    tests = numpy.hstack(list(tests.values()))

    if not DEBUG:
        random.shuffle(tests)

    print("Running tests (exhaustive)...")

    global bar_queue
    bar_queue = multiprocessing.Queue()
    bar_process = multiprocessing.Process(target=update_bar, args=(len(tests),))
    bar_process.start()

    chunksize = math.ceil(len(tests) / multiprocessing.cpu_count())
    if DEBUG:
        r = list(map(runner, tests))
    else:
        with multiprocessing.Pool() as pool:
            r = list(pool.imap_unordered(runner, tests, chunksize=chunksize))
        pool.close()
        pool.join()

    bar_queue.put(None)
    bar_process.join()

    return r


def entry_with_num_nodes(MAX_NODES):
    if MAX_NODES <= 4:
        return entry_with_small_num_nodes(MAX_NODES)
    return entry_with_large_num_nodes(MAX_NODES)


def print_to_string(*args, **kwargs):
    with io.StringIO() as output:
        print(*args, file=output, **kwargs)
        return output.getvalue()


def main():
    r = numpy.array([])
    r = numpy.hstack((r, numpy.array(entry_with_small_num_nodes(3))))
    # r = numpy.hstack((r, numpy.array(entry_with_small_num_nodes(4))))
    r = numpy.hstack((r, numpy.array(entry_with_num_nodes(10))))
    # r = numpy.hstack((r, numpy.array(entry_with_num_nodes(10))))

    if ihl.interrupted:
        return

    headers = [
        "Name",
        "NumNodes (big-O)",
        "... (formula)",
        "NumEdges (big-O)",
        "... (formula)",
    ]

    df = pd.DataFrame.from_records(r).fillna(0)

    res = []
    for key in df.columns:
        if key in [
            "NumNodes",
            "NumEdges",
            "(flat) method",
            "(solve) randomSeed",
        ]:
            continue
        NumNodes = df["NumNodes"].to_numpy()
        NumEdges = df["NumEdges"].to_numpy()
        data = df[key].to_numpy()

        best0, fitted = big_o.infer_big_o_class(NumNodes, data)
        best1, fitted = big_o.infer_big_o_class(NumEdges, data)

        best0_name = "{}".format(best0.__class__.__name__)
        best0 = re.sub(
            r"\bn\b",
            "NumNodes",
            best0.format_str()
            .format(*best0.coefficients())
            .replace("time = ", ""),
        )

        best1_name = "{}".format(best1.__class__.__name__)
        best1 = re.sub(
            r"\bn\b",
            "NumEdges",
            best1.format_str()
            .format(*best1.coefficients())
            .replace("time = ", ""),
        )

        res.append([key, best0_name, best0, best1_name, best1])

    print(tabulate.tabulate(res, headers, tablefmt="github"))


if __name__ == "__main__":
    random.seed()
    global ihl
    with GracefulInterruptHandler() as ihl:
        main()
