# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..4)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 756/756 [00:02<00:00, 316.52it/s]
Running tests (random, N=0..15)...
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 128000/128000 [10:09<00:00, 210.11it/s]
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:211: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:243: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
| Name                                   | NumNodes (big-O)   | ... (formula)                 | NumEdges (big-O)   | ... (formula)               |
|----------------------------------------|--------------------|-------------------------------|--------------------|-----------------------------|
| (flat) paths                           | Constant           | -0                            | Constant           | -0                          |
| (flat) flatBoolVars                    | Quadratic          | 4 + 0.87*NumNodes^2           | Linear             | 27 + 2.6*NumEdges           |
| (flat) flatIntVars                     | Linear             | -1.8 + 3*NumNodes             | Logarithmic        | 3.3 + 8.7*log(NumEdges)     |
| (flat) flatBoolConstraints             | Linear             | -3.7 + 2.8*NumNodes           | Logarithmic        | -0.94 + 9.3*log(NumEdges)   |
| (flat) flatIntConstraints              | Quadratic          | 8.7 + 0.84*NumNodes^2         | Linear             | 30 + 2.5*NumEdges           |
| (flat) evaluatedReifiedConstraints     | Polynomial         | 2.4 * x^1.5                   | Logarithmic        | 9.3 + 25*log(NumEdges)      |
| (flat) evaluatedHalfReifiedConstraints | Quadratic          | -0.38 + 0.24*NumNodes^2       | Linear             | 0.029 + 1*NumEdges          |
| (flat) flatTime                        | Quadratic          | 0.077 + 6.1E-05*NumNodes^2    | Linear             | 0.078 + 0.00021*NumEdges    |
| (solve) nodes                          | Cubic              | -9.6E+02 + 2.4*NumNodes^3     | Cubic              | -1.2E+02 + 0.03*NumEdges^3  |
| (solve) failures                       | Cubic              | -7.9E+02 + 1.9*NumNodes^3     | Cubic              | -1.9E+02 + 0.025*NumEdges^3 |
| (solve) restarts                       | Constant           | -0                            | Constant           | -0                          |
| (solve) variables                      | Quadratic          | 4.6 + 6.7*NumNodes^2          | Linear             | 1.9E+02 + 20*NumEdges       |
| (solve) intVars                        | Linear             | -1.3 + 3*NumNodes             | Logarithmic        | 5.8 + 8.1*log(NumEdges)     |
| (solve) boolVariables                  | Quadratic          | -6.7 + 6.5*NumNodes^2         | Linear             | 1.8E+02 + 19*NumEdges       |
| (solve) propagators                    | Quadratic          | -3.3 + 1*NumNodes^2           | Logarithmic        | -31 + 51*log(NumEdges)      |
| (solve) propagations                   | Cubic              | -7.3E+04 + 1.7E+02*NumNodes^3 | Cubic              | -2E+04 + 2.1*NumEdges^3     |
| (solve) peakDepth                      | Quadratic          | -0.83 + 0.16*NumNodes^2       | Logarithmic        | -4 + 7.4*log(NumEdges)      |
| (solve) nogoods                        | Cubic              | -7.9E+02 + 1.9*NumNodes^3     | Cubic              | -1.9E+02 + 0.025*NumEdges^3 |
| (solve) backjumps                      | Cubic              | -1.7E+02 + 0.47*NumNodes^3    | Cubic              | 51 + 0.0047*NumEdges^3      |
| (solve) peakMem                        | Constant           | -0                            | Constant           | -0                          |
| (solve) time                           | Cubic              | 0.051 + 6.8E-05*NumNodes^3    | Cubic              | 0.069 + 9.2E-07*NumEdges^3  |
| (solve) initTime                       | Quadratic          | 0.078 + 7E-05*NumNodes^2      | Linear             | 0.079 + 0.00023*NumEdges    |
| (solve) solveTime                      | Cubic              | -0.029 + 6.3E-05*NumNodes^3   | Cubic              | -0.013 + 8.9E-07*NumEdges^3 |
| (solve) baseMem                        | Constant           | -0                            | Constant           | -0                          |
| (solve) trailMem                       | Quadratic          | -0.00035 + 4.8E-05*NumNodes^2 | Linear             | 0.00037 + 0.00017*NumEdges  |
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
