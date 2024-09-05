include "subgraph.mzn";
include "link_set_to_booleans.mzn";

include "../include/reachable_multiroot.mzn";

%-------------------------------------------------------------------------------

int: NUM_GRAPH_NODES; % par
int: NUM_GRAPH_EDGES; % par

enum GRAPH_NODES = GN(1..NUM_GRAPH_NODES);
enum GRAPH_EDGES = GE(1..NUM_GRAPH_EDGES);

array[GRAPH_EDGES] of tuple(GRAPH_NODES,GRAPH_NODES): GRAPH_NODE_PAIRS; % par
array[GRAPH_EDGES] of GRAPH_NODES: GRAPH_LEAVING_NODE  = [ p.1 | p in GRAPH_NODE_PAIRS ]; % par
array[GRAPH_EDGES] of GRAPH_NODES: GRAPH_ENTERING_NODE = [ p.2 | p in GRAPH_NODE_PAIRS ]; % par

array[GRAPH_NODES] of var bool: GraphNodes; % par
array[GRAPH_EDGES] of var bool: GraphEdges; % par

constraint subgraph(
  GRAPH_LEAVING_NODE,
  GRAPH_ENTERING_NODE,
  GraphNodes,
  GraphEdges
);

%-------------------------------------------------------------------------------
% /\ User code
%===============================================================================
% \/ The Algorithm
%-------------------------------------------------------------------------------

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
    let {
      int: EPH_NODE = 1 + max(index_set(ns));
      set of int: DISJOINT_SUBGRAPH_NODES = index_set(ns) union {EPH_NODE};
      array[GRAPH_EDGES] of var DISJOINT_SUBGRAPH_NODES: EdgeRoot;
      array[GRAPH_NODES] of var bool: NodeRootnessMask;
      array[GRAPH_NODES] of bool: ALL_GRAPH_NODES = [ true | n in GRAPH_NODES ];
    } in
      forall (n in GRAPH_NODES)(
        ((not ns[n]) -> (nr[n] == n))
      ) /\
      forall (e in GRAPH_EDGES)(
        es[e] == (EdgeRoot[e] != EPH_NODE)
      ) /\
      forall (e in GRAPH_EDGES)(
        es[e] -> (
          EdgeRoot[e] == nr[GRAPH_LEAVING_NODE[e]] /\
          EdgeRoot[e] == nr[GRAPH_ENTERING_NODE[e]]
        )
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

%-------------------------------------------------------------------------------
% /\ The Algorithm
%===============================================================================
% \/ User code
%-------------------------------------------------------------------------------

array[GRAPH_NODES] of var GRAPH_NODES: NodeRoot;

constraint cluster(GRAPH_LEAVING_NODE, GRAPH_ENTERING_NODE, NodeRoot, GraphNodes, GraphEdges);

solve :: int_search(NodeRoot, input_order, indomain_min) satisfy;
