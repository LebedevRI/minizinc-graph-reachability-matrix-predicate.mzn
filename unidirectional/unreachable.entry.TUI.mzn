%-------------------------------------------------------------------------------

include "unreachable.core.mzn";

%-------------------------------------------------------------------------------

NUM_GRAPH_NODES = 7; % par
NUM_GRAPH_EDGES = length(j,i in GRAPH_NODES where i > j)(1); % par
GRAPH_NODE_PAIRS = [ (j,i) | j,i in GRAPH_NODES where i > j ]; % par

%-------------------------------------------------------------------------------

array[GRAPH_NODES,GRAPH_NODES] of var bool: HardWires;

constraint symmetry_breaking_constraint(forall (j,i in GRAPH_NODES where i > j)(
  HardWires[i,j] == HardWires[j,i]
));

constraint forall (c in GRAPH_NODES)(
  HardWires[c,c] == false
);

constraint forall (j,i in GRAPH_NODES where i > j)(
  let {
    GRAPH_NODES: m = min(i,j);
    GRAPH_NODES: M = max(i,j);
  } in
  HardWires[m,M] == ((m,M) == (1,2) \/ (m,M) == (2,3) \/ (m,M) == (2,7) \/ (m,M) == (4,5))
);

%-------------------------------------------------------------------------------

% array[GRAPH_NODES] of var bool: GraphNodes;
% array[GRAPH_EDGES] of var bool: GraphEdges;

constraint subgraph(
  GRAPH_LEAVING_NODE,
  GRAPH_ENTERING_NODE,
  GraphNodes,
  GraphEdges
);

constraint forall (n in GRAPH_NODES)(
  GraphNodes[n] == exists(HardWires[n,..])
);

constraint forall (e in GRAPH_EDGES)(
  GraphEdges[e] == HardWires[GRAPH_LEAVING_NODE[e],GRAPH_ENTERING_NODE[e]]
);

%-------------------------------------------------------------------------------


array[GRAPH_NODES,GRAPH_NODES] of var bool: ReachabilityMatrix;

constraint symmetry_breaking_constraint(forall (j,i in GRAPH_NODES where i > j)(
  ReachabilityMatrix[i,j] == ReachabilityMatrix[j,i]
));

constraint forall (c in GRAPH_NODES)(
  ReachabilityMatrix[c,c] == true
);

constraint forall (j,i in GRAPH_NODES where i > j)(
  ReachabilityMatrix[j,i] == (NodeDisjointSubgraphIndex[i] == NodeDisjointSubgraphIndex[j])
);

output["\n"++"================================================================================\n"];
output["================================================================================\n"];
output["\n"++"HardWires:\n"++show_array2d_bool(HardWires)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"GraphNodes:\n"++show_array2d_bool(array2d(GRAPH_NODES, 1..1, GraphNodes))];
output["\n"++"GraphEdges:\n"++show_array2d_bool(array2d(GRAPH_EDGES, 1..1, GraphEdges))];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"NodeDisjointSubgraphIndex:\n"++show(NodeDisjointSubgraphIndex)++"\n"];
output["\n"++"DisjointSubgraphNodeSet:\n"++show(DisjointSubgraphNodeSet)++"\n"];
output["\n"++"NodeDisjointSubgraphMatrix:\n"++show_array2d_bool(NodeDisjointSubgraphMatrix)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"EdgeDisjointSubgraphIndex:\n"++show(EdgeDisjointSubgraphIndex)++"\n"];
output["\n"++"DisjointSubgraphEdgeSet:\n"++show(DisjointSubgraphEdgeSet)++"\n"];
output["\n"++"EdgeDisjointSubgraphMatrix:\n"++show_array2d_bool(EdgeDisjointSubgraphMatrix)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"ReachabilityMatrix:\n"++show_array2d_bool(ReachabilityMatrix)];
output["\n"++"================================================================================\n"];
output["================================================================================\n"];
