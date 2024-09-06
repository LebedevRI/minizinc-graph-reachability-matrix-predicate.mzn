include "link_set_to_booleans.mzn";
include "reachable_multiroot.mzn";
include "subgraph.mzn";

predicate fzn_cluster(array[$$E] of $$N: from, array[$$E] of $$N: to,
                      array[$$N] of var $$N: nr, array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    let {
        array[index_set(ns)] of var bool: NodeRootnessMask;
        array[index_set(ns)] of bool: ALL_GRAPH_NODES = [ true | n in index_set(ns) ];
    } in
        forall (n in index_set(ns))(
            ((not ns[n]) -> (nr[n] == n))
        ) /\
        forall (e in index_set(es))(
            es[e] -> (nr[from[e]] == nr[to[e]])
        ) /\
        forall(j in index_set(ns))(
            link_set_to_booleans(array2set(nr), NodeRootnessMask)
        ) /\
        reachable_multiroot(
            from,
            to,
            NodeRootnessMask,
            ALL_GRAPH_NODES,
            es
        );
