%-------------------------------------------------------------------------------

include "unreachable.core.mzn";

%-------------------------------------------------------------------------------

NUM_GRAPH_NODES = 5; % par
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
%   HardWires[m,M] == ((m,M) == (1,2) \/ (m,M) == (2,5))
  HardWires[m,M] == ((m,M) == (1,2) \/ (m,M) == (2,3) \/ (m,M) == (5,6))
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

% constraint output_to_json_section("ReachabilityMatrix", ReachabilityMatrix);
% constraint output_to_section("ReachabilityMatrix", "");
% constraint output_to_section("raw", "");
% constraint output_to_section("default", "");
% output[""];
