include "subgraph.mzn";

predicate fzn_reachable_multiroot(int: N, int: E, array[int] of int: from, array[int] of int: to,
                                  array[int] of var bool: rs, array[int] of var bool: ns, array[int] of var bool: es) =
    abort("fzn_dreachable_multiroot not implemented (use enum version)");


%-----------------------------------------------------------------------------%
