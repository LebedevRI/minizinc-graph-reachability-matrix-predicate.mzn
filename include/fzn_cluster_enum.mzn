include "link_set_to_booleans.mzn";
include "reachable_multiroot.mzn";
include "subgraph.mzn";

predicate fzn_cluster(array[$$E] of $$N: from, array[$$E] of $$N: to,
                      array[$$N] of var $$N: nr, array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    let {
        array[GRAPH_NODES] of var bool: NodeRootnessMask;
        array[GRAPH_NODES] of bool: ALL_GRAPH_NODES = [ true | n in GRAPH_NODES ];
    } in
        forall (n in GRAPH_NODES)(
            ((not ns[n]) -> (nr[n] == n))
        ) /\
        forall (e in GRAPH_EDGES)(
            es[e] -> (nr[GRAPH_LEAVING_NODE[e]] == nr[GRAPH_ENTERING_NODE[e]])
        ) /\
        forall(j in GRAPH_NODES)(
            link_set_to_booleans(array2set(nr), NodeRootnessMask)
        ) /\
        reachable_multiroot(
            from,
            to,
            NodeRootnessMask,
            ALL_GRAPH_NODES,
            es
        );
