include "subgraph.mzn";
include "link_set_to_booleans.mzn";
include "int_set_channel.mzn";
include "arg_val.mzn";
include "connected.mzn";

%-------------------------------------------------------------------------------

int: NUM_GRAPH_NODES; % par
int: NUM_GRAPH_EDGES; % par

enum GRAPH_NODES = GN(1..NUM_GRAPH_NODES);
enum GRAPH_EDGES = GE(1..NUM_GRAPH_EDGES);

array[GRAPH_EDGES] of tuple(GRAPH_NODES,GRAPH_NODES): GRAPH_NODE_PAIRS; % par
array[GRAPH_EDGES] of GRAPH_NODES: GRAPH_LEAVING_NODE  = [ p.1 | p in GRAPH_NODE_PAIRS ];
array[GRAPH_EDGES] of GRAPH_NODES: GRAPH_ENTERING_NODE = [ p.2 | p in GRAPH_NODE_PAIRS ];

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
% We really do need that extra ephemeral node for empty disjoint subgraphs
enum DISJOINT_SUBGRAPH_NODES = DGn(GRAPH_NODES) ++ {NO_NODE};

array[GRAPH_EDGES] of DISJOINT_SUBGRAPH_NODES: DISJOINT_SUBGRAPH_LEAVING_NODE = [DGn(GRAPH_LEAVING_NODE[e]) | e in GRAPH_EDGES];
array[GRAPH_EDGES] of DISJOINT_SUBGRAPH_NODES: DISJOINT_SUBGRAPH_ENTERING_NODE = [DGn(GRAPH_ENTERING_NODE[e]) | e in GRAPH_EDGES];

%-------------------------------------------------------------------------------

% To which disjoint subgraph does this node belong?
array[GRAPH_NODES] of var DISJOINT_SUBGRAPH_INDICES: NodeDisjointSubgraphIndex;
% Per disjoint subgraph, what are the nodes that belong to this disjoint subgraph?
array[DISJOINT_SUBGRAPH_INDICES] of var set of GRAPH_NODES: DisjointSubgraphNodeSet;
% Mask of nodes per disjoint subgraph. NOTE: includes ephemeral `NO_NODE` node!
array[DISJOINT_SUBGRAPH_NODES,DISJOINT_SUBGRAPH_INDICES] of var bool: NodeDisjointSubgraphMatrix;
% Per disjoint subgraph, if it has nodes, what is the minimal node index in this disjoint subgraph?
array[DISJOINT_SUBGRAPH_INDICES] of var DISJOINT_SUBGRAPH_NODES: LeastGraphNodeIndexOfDisjointSubgraph;

constraint (
% Channelling between node subgraph index and subgraph node set.
    int_set_channel(NodeDisjointSubgraphIndex, DisjointSubgraphNodeSet)
% For each disjoint subgraph:
/\  forall (nsi in DISJOINT_SUBGRAPH_INDICES)(
% Channeling between disjoint subgraph node set, and a node - disjoint subgraph matrix.
% Note that the matrix, unlike the set, also tracks an ephemeral NO_NODE node.
      link_set_to_booleans(
        DisjointSubgraphNodeSet[nsi],
        NodeDisjointSubgraphMatrix[DGn(GRAPH_NODES),nsi]
      )
% Which of the nodes of this disjoint subgraph has the lowest index?
/\    LeastGraphNodeIndexOfDisjointSubgraph[nsi] == arg_val(NodeDisjointSubgraphMatrix[..,nsi], true)
% Is this disjoint subgraph empty (and contains only ephemeral node `NO_NODE`),
% or non-empty (and does *NOT* contain node `NO_NODE`?)
/\    NodeDisjointSubgraphMatrix[NO_NODE,nsi] == (card(DisjointSubgraphNodeSet[nsi]) == 0)
/\    NodeDisjointSubgraphMatrix[NO_NODE,nsi] == (LeastGraphNodeIndexOfDisjointSubgraph[nsi] == NO_NODE)
% Enforce global ordering of disjoint subgraphs.
% This is nessesary, and sufficient, to result in an unique solution.
/\    symmetry_breaking_constraint(
          NodeDisjointSubgraphMatrix[NO_NODE,nsi]
      \/  LeastGraphNodeIndexOfDisjointSubgraph[nsi] == DG^-1(nsi)
      )
    )
);

%-------------------------------------------------------------------------------

% Edge either belongs to one of the disjoint subgraphs, or is missing(*).
% We really do need that extra ephemeral disjoint subgraph for missing edges,
% else the logic is clumsier to write.
enum DISJOINT_SUBGRAPH_EDGE_INDICES = DGe(DISJOINT_SUBGRAPH_INDICES) ++ {NO_EDGE};

% To which disjoint subgraph(*) does this edge belong?
array[GRAPH_EDGES] of var DISJOINT_SUBGRAPH_EDGE_INDICES: EdgeDisjointSubgraphIndex;
% Per disjoint subgraph(*), what are the edges that belong to this disjoint subgraph?
array[DISJOINT_SUBGRAPH_EDGE_INDICES] of var set of GRAPH_EDGES: DisjointSubgraphEdgeSet;
% Mask of edges per disjoint subgraph.
array[GRAPH_EDGES,DISJOINT_SUBGRAPH_INDICES] of var bool: EdgeDisjointSubgraphMatrix;

constraint (
% Channelling between edge subgraph index and subgraph edge set.
    int_set_channel(EdgeDisjointSubgraphIndex, DisjointSubgraphEdgeSet)
% Channeling between disjoint subgraph edge set and a edge - disjoint subgraph matrix.
/\  forall (n in DISJOINT_SUBGRAPH_INDICES)(
      link_set_to_booleans(
        DisjointSubgraphEdgeSet[DGe(n)],
        EdgeDisjointSubgraphMatrix[..,n]
      )
    )
% For each edge:
/\  forall (e in GRAPH_EDGES)(
% If the edge exists, then it has an actual disjoint subgraph index,
% and does not belong to the ephemeral disjoint subgraph, and vice versa.
        GraphEdges[e] == (EdgeDisjointSubgraphIndex[e] != NO_EDGE)
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

constraint (
% For each node:
    forall (n in DISJOINT_SUBGRAPH_INDICES)(
% Finally! Actually enforce that each disjoint subgraph is actually connected,
% that every node is reachable from every node of this disjoint subgraph.
%
% Note that `connect` requires that the graph has at least one active node,
% and we've gone out of our way to ensure that, via NO_NODE ephemeral node.
%
% WARNING WARNING WARNING
% `connected()` is internally O(n^2) of the number of nodes,
% so this predicate has complexity of O(n^3) of the number of nodes,
    connected(
        DISJOINT_SUBGRAPH_LEAVING_NODE,
        DISJOINT_SUBGRAPH_ENTERING_NODE,
        NodeDisjointSubgraphMatrix[..,n],
        EdgeDisjointSubgraphMatrix[..,n]
      )
    )
);

%-------------------------------------------------------------------------------
% /\ The Algorithm
%===============================================================================
% \/ User code
%-------------------------------------------------------------------------------

solve :: int_search(NodeDisjointSubgraphIndex, input_order, indomain_min) satisfy;
