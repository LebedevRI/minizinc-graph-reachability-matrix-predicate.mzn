include "link_set_to_booleans.mzn";
include "reachable_multiroot.mzn";
include "subgraph.mzn";
include "arg_val.mzn";

predicate fzn_cluster(array[$$E] of $$N: from, array[$$E] of $$N: to,
                      array[$$N] of var $$C: ci,
                      array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    let {
        array[index_set(ns)] of var index_set(ns): NodeRoot;
        array[index_set(ns)] of var bool: NodeRootnessMask;
        array[index_set(ns)] of bool: ALL_GRAPH_NODES = [ true | n in index_set(ns) ];
        array[index_set(ns)] of var opt dom_array(ci): ClusterIndexOfRoot;
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
        symmetry_breaking_constraint(forall(r in index_set(ns))(
            let {
                var opt index_set(ns): EarliestNodeOfRoot = arg_val_weak(NodeRoot, r)
            } in
                ClusterIndexOfRoot[r] == if absent(EarliestNodeOfRoot) then <> else EarliestNodeOfRoot - min(index_set(ns)) + min(dom_array(ci)) endif
        ) /\
        forall(n in index_set(ns))(
            ci[n] == ClusterIndexOfRoot[NodeRoot[n]]
        ));
