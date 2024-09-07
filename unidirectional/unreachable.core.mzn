include "subgraph.mzn";

include "../include/cluster.mzn";

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

array[GRAPH_NODES] of var 1..NUM_GRAPH_NODES: ClusterIndex;

constraint cluster(GRAPH_LEAVING_NODE, GRAPH_ENTERING_NODE, ClusterIndex, GraphNodes, GraphEdges);

solve :: int_search(ClusterIndex, input_order, indomain_min) satisfy;
