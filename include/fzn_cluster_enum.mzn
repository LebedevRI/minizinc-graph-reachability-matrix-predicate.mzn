include "link_set_to_booleans.mzn";
include "reachable_multiroot.mzn";
include "subgraph.mzn";
include "arg_val.mzn";

predicate fzn_cluster(array[$$E] of $$N: from, array[$$E] of $$N: to,
                      array[$$N,$$N] of var bool: r,
                      array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    let {
        array[index_set(ns)] of var index_set(ns): NodeRoot;
        array[index_set(ns)] of var bool: NodeRootnessMask;
        array[index_set(ns)] of bool: ALL_GRAPH_NODES = [ true | n in index_set(ns) ];
    } in
        forall (n in index_set(ns))(
            ((not ns[n]) -> (NodeRoot[n] == n))
        ) /\
        forall (e in index_set(es))(
            es[e] -> (NodeRoot[from[e]] == NodeRoot[to[e]])
        ) /\
        link_set_to_booleans(array2set(NodeRoot), NodeRootnessMask) /\
        reachable_multiroot(
            from,
            to,
            NodeRootnessMask,
            ALL_GRAPH_NODES,
            es
        ) /\
        symmetry_breaking_constraint(forall (j,i in index_set(ns) where i > j)(
            r[i,j] == r[j,i]
        )) /\
        forall (c in index_set(ns))(
            r[c,c] == true
        ) /\
        forall (j,i in index_set(ns) where i > j)(
            r[j,i] == (NodeRoot[i] == NodeRoot[j])
        );
