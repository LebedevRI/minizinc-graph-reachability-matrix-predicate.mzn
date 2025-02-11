include "reachable.mzn";

predicate fzn_dcluster(array[$$E] of $$N: from, array[$$E] of $$N: to,
                       array[$$N,$$N] of var bool: r,
                       array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    let {
        array [index_set(ns),index_set(es)] of var bool: des,
    } in
        forall (c in index_set(ns))(
            r[c,c] == true
        ) /\
        forall (j,i in index_set(ns) where i != j)(
            r[j,i] -> (ns[j] /\ ns[i])
        ) /\
        forall (j,i in index_set(ns) where i != j)(
            r[j,i] == (
                exists(e in index_set(es) where from[e] == j /\ to[e] == i)(
                    es[e]
                ) \/
                exists(k in index_set(ns) where k != j /\ k != i)(
                    ns[k] /\ r[j,k] /\ r[k,i]
                )
            )
        ) /\
        forall (e in index_set(es))(
            exists(des[..,e]) -> es[e]
        ) /\
        forall (j in index_set(ns))(
            dreachable(from, to, j, r[j,..], array1d(index_set(es),des[j,..]))
        ) /\
        % nodes connected by chosen edges must be chosen
        subgraph(from,to,ns,es);

%-----------------------------------------------------------------------------%
