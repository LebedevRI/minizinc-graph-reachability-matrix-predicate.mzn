#!/usr/bin/python3

import numpy
import itertools
import networkx
import json
import tempfile
import subprocess
import tqdm
import multiprocessing
import random
import scipy

DEBUG = False

# SOLVER = "gecode"
SOLVER = "chuffed"

# `link_set_to_booleans` does not like empty ranges.
MIN_NODES = 0
MIN_EDGES = 0

def GraphToSymmetricMatrix(data):
    m = numpy.zeros((data.NumNodes, data.NumNodes), dtype=bool)
    for (edgeIndice, edgeValue) in enumerate(data.GraphEdges):
        for (sourceNode, targetNode) in itertools.permutations(
                data.NodePairs[edgeIndice], r=2):
            m[sourceNode - 1, targetNode - 1] = edgeValue
    return m


def ComputeReachabilityMatrix(data):
    m = GraphToSymmetricMatrix(data)
    for c in range(1, data.NumNodes + 1):
        m[c - 1, c - 1] = 1
    R = numpy.linalg.matrix_power(m, max(data.NumNodes - 1, 1))
    assert numpy.array_equal(R, numpy.linalg.matrix_power(R, 2))
    return R


def ComputeReachabilityMatrix_RefImpl(data):
    G = networkx.Graph(GraphToSymmetricMatrix(data))
    R = numpy.zeros((data.NumNodes, data.NumNodes), dtype=bool)
    for j in range(data.NumNodes):
        for i in range(data.NumNodes):
            if networkx.has_path(G, i, j):
                R[i, j] = True
    return R


def NodeDisjointSubgraphIndexToReachabilityMatrix(
        data, NodeRoot):
    m = numpy.zeros((data.NumNodes, data.NumNodes), dtype=bool)
    for j in range(data.NumNodes):
        for i in range(data.NumNodes):
            if (NodeRoot[i] == NodeRoot[j]):
                m[j, i] = 1
    return m


class TestData:
    def __init__(self, NumNodes, NumEdges, NodePairs, GraphEdges):
        self.NumNodes = NumNodes
        self.NumEdges = NumEdges
        self.NodePairs = NodePairs
        self.GraphEdges = GraphEdges
        assert self.NumNodes >= 0
        assert self.NumEdges >= 0
        assert self.NumEdges == len(self.GraphEdges)
        for (sourceNode, targetNode) in NodePairs:
            assert sourceNode >= 1 and sourceNode <= NumNodes and \
                targetNode >= 1 and targetNode <= NumNodes
        assert len(set(self.NodePairs)) == len(self.NodePairs)
    def __repr__(self):
        return "TestData(NumNodes={}, NumEdges={}, NodePairs={}, GraphEdges={})".format(
            self.NumNodes, self.NumEdges, self.NodePairs, self.GraphEdges)
    def __str__(self):
        return self.__repr__()

class Status:
    def __init__(self, NumNodes, NumEdges, NumVars,
                 NumConstraints, FlatTime, SolveTime):
        self.NumNodes = NumNodes
        self.NumEdges = NumEdges
        self.NumVars = NumVars
        self.NumConstraints = NumConstraints
        self.FlatTime = FlatTime
        self.SolveTime = SolveTime


def runner(test):
    ReachabilityMatrixRef = ComputeReachabilityMatrix(test)
    if DEBUG:
        print("\n\n\n\n")
        print("==================")
        print(test)
    if True:
        assert numpy.array_equal(
            ReachabilityMatrixRef,
            ComputeReachabilityMatrix_RefImpl(test))
    if DEBUG:
        print(ReachabilityMatrixRef)

    jsonInput = {}
    jsonInput["NUM_GRAPH_NODES"] = test.NumNodes
    jsonInput["NUM_GRAPH_EDGES"] = test.NumEdges
    jsonInput["GRAPH_NODE_PAIRS_par"] = test.NodePairs
    jsonInput["GraphEdges_par"] = test.GraphEdges

    stdout = ""
    res = subprocess.run(["minizinc",
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
                          json.dumps(jsonInput)],
                          capture_output=True)
    if DEBUG:
        print(res)
    if res.returncode != 0:
        print(res.stderr)
    res.check_returncode()
    stdout = res.stdout
    if DEBUG:
        print(stdout)

    res = {}
    for s in stdout.splitlines():
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
                # ReachabilityMatrix = res["solution"]["output"]["ReachabilityMatrix"]
                ReachabilityMatrix = NodeDisjointSubgraphIndexToReachabilityMatrix(
                    test, ss["output"]["NodeRoot"])
                ReachabilityMatrix = numpy.asarray(ReachabilityMatrix)
                if DEBUG:
                    print(ReachabilityMatrix)
                assert numpy.array_equal(
                    ReachabilityMatrix, ReachabilityMatrixRef)
    assert res["status"]["status"] == "ALL_SOLUTIONS"
    assert res["statistics"][2]["statistics"]["nSolutions"] >= 1
    # assert res["statistics"][2]["statistics"]["nSolutions"] == 1
    flatTime = res["statistics"][0]["statistics"]["flatTime"]
    solveTime = res["statistics"][1]["statistics"]["solveTime"]
    Vars = sum([res["statistics"][0]["statistics"][s]
               for s in res["statistics"][0]["statistics"] if s.endswith("Vars")])
    Constraints = sum([res["statistics"][0]["statistics"][s]
                      for s in res["statistics"][0]["statistics"] if (s.endswith("Constraints") and not s.endswith("ReifiedConstraints"))])
    if DEBUG:
        print("==================")
    return Status(test.NumNodes, test.NumEdges, Vars,
                  Constraints, flatTime, solveTime)


def sampling_runner(i, num_nodes, num_nodes_is_upper_limit):
    if num_nodes_is_upper_limit:
        NumNodes = random.randint(MIN_NODES, num_nodes)
    else:
        NumNodes = num_nodes
    assert NumNodes >= 0
    ALL_NODE_PAIRS = itertools.combinations(range(1, NumNodes + 1), r=2)
    ALL_NODE_PAIRS = [(e[0], e[1]) for e in ALL_NODE_PAIRS]
    NumEdges = random.randint(MIN_EDGES, len(ALL_NODE_PAIRS))
    assert NumEdges >= 0
    NodePairs = random.sample(ALL_NODE_PAIRS, k=NumEdges)
    GraphEdges = random.choices([False, True], k=NumEdges)
    test = TestData(
        NumNodes=NumNodes,
        NumEdges=NumEdges,
        NodePairs=NodePairs,
        GraphEdges=GraphEdges)
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
        return sampling_runner(
            i, self.num_nodes, self.num_nodes_is_upper_limit)


def generate_exhaustive_tests_for_graph(NumNodes, NumEdges):
    tests = []
    MAX_EDGES = ((NumNodes**2) - NumNodes) // 2
    ALL_NODE_PAIRS = itertools.combinations(range(1, NumNodes + 1), r=2)
    ALL_NODE_PAIRS = [(e[0], e[1]) for e in ALL_NODE_PAIRS]
    assert len(ALL_NODE_PAIRS) == MAX_EDGES
    for NodePairs in itertools.combinations(ALL_NODE_PAIRS, NumEdges):
        for GraphEdges in itertools.product(
                [False, True], repeat=NumEdges):
            tests.append(TestData(
                NumNodes=NumNodes,
                NumEdges=NumEdges,
                NodePairs=NodePairs,
                GraphEdges=GraphEdges))
    return tests


def generate_exhaustive_tests(MAX_NODES):
    tests = {}
    for NumNodes in range(MIN_NODES, MAX_NODES + 1):
        if not NumNodes in tests:
            tests[NumNodes] = []
        MAX_EDGES = ((NumNodes**2) - NumNodes) // 2
        for NumEdges in range(MIN_EDGES, MAX_EDGES + 1):
            tests[NumNodes].extend(
                generate_exhaustive_tests_for_graph(NumNodes, NumEdges))
    return tests


def entry_with_large_num_nodes(MAX_NODES):
    NUM_TESTS = 32 * 400
    print("Running tests (random, N=0..{})...".format(MAX_NODES))
    if DEBUG:
        r = list(
                tqdm.tqdm(
                    map(
                        SamplingRunner(MAX_NODES, num_nodes_is_upper_limit=True),
                        range(NUM_TESTS)),
                    total=NUM_TESTS)
            )
    else:
        with multiprocessing.Pool() as pool:
            r = list(
                tqdm.tqdm(
                    pool.imap_unordered(
                        SamplingRunner(MAX_NODES, num_nodes_is_upper_limit=True),
                        range(NUM_TESTS)),
                    total=NUM_TESTS)
            )
        pool.close()
        pool.join()
    return r


def entry_with_small_num_nodes(MAX_NODES):
    print("Generating tests (exhaustive, N=0..{})...".format(MAX_NODES))
    tests = generate_exhaustive_tests(MAX_NODES)
    tests = numpy.hstack(list(tests.values()))

    if not DEBUG:
        random.shuffle(tests)

    print("Running tests (exhaustive)...")
    if DEBUG:
        r = list(tqdm.tqdm(map(
                runner,
                tests), total=len(tests)))
    else:
        with multiprocessing.Pool() as pool:
            r = list(tqdm.tqdm(pool.imap_unordered(
                runner,
                tests), total=len(tests)))
        pool.close()
        pool.join()
    return r


def entry_with_num_nodes(MAX_NODES):
    if MAX_NODES <= 5:
        return entry_with_small_num_nodes(MAX_NODES)
    return entry_with_large_num_nodes(MAX_NODES)


def fun_poly(k, NumNodes, NumEdges, y):
    return -y + k[0] + k[1] * NumNodes**1 + k[2] * NumNodes**2 + k[3] * \
        NumNodes**3 + k[4] * NumEdges**1 + \
        k[5] * NumEdges**2 + k[6] * NumEdges**3


def print_poly(x, active_mask):
    if (active_mask[0]):
        print(" + {:.2e} ".format(x[0]))
    if (active_mask[1]):
        print(" + {:.2e}*NumNodes^1".format(x[1]))
    if (active_mask[2]):
        print(" + {:.2e}*NumNodes^2".format(x[2]))
    if (active_mask[3]):
        print(" + {:.2e}*NumNodes^3".format(x[3]))
    if (active_mask[4]):
        print(" + {:.2e}*NumEdges^1".format(x[4]))
    if (active_mask[5]):
        print(" + {:.2e}*NumEdges^2".format(x[5]))
    if (active_mask[6]):
        print(" + {:.2e}*NumEdges^3".format(x[6]))


def main():
    r = numpy.array([])
    # r = numpy.hstack((r, numpy.array(entry_with_small_num_nodes(4))))
    # r = numpy.hstack((r, numpy.array(entry_with_large_num_nodes(5))))
    r = numpy.hstack((r, numpy.array(entry_with_num_nodes(10))))
    # r = numpy.hstack((r, numpy.array(entry_with_num_nodes(10))))
    # return

    NumNodes = numpy.array([e.NumNodes for e in r])
    NumEdges = numpy.array([e.NumEdges for e in r])
    Vars = numpy.array([e.NumVars for e in r])
    Constraints = numpy.array([e.NumConstraints for e in r])
    FlatTime = numpy.array([e.FlatTime for e in r])
    SolveTime = numpy.array([e.SolveTime for e in r])

    k = numpy.ones(1 + 2 * 3)

    sol = scipy.optimize.least_squares(fun_poly, k, args=(
        NumNodes, NumEdges, FlatTime), bounds=(numpy.zeros(len(k)), numpy.inf))
    print("\nCompile time big-O: ")
    print_poly(sol.x, sol.active_mask)
    print("\n", sol)

    if False:
        sol = scipy.optimize.least_squares(fun_poly, k, args=(
            NumNodes, NumEdges, Vars), bounds=(numpy.zeros(len(k)), numpy.inf))
        print("\nCompile time Vars: ")
        print_poly(sol.x, sol.active_mask)
        print("\n", sol)

        sol = scipy.optimize.least_squares(fun_poly, k, args=(
            NumNodes, NumEdges, Constraints), bounds=(numpy.zeros(len(k)), numpy.inf))
        print("\nCompile time Constraints: ")
        print_poly(sol.x, sol.active_mask)
        print("\n", sol)

    sol = scipy.optimize.least_squares(fun_poly, k, args=(
        NumNodes, NumEdges, SolveTime), bounds=(numpy.zeros(len(k)), numpy.inf))
    print("\nSolve time big-O: ")
    print_poly(sol.x, sol.active_mask)
    print("\n", sol)


if __name__ == '__main__':
    random.seed()
    main()
