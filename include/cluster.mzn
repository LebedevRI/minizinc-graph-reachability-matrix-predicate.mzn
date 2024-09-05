include "fzn_cluster_int.mzn";
include "fzn_cluster_int_reif.mzn";
include "fzn_cluster_enum.mzn";
include "fzn_cluster_enum_reif.mzn";

/** @group globals.graph
    Clusterize the subgraph \a ns and \a es of a given undirected graph into disjoint subgraphs,
    and for each graph node, record the root node of distjoint subgraph containing said node in \a nr.

    @param N: the number of nodes in the given graph
    @param E: the number of edges in the given graph
    @param from: the leaving node 1..\a N for each edge
    @param to: the entering node 1..\a N for each edge
    @param nr: a node, that is a root node for the current node's disjoint subgraph
    @param ns: a Boolean for each node whether it is in the subgraph
    @param es: a Boolean for each edge whether it is in the subgraph
*/
predicate cluster(int: N, int: E, array[int] of int: from, array[int] of int: to,
                  array[int] of var int: nr, array[int] of var bool: ns, array[int] of var bool: es) =
    assert(index_set(from) = 1..E,"cluster: index set of from must be 1..\(E)") /\
    assert(index_set(to) = 1..E,"cluster: index set of to must be 1..\(E)") /\
    assert(index_set(nr) = 1..N,"cluster: index set of nr must be 1..\(N)") /\
    assert(index_set(ns) = 1..N,"cluster: index set of ns must be 1..\(N)") /\
    assert(index_set(es) = 1..E,"cluster: index set of es must be 1..\(E)") /\
    fzn_cluster(N,E,from,to,nr,ns,es);

/** @group globals.graph
    Clusterize the subgraph \a ns and \a es of a given undirected graph into disjoint subgraphs,
    and for each graph node, record the root node of distjoint subgraph containing said node in \a nr.

    @param from: the leaving node for each edge
    @param to: the entering node for each edge
    @param nr: a node, that is a root node for the current node's disjoint subgraph
    @param ns: a Boolean for each node whether it is in the subgraph
    @param es: a Boolean for each edge whether it is in the subgraph
*/
predicate cluster(array[$$E] of $$N: from, array[$$E] of $$N: to,
                  array[$$N] of var $$N: nr, array[$$N] of var bool: ns, array[$$E] of var bool: es) =
    assert(index_set(from) = index_set(to),"cluster: index set of from and to must be identical") /\
    assert(index_set(from) = index_set(es),"cluster: index set of from and es must be identical") /\
    assert(dom_array(from) subset index_set(nr),"cluster: nodes in from must be in index set of nr") /\
    assert(dom_array(to) subset index_set(nr),"cluster: nodes in to must be in index set of nr") /\
    assert(dom_array(from) subset index_set(ns),"cluster: nodes in from must be in index set of ns") /\
    assert(dom_array(to) subset index_set(ns),"cluster: nodes in to must be in index set of ns") /\
    fzn_cluster(from,to,nr,ns,es);
