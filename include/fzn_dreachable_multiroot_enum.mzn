include "subgraph.mzn";

predicate fzn_dreachable_multiroot(array[$$E] of $$N: from, array[$$E] of $$N: to,
                                   array[$$N] of var bool: rs, array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    let {
        array[index_set(ns)] of var 0..card(index_set(ns))-1: dist; /* distance from root */
        array[index_set(ns)] of var index_set(ns): parent; /* parent */
    } in
        forall(n in index_set(ns)) % root nodes must be chosen
              (rs[n] -> ns[n]) /\
        forall(n in index_set(ns)) % root nodes are self-parents
              (rs[n] -> (parent[n] = n)) /\
        forall(n in index_set(ns)) % root nodes are at distance 0 from themselves
              (rs[n] -> (dist[n] = 0)) /\
        forall(n in index_set(ns)) % non-chosen nodes are self-parents
              ((not ns[n]) -> (parent[n] = n)) /\
        forall(n in index_set(ns)) % non-chosen nodes are at distance 0 from themselves
              ((not ns[n]) -> (dist[n] = 0)) /\
        forall(n in index_set(ns)) % chosen nodes are either roots or non-self-parent
              (ns[n] -> (rs[n] \/ parent[n] != n)) /\ % FIXME: redundant?
        forall(n in index_set(ns)) % self-parent nodes are either non-chosen or roots
              (parent[n] = n -> ((not ns[n]) \/ rs[n])) /\ % FIXME: redundant?
        forall(n in index_set(ns)) % each non-self-parent node is not a root
              (parent[n] != n -> (not rs[n])) /\ % FIXME: redundant?
        forall(n in index_set(ns)) % each non-self-parent node must be chosen along with its parent
              (parent[n] != n -> (ns[n] /\ ns[parent[n]])) /\
        forall(n in index_set(ns)) % each non-self-parent node is one more step removed from a root than its parent node
              (parent[n] != n -> dist[n] = dist[parent[n]] + 1) /\
        forall(n in index_set(ns)) % each non-self-parent node must have a chosen edge from its parent
              (parent[n] != n -> exists(e in index_set(from) where to[e] = n)(es[e] /\ from[e] = parent[n])) /\
        subgraph(from,to,ns,es);

%-----------------------------------------------------------------------------%
