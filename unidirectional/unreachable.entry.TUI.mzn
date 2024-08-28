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

constraint forall (j,i in GRAPH_NODES)(
  let {
    GRAPH_NODES: m = min(i,j);
    GRAPH_NODES: M = max(i,j);
  } in
   HardWires[m,M] == ((m,M) == (1,2) \/ (m,M) == (2,3) \/ (m,M) == (2,7) \/ (m,M) == (4,5))
%   HardWires[m,M] == false
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

predicate transpose(array[$$J, $$I] of var bool: x, array[$$I, $$J] of var bool: t) =
  forall(j in index_set_1of2(x), i in index_set_2of2(x))(
    t[i,j] == x[j,i]
  );

array[index_set_2of2(NodeDisjointSubgraphMatrix),index_set_1of2(NodeDisjointSubgraphMatrix)] of var bool: TNodeDisjointSubgraphMatrix;
array[index_set_2of2(EdgeDisjointSubgraphMatrix),index_set_1of2(EdgeDisjointSubgraphMatrix)] of var bool: TEdgeDisjointSubgraphMatrix;
array[index_set_2of2(DisjointSubgraphRootNodeMask),index_set_1of2(DisjointSubgraphRootNodeMask)] of var bool: TDisjointSubgraphRootNodeMask;

constraint transpose(NodeDisjointSubgraphMatrix, TNodeDisjointSubgraphMatrix);
constraint transpose(EdgeDisjointSubgraphMatrix, TEdgeDisjointSubgraphMatrix);
constraint transpose(DisjointSubgraphRootNodeMask, TDisjointSubgraphRootNodeMask);

output["\n"++"================================================================================\n"];
output["================================================================================\n"];
output["\n"++"HardWires:\n"++show_array2d_bool(HardWires)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"GraphNodes:\n"++show_array2d_bool(array2d(GRAPH_NODES, 1..1, GraphNodes))];
output["\n"++"GraphEdges:\n"++show_array2d_bool(array2d(GRAPH_EDGES, 1..1, GraphEdges))];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"NodeDisjointSubgraphIndex:\n"++show(NodeDisjointSubgraphIndex)++"\n"];
output["\n"++"DisjointSubgraphNodeSet:\n"++show(DisjointSubgraphNodeSet)++"\n"];
output["\n"++"NodeDisjointSubgraphMatrix:\n"++show_array2d_bool(TNodeDisjointSubgraphMatrix)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"EdgeDisjointSubgraphIndex:\n"++show(EdgeDisjointSubgraphIndex)++"\n"];
output["\n"++"DisjointSubgraphEdgeSet:\n"++show(DisjointSubgraphEdgeSet)++"\n"];
output["\n"++"EdgeDisjointSubgraphMatrix:\n"++show_array2d_bool(TEdgeDisjointSubgraphMatrix)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"DisjointSubgraphRootNodeMask:\n"++show_array2d_bool(TDisjointSubgraphRootNodeMask)];
output["\n"++"GraphRootNodeSet:\n"++show(GraphRootNodeSet)++"\n"];
output["\n"++"NodeRootnessMask:\n"++show_array2d_bool(array2d(DISJOINT_SUBGRAPH_NODES, 1..1, NodeRootnessMask))];
output["\n"++"DisjointSubgraphRootNode:\n"++show(array2d(DISJOINT_SUBGRAPH_INDICES, 1..1, DisjointSubgraphRootNode))++"\n"];
output["\n"++"LeastGraphNodeIndexOfDisjointSubgraph:\n"++show(array2d(DISJOINT_SUBGRAPH_INDICES, 1..1, LeastGraphNodeIndexOfDisjointSubgraph))++"\n"];
% output["\n"++"SubgraphNodeRootDistance:\n"++show(array2d(DISJOINT_SUBGRAPH_NODES, 1..1, SubgraphNodeRootDistance))++"\n"];
% output["\n"++"sum(SubgraphNodeRootDistance):\n"++show(sum(SubgraphNodeRootDistance))++"\n"];
% output["\n"++"SubgraphNodeParent:\n"++show(array2d(DISJOINT_SUBGRAPH_NODES, 1..1, SubgraphNodeParent))++"\n"];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"ReachabilityMatrix:\n"++show_array2d_bool(ReachabilityMatrix)];
output["\n"++"================================================================================\n"];
output["================================================================================\n"];
