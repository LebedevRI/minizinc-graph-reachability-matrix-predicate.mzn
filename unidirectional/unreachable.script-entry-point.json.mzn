%-------------------------------------------------------------------------------

include "unreachable.core.mzn";

%-------------------------------------------------------------------------------

array[GRAPH_EDGES,1..2] of int: GRAPH_NODE_PAIRS_par; % par
array[GRAPH_EDGES] of bool: GraphEdges_par; % par

GRAPH_NODE_PAIRS = [ (to_enum(GRAPH_NODES, GRAPH_NODE_PAIRS_par[e,1]), to_enum(GRAPH_NODES, GRAPH_NODE_PAIRS_par[e,2])) | e in GRAPH_EDGES ];

constraint forall (e in GRAPH_EDGES)(
  GraphEdges_par[e] == GraphEdges[e]
);

constraint forall (n in GRAPH_NODES)(
  GraphNodes[n] == exists(e in GRAPH_EDGES)(GraphEdges_par[e] /\ (GRAPH_NODE_PAIRS_par[e,1] == n \/ GRAPH_NODE_PAIRS_par[e,2] == n))
);

%-------------------------------------------------------------------------------

constraint output_to_json_section("NodeDisjointSubgraphIndex", NodeDisjointSubgraphIndex);
constraint output_to_section("NodeDisjointSubgraphIndex", "");
constraint output_to_section("raw", "");
constraint output_to_section("default", "");
output[""];
