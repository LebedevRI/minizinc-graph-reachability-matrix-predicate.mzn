# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..4)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 756/756 [00:02<00:00, 319.56it/s]
Running tests (random, N=0..15)...
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 128000/128000 [07:00<00:00, 304.26it/s]
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:211: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:243: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
| Name                                   | NumNodes (big-O)   | ... (formula)                 | NumEdges (big-O)   | ... (formula)                             |
|----------------------------------------|--------------------|-------------------------------|--------------------|-------------------------------------------|
| (flat) paths                           | Constant           | -0                            | Constant           | -0                                        |
| (flat) flatBoolVars                    | Quadratic          | 4.2 + 0.87*NumNodes^2         | Linear             | 27 + 2.6*NumEdges                         |
| (flat) flatIntVars                     | Linear             | -2.7 + 3*NumNodes             | Logarithmic        | 1.9 + 9.1*log(NumEdges)                   |
| (flat) flatBoolConstraints             | Linear             | -3.7 + 2.8*NumNodes           | Logarithmic        | -1 + 9.3*log(NumEdges)                    |
| (flat) flatIntConstraints              | Quadratic          | 5.4 + 0.77*NumNodes^2         | Linear             | 25 + 2.4*NumEdges                         |
| (flat) evaluatedReifiedConstraints     | Quadratic          | 4.6 + 0.52*NumNodes^2         | Logarithmic        | 3.5 + 20*log(NumEdges)                    |
| (flat) evaluatedHalfReifiedConstraints | Quadratic          | -0.26 + 0.23*NumNodes^2       | Linear             | 0.0088 + 1*NumEdges                       |
| (flat) flatTime                        | Quadratic          | 0.081 + 6.3E-05*NumNodes^2    | Linear             | 0.082 + 0.00021*NumEdges                  |
| (solve) nodes                          | Cubic              | -53 + 0.44*NumNodes^3         | Linear             | -47 + 22*NumEdges                         |
| (solve) failures                       | Cubic              | -13 + 0.12*NumNodes^3         | Linear             | -12 + 6.2*NumEdges                        |
| (solve) restarts                       | Constant           | -0                            | Constant           | -0                                        |
| (solve) variables                      | Quadratic          | 6.9 + 6.9*NumNodes^2          | Logarithmic        | -1.1E+02 + 3.2E+02*log(NumEdges)          |
| (solve) intVars                        | Linear             | -2.1 + 3.1*NumNodes           | Logarithmic        | 4.5 + 8.5*log(NumEdges)                   |
| (solve) boolVariables                  | Quadratic          | -3.8 + 6.7*NumNodes^2         | Linear             | 2.1E+02 + 19*NumEdges                     |
| (solve) propagators                    | Quadratic          | -3 + 1*NumNodes^2             | Logarithmic        | -31 + 51*log(NumEdges)                    |
| (solve) propagations                   | Cubic              | -4.8E+03 + 20*NumNodes^3      | Linearithmic       | -1.2E+03 + 2.3E+02*NumEdges*log(NumEdges) |
| (solve) peakDepth                      | Quadratic          | -1.3 + 0.3*NumNodes^2         | Linear             | 6.1 + 0.91*NumEdges                       |
| (solve) nogoods                        | Cubic              | -13 + 0.12*NumNodes^3         | Linear             | -12 + 6.2*NumEdges                        |
| (solve) backjumps                      | Cubic              | -45 + 0.27*NumNodes^3         | Linear             | -36 + 13*NumEdges                         |
| (solve) peakMem                        | Constant           | -0                            | Constant           | -0                                        |
| (solve) time                           | Cubic              | 0.083 + 8.8E-06*NumNodes^3    | Linear             | 0.083 + 0.00045*NumEdges                  |
| (solve) initTime                       | Quadratic          | 0.082 + 7.2E-05*NumNodes^2    | Linear             | 0.084 + 0.00024*NumEdges                  |
| (solve) solveTime                      | Cubic              | -0.00068 + 4.1E-06*NumNodes^3 | Linear             | -0.00076 + 0.00021*NumEdges               |
| (solve) baseMem                        | Constant           | -0                            | Constant           | -0                                        |
| (solve) trailMem                       | Cubic              | 0.00013 + 7.2E-06*NumNodes^3  | Linearithmic       | 0.00048 + 9.7E-05*NumEdges*log(NumEdges)  |
```

# `$ minizinc --all-solutions unreachable.entry.TUI.mzn`

```
$ minizinc --all-solutions unreachable.entry.TUI.mzn

================================================================================
================================================================================

HardWires:
  1234567
1  █
2 █ █   █
3  █
4     █
5    █
6
7  █

--------------------------------------------------------------------------------

GraphNodes:
  1
1 █
2 █
3 █
4 █
5 █
6
7 █

GraphEdges:
   1
 1 █
 2
 3
 4
 5
 6
 7 █
 8
 9
10
11 █
12
13
14
15
16 █
17
18
19
20
21

--------------------------------------------------------------------------------

NodeDisjointSubgraphIndex:
[DG(1), DG(1), DG(1), DG(2), DG(2), DG(3), DG(1)]

DisjointSubgraphNodeSet:
[{GN(1), GN(2), GN(3), GN(7)}, {GN(4), GN(5)}, {GN(6)}, {}, {}, {}, {}]

NodeDisjointSubgraphMatrix:
  1234567
1 █
2 █
3 █
4  █
5  █
6   █
7 █
8    ████

--------------------------------------------------------------------------------

EdgeDisjointSubgraphIndex:
[DGe(DG(1)), EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, DGe(DG(1)), EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, DGe(DG(1)), EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, DGe(DG(2)), EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH, EPH_SUBGRAPH]

DisjointSubgraphEdgeSet:
[{GE(1), GE(7), GE(11)}, {GE(16)}, {}, {}, {}, {}, {}, {GE(2), GE(3), GE(4), GE(5), GE(6), GE(8), GE(9), GE(10), GE(12), GE(13), GE(14), GE(15), GE(17), GE(18), GE(19), GE(20), GE(21)}]

EdgeDisjointSubgraphMatrix:
   1234567
 1 █
 2
 3
 4
 5
 6
 7 █
 8
 9
10
11 █
12
13
14
15
16  █
17
18
19
20
21

--------------------------------------------------------------------------------

ReachabilityMatrix:
  1234567
1 ███   █
2 ███   █
3 ███   █
4    ██
5    ██
6      █
7 ███   █

================================================================================
================================================================================
----------
==========
```
