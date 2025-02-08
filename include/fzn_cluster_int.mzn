include "subgraph.mzn";

predicate fzn_cluster(int: N, int: E, array[int] of int: from, array[int] of int: to,
                      array[int,int] of var bool: r, array[int] of var bool: ns, array[int] of var bool: es) =
    abort("fzn_cluster not implemented (use enum version)");


%-----------------------------------------------------------------------------%
