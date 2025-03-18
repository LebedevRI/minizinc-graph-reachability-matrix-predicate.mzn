# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..3)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 736/736 [00:02<00:00, 279.47it/s]
Running tests (random, N=0..10)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 12800/12800 [00:55<00:00, 230.15it/s]
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:211: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:243: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
| Name                                   | NumNodes (big-O)   | ... (formula)                       | NumEdges (big-O)   | ... (formula)                            |
|----------------------------------------|--------------------|-------------------------------------|--------------------|------------------------------------------|
| (flat) paths                           | Constant           | -0                                  | Constant           | -0                                       |
| (flat) flatBoolVars                    | Cubic              | -0.17 + 0.81*NumNodes^3             | Linearithmic       | 16 + 3.9*NumEdges*log(NumEdges)          |
| (flat) flatIntVars                     | Cubic              | 5.4 + 0.2*NumNodes^3                | Linear             | -2.5 + 3.9*NumEdges                      |
| (flat) flatBoolConstraints             | Cubic              | 11 + 0.48*NumNodes^3                | Linear             | 6.7 + 8.7*NumEdges                       |
| (flat) flatIntConstraints              | Cubic              | 4.3 + 0.52*NumNodes^3               | Linear             | -25 + 11*NumEdges                        |
| (flat) evaluatedReifiedConstraints     | Cubic              | 3.6 + 0.13*NumNodes^3               | Linear             | -1.7 + 2.6*NumEdges                      |
| (flat) evaluatedHalfReifiedConstraints | Cubic              | -4.3 + 0.2*NumNodes^3               | Linearithmic       | -4 + 1*NumEdges*log(NumEdges)            |
| (flat) flatTime                        | Cubic              | 0.092 + 5.6E-05*NumNodes^3          | Exponential        | 0.095 * 1^NumEdges                       |
| (solve) nodes                          | Cubic              | -3.2E+02 + 3.3*NumNodes^3           | Quadratic          | -85 + 1.2*NumEdges^2                     |
| (solve) failures                       | Cubic              | -50 + 0.53*NumNodes^3               | Cubic              | 16 + 0.0027*NumEdges^3                   |
| (solve) restarts                       | Constant           | -0                                  | Constant           | -0                                       |
| (solve) variables                      | Cubic              | -1E+02 + 7.1*NumNodes^3             | Linear             | -41 + 1.2E+02*NumEdges                   |
| (solve) intVars                        | Quadratic          | -11 + 2.1*NumNodes^2                | Linear             | 2.5 + 4*NumEdges                         |
| (solve) boolVariables                  | Cubic              | -1.1E+02 + 6.9*NumNodes^3           | Linear             | -45 + 1.2E+02*NumEdges                   |
| (solve) propagators                    | Cubic              | 8.2 + 0.26*NumNodes^3               | Linear             | -2.3 + 5.2*NumEdges                      |
| (solve) propagations                   | Cubic              | -6.7E+03 + 61*NumNodes^3            | Quadratic          | -2.7E+03 + 21*NumEdges^2                 |
| (solve) peakDepth                      | Cubic              | -7.8 + 0.16*NumNodes^3              | Quadratic          | 2.7 + 0.058*NumEdges^2                   |
| (solve) nogoods                        | Cubic              | -50 + 0.53*NumNodes^3               | Cubic              | 16 + 0.0027*NumEdges^3                   |
| (solve) backjumps                      | Cubic              | -2.6E+02 + 2.6*NumNodes^3           | Quadratic          | -65 + 0.91*NumEdges^2                    |
| (solve) peakMem                        | Constant           | -0                                  | Constant           | -0                                       |
| (solve) time                           | Cubic              | 0.091 + 8.5E-05*NumNodes^3          | Exponential        | 0.094 * 1^NumEdges                       |
| (solve) initTime                       | Cubic              | 0.093 + 6.5E-05*NumNodes^3          | Linear             | 0.095 + 0.001*NumEdges                   |
| (solve) solveTime                      | Cubic              | -0.0022 + 2.1E-05*NumNodes^3        | Quadratic          | -0.00079 + 7.4E-06*NumEdges^2            |
| (solve) baseMem                        | Constant           | -0                                  | Constant           | -0                                       |
| (solve) trailMem                       | Cubic              | -0.00063 + 1.9E-05*NumNodes^3       | Linearithmic       | -0.00083 + 0.0001*NumEdges*log(NumEdges) |
| (flat) eliminatedImplications          | Linearithmic       | -0.63 + 0.26*NumNodes*log(NumNodes) | Logarithmic        | -0.67 + 1.3*log(NumEdges)                |
```

# `$ minizinc --all-solutions unreachable.entry.TUI.mzn`

```
$ minizinc unreachable.entry.TUI.mzn

================================================================================
================================================================================

HardWires:
  12
1  █
2   

--------------------------------------------------------------------------------

GraphNodes:
  1
1 █
2 █

GraphEdges:
  1
1 █

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

ReachabilityMatrix:
  12
1 ██
2  █

================================================================================
================================================================================
----------
```
