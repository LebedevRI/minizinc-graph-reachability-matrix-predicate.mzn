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

% Either graph node, or an ephemeral node. % We need that extra ephemeral node
% as a parent node for any and all non-chosen edeges.
enum DISJOINT_SUBGRAPH_NODES = DGn(GRAPH_NODES) ++ {EPH_NODE};

%-------------------------------------------------------------------------------

array[GRAPH_NODES] of var GRAPH_NODES: NodeRoot;
array[GRAPH_EDGES] of var DISJOINT_SUBGRAPH_NODES: EdgeRoot;

constraint
  forall (n in GRAPH_NODES)(
    ((not GraphNodes[n]) -> (NodeRoot[n] == n))
  ) /\
  forall (e in GRAPH_EDGES)(
    GraphEdges[e] == (EdgeRoot[e] != EPH_NODE)
  ) /\
  forall (e in GRAPH_EDGES)(
    GraphEdges[e] -> (
        EdgeRoot[e] == DGn(NodeRoot[GRAPH_LEAVING_NODE[e]])
    /\  EdgeRoot[e] == DGn(NodeRoot[GRAPH_ENTERING_NODE[e]])
    )
  );

%|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

% Is this node a root node for some disjoint subgraph?
array[GRAPH_NODES] of var bool: NodeRootnessMask;

constraint forall(j in GRAPH_NODES)(
  link_set_to_booleans(array2set(NodeRoot), NodeRootnessMask)
);

% All nodes must participate.
array[GRAPH_NODES] of bool: ALL_GRAPH_NODES = [ true | n in GRAPH_NODES ];

constraint
  reachable_multiroot(
    GRAPH_LEAVING_NODE,
    GRAPH_ENTERING_NODE,
    NodeRootnessMask,
    ALL_GRAPH_NODES,
    GraphEdges
  );


%-------------------------------------------------------------------------------
% /\ The Algorithm
%===============================================================================
% \/ User code
%-------------------------------------------------------------------------------

solve :: int_search(NodeRoot, input_order, indomain_min) satisfy;
