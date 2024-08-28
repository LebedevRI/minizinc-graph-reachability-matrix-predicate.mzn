include "subgraph.mzn";
include "link_set_to_booleans.mzn";
include "int_set_channel.mzn";
include "arg_val.mzn";
include "connected.mzn";
include "increasing.mzn";
include "decreasing.mzn";
include "arg_max.mzn";

include "../include/reachable_multiroot.mzn";

%-------------------------------------------------------------------------------

int: NUM_GRAPH_NODES; % par
int: NUM_GRAPH_EDGES; % par

enum GRAPH_NODES = GN(1..NUM_GRAPH_NODES);
enum GRAPH_EDGES = GE(1..NUM_GRAPH_EDGES);

array[GRAPH_EDGES] of tuple(GRAPH_NODES,GRAPH_NODES): GRAPH_NODE_PAIRS; % par
array[GRAPH_EDGES] of GRAPH_NODES: GRAPH_LEAVING_NODE  = [ p.1 | p in GRAPH_NODE_PAIRS ]; % par
array[GRAPH_EDGES] of GRAPH_NODES: GRAPH_ENTERING_NODE = [ p.2 | p in GRAPH_NODE_PAIRS ]; % par

%-------------------------------------------------------------------------------

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

% At worst, no nodes are connected, at best all nodes are connected,
% so we need between 1 and num nodes of disjoint subgraphs.
enum DISJOINT_SUBGRAPH_INDICES = DG(1..NUM_GRAPH_NODES);

% Either graph node, or an ephemeral node.
% We really do need that extra ephemeral node for empty disjoint subgraphs.
enum DISJOINT_SUBGRAPH_NODES = DGn(GRAPH_NODES) ++ {EPH_NODE};

array[GRAPH_EDGES] of DISJOINT_SUBGRAPH_NODES: DISJOINT_SUBGRAPH_LEAVING_NODE = [DGn(GRAPH_LEAVING_NODE[e]) | e in GRAPH_EDGES];
array[GRAPH_EDGES] of DISJOINT_SUBGRAPH_NODES: DISJOINT_SUBGRAPH_ENTERING_NODE = [DGn(GRAPH_ENTERING_NODE[e]) | e in GRAPH_EDGES];

%-------------------------------------------------------------------------------

% Edge either belongs to one of the disjoint subgraphs, or is missing(*).
% We really do need that extra ephemeral disjoint subgraph for missing edges,
% else the logic is clumsier to write.
enum DISJOINT_SUBGRAPH_EDGE_INDICES = DGe(DISJOINT_SUBGRAPH_INDICES) ++ {EPH_SUBGRAPH};

% To which disjoint subgraph does this node belong?
array[GRAPH_NODES] of var DISJOINT_SUBGRAPH_INDICES: NodeDisjointSubgraphIndex; % RETURN !!!
% To which disjoint subgraph(*) does this edge belong?
array[GRAPH_EDGES] of var DISJOINT_SUBGRAPH_EDGE_INDICES: EdgeDisjointSubgraphIndex;

constraint (
% For each edge:
    forall (e in GRAPH_EDGES)(
% If the edge exists, then it has an actual disjoint subgraph index,
% and does not belong to the ephemeral disjoint subgraph, and vice versa.
        GraphEdges[e] == (EdgeDisjointSubgraphIndex[e] != EPH_SUBGRAPH)
% Likewise, if a (direct!) edge exists, then (1) the leaving node of the edge, (2) the edge and
% (3) the entering node of the edge, all share the same disjoint subgraph index.
% Note, however, that if no (direct!) edge exists, it does not tell us anything!
    /\  GraphEdges[e] == (
            EdgeDisjointSubgraphIndex[e] == DGe(NodeDisjointSubgraphIndex[GRAPH_LEAVING_NODE[e]])
        /\  EdgeDisjointSubgraphIndex[e] == DGe(NodeDisjointSubgraphIndex[GRAPH_ENTERING_NODE[e]])
        )
    )
);

%|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

% Per disjoint subgraph, what are the nodes that belong to this disjoint subgraph?
array[DISJOINT_SUBGRAPH_INDICES] of var set of GRAPH_NODES: DisjointSubgraphNodeSet;
% Mask of nodes per disjoint subgraph. NOTE: includes ephemeral `EPH_NODE` node!
array[DISJOINT_SUBGRAPH_INDICES,DISJOINT_SUBGRAPH_NODES] of var bool: NodeDisjointSubgraphMatrix;

% Per disjoint subgraph(*), what are the edges that belong to this disjoint subgraph?
array[DISJOINT_SUBGRAPH_EDGE_INDICES] of var set of GRAPH_EDGES: DisjointSubgraphEdgeSet;
% Mask of edges per disjoint subgraph.
array[DISJOINT_SUBGRAPH_INDICES,GRAPH_EDGES] of var bool: EdgeDisjointSubgraphMatrix;

constraint (
% Channelling between node subgraph index and subgraph node set.
    int_set_channel(NodeDisjointSubgraphIndex, DisjointSubgraphNodeSet)
% Channelling between edge subgraph index and subgraph edge set.
/\  int_set_channel(EdgeDisjointSubgraphIndex, DisjointSubgraphEdgeSet)
% For each disjoint subgraph:
/\  forall (dsi in DISJOINT_SUBGRAPH_INDICES)(
% Channeling between disjoint subgraph node set, and a node - disjoint subgraph matrix.
% Note that the matrix, unlike the set, also tracks an ephemeral EPH_NODE node.
        link_set_to_booleans(
          DisjointSubgraphNodeSet[dsi],
          NodeDisjointSubgraphMatrix[dsi,DGn(GRAPH_NODES)]
        )
% Channeling between disjoint subgraph edge set and a edge - disjoint subgraph matrix.
    /\  link_set_to_booleans(
          DisjointSubgraphEdgeSet[DGe(dsi)],
          EdgeDisjointSubgraphMatrix[dsi,..]
        )
    )
);

%-------------------------------------------------------------------------------

% array[DISJOINT_SUBGRAPH_INDICES] of var bool: LiveDisjointSubgraphs;

% constraint (
% % For each disjoint subgraph:
%     forall (dsi in DISJOINT_SUBGRAPH_INDICES)(
%       LiveDisjointSubgraphs[dsi] == exists(NodeDisjointSubgraphMatrix[dsi,DGn(GRAPH_NODES)])
%     )
% /\  symmetry_breaking_constraint(
%       decreasing(LiveDisjointSubgraphs)
%     )
% );

% constraint (
%   symmetry_breaking_constraint(
%     increasing(NodeDisjointSubgraphMatrix[..,EPH_NODE])
%   )
% );

%-------------------------------------------------------------------------------

% Is a given node a root node for a particular disjoint subgraph?
array[DISJOINT_SUBGRAPH_INDICES,DISJOINT_SUBGRAPH_NODES] of var bool: DisjointSubgraphRootNodeMask;
% What are all the root nodes of the overall graph?
var set of DISJOINT_SUBGRAPH_NODES: GraphRootNodeSet;
% Is this node a root node for some disjoint subgraph?
array[DISJOINT_SUBGRAPH_NODES] of var bool: NodeRootnessMask;
% Per disjoint subgraph, what is the root node of said subgraph?
array[DISJOINT_SUBGRAPH_INDICES] of var DISJOINT_SUBGRAPH_NODES: DisjointSubgraphRootNode;

constraint (
    forall (dsi in DISJOINT_SUBGRAPH_INDICES)(
% Each disjoint subgraph does have (a single) root node.
      count(DisjointSubgraphRootNodeMask[dsi,..]) == 1
    )
% Each actual graph node (i.e. not EPH_NODE) can only be a root of at most one disjoint subgraph.
/\  forall (n in GRAPH_NODES)(
      count(DisjointSubgraphRootNodeMask[..,DGn(n)]) <= 1
    )
% A graph node is a root node if there is a graph for which said node is a root node.
/\  forall (dsn in DISJOINT_SUBGRAPH_NODES)(
      NodeRootnessMask[dsn] == exists(DisjointSubgraphRootNodeMask[..,dsn])
    )
% Per disjoint subgraph, a node can only be it's root if it is a part of said subgraph in the first place.
/\  forall (dsi in DISJOINT_SUBGRAPH_INDICES, dsn in DISJOINT_SUBGRAPH_NODES)(
      (DisjointSubgraphRootNodeMask[dsi,dsn] -> NodeDisjointSubgraphMatrix[dsi,dsn])
    )
%-------------------------------------------------------------------------------
% Channeling between the set of root nodes and node rootness mask.
/\  link_set_to_booleans(GraphRootNodeSet, NodeRootnessMask)
/\  forall (dsi in DISJOINT_SUBGRAPH_INDICES)(
% Channeling between the subgraph root node index and subgraph node rootness mask.
      link_set_to_booleans({DisjointSubgraphRootNode[dsi]}, DisjointSubgraphRootNodeMask[dsi,..])
    )
);

% If any actual graph node is a root node, then all graph nodes 
% must participate (pretend to be selected) in the following test.
array[GRAPH_NODES] of var bool: DisjointSubgraphNodes = [ exists(NodeRootnessMask[DGn(GRAPH_NODES)]) | n in GRAPH_NODES ];

constraint
  reachable_multiroot(
    GRAPH_LEAVING_NODE,
    GRAPH_ENTERING_NODE,
    array1d(GRAPH_NODES, NodeRootnessMask[DGn(GRAPH_NODES)]),
    DisjointSubgraphNodes,
    GraphEdges
  );

%-------------------------------------------------------------------------------

% Per disjoint subgraph, if it has nodes, what is the minimal node index in this disjoint subgraph?
array[DISJOINT_SUBGRAPH_INDICES] of var DISJOINT_SUBGRAPH_NODES: LeastGraphNodeIndexOfDisjointSubgraph;

constraint (
% For each disjoint subgraph:
    forall (dsi in DISJOINT_SUBGRAPH_INDICES)(
% Each disjoint subgraph has at least one node.
      exists(NodeDisjointSubgraphMatrix[dsi,..]) == true
% Which of the nodes of this disjoint subgraph has the lowest index?
    /\  LeastGraphNodeIndexOfDisjointSubgraph[dsi] == arg_max(NodeDisjointSubgraphMatrix[dsi,..])
% Is this disjoint subgraph empty (and contains only ephemeral node `EPH_NODE`),
% or non-empty (and does *NOT* contain node `EPH_NODE`?)
    /\  NodeDisjointSubgraphMatrix[dsi,EPH_NODE] == (DisjointSubgraphNodeSet[dsi] == {})
    /\  NodeDisjointSubgraphMatrix[dsi,EPH_NODE] == (LeastGraphNodeIndexOfDisjointSubgraph[dsi] == EPH_NODE)
%     /\  symmetry_breaking_constraint(DisjointSubgraphRootNode[dsi] == EPH_NODE \/ DisjointSubgraphRootNode[dsi] == DGn(GN(DG^-1(dsi))))
    )
% Enforce global ordering of disjoint subgraphs.
/\  symmetry_breaking_constraint(
      increasing(LeastGraphNodeIndexOfDisjointSubgraph)
    )
);

%-------------------------------------------------------------------------------
% /\ The Algorithm
%===============================================================================
% \/ User code
%-------------------------------------------------------------------------------

solve :: int_search(NodeDisjointSubgraphIndex, input_order, indomain_min) satisfy;
