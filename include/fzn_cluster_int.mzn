include "subgraph.mzn";

predicate fzn_cluster(int: N, int: E, array[int] of int: from, array[int] of int: to,
                      array[int] of var int: nr, array[int] of var bool: ns, array[int] of var bool: es) =
    abort("fzn_cluster not implemented (use enum version)");


%-----------------------------------------------------------------------------%
