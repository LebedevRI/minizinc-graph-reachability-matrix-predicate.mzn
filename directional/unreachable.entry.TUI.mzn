%-------------------------------------------------------------------------------

include "unreachable.core.mzn";

%-------------------------------------------------------------------------------

NUM_GRAPH_NODES = 10; % par
NUM_GRAPH_EDGES = length(j,i in GRAPH_NODES where i > j)(1); % par
GRAPH_NODE_PAIRS = [ (j,i) | j,i in GRAPH_NODES where i > j ]; % par

%-------------------------------------------------------------------------------

array[GRAPH_NODES,GRAPH_NODES] of var bool: HardWires;

constraint forall (c in GRAPH_NODES)(
  HardWires[c,c] == false
);

constraint forall (j,i in GRAPH_NODES)(
  HardWires[j,i] == ((enum2int(j),enum2int(i)) == (1,2) \/ (enum2int(j),enum2int(i)) == (1,3))
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
  GraphNodes[n] == exists(HardWires[n,..]) \/ exists(HardWires[..,n])
);

constraint forall (e in GRAPH_EDGES)(
  GraphEdges[e] == HardWires[GRAPH_LEAVING_NODE[e],GRAPH_ENTERING_NODE[e]]
);

%-------------------------------------------------------------------------------

predicate transpose(array[$$J, $$I] of var bool: x, array[$$I, $$J] of var bool: t) =
  forall(j in index_set_1of2(x), i in index_set_2of2(x))(
    t[i,j] == x[j,i]
  );

output["\n"++"================================================================================\n"];
output["================================================================================\n"];
output["\n"++"HardWires:\n"++show_array2d_bool(HardWires)];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"GraphNodes:\n"++show_array2d_bool(array2d(GRAPH_NODES, 1..1, GraphNodes))];
output["\n"++"GraphEdges:\n"++show_array2d_bool(array2d(GRAPH_EDGES, 1..1, GraphEdges))];
output["\n"++"--------------------------------------------------------------------------------\n"];
% output["\n"++"ClusterIndex:\n"++show(ClusterIndex)++"\n"];
% output["\n"++"EdgeRoot:\n"++show(EdgeRoot)++"\n"];
output["\n"++"--------------------------------------------------------------------------------\n"];
% output["\n"++"NodeRootnessMask:\n"++show_array2d_bool(array2d(GRAPH_NODES, 1..1, NodeRootnessMask))];
output["\n"++"--------------------------------------------------------------------------------\n"];
output["\n"++"ReachabilityMatrix:\n"++show_array2d_bool(ReachabilityMatrix)];
output["\n"++"================================================================================\n"];
output["================================================================================\n"];
