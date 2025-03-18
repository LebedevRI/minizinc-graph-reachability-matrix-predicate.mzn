# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..3)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 736/736 [00:02<00:00, 281.17it/s]
Running tests (random, N=0..10)...
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 128000/128000 [09:05<00:00, 234.69it/s]
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:211: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:243: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
| Name                                   | NumNodes (big-O)   | ... (formula)                       | NumEdges (big-O)   | ... (formula)                            |
|----------------------------------------|--------------------|-------------------------------------|--------------------|------------------------------------------|
| (flat) paths                           | Constant           | -0                                  | Constant           | -0                                       |
| (flat) flatBoolVars                    | Cubic              | -0.97 + 0.8*NumNodes^3              | Linearithmic       | 17 + 3.9*NumEdges*log(NumEdges)          |
| (flat) flatIntVars                     | Cubic              | 5.4 + 0.19*NumNodes^3               | Linear             | -2.1 + 3.9*NumEdges                      |
| (flat) flatBoolConstraints             | Cubic              | 10 + 0.48*NumNodes^3                | Linear             | 9.2 + 8.7*NumEdges                       |
| (flat) flatIntConstraints              | Cubic              | 3.9 + 0.52*NumNodes^3               | Linear             | -25 + 11*NumEdges                        |
| (flat) evaluatedReifiedConstraints     | Cubic              | 3.6 + 0.13*NumNodes^3               | Linear             | -1.4 + 2.6*NumEdges                      |
| (flat) evaluatedHalfReifiedConstraints | Cubic              | -4.7 + 0.2*NumNodes^3               | Linearithmic       | -4 + 1*NumEdges*log(NumEdges)            |
| (flat) flatTime                        | Cubic              | 0.092 + 5.6E-05*NumNodes^3          | Exponential        | 0.095 * 1^NumEdges                       |
| (solve) nodes                          | Cubic              | -3.5E+02 + 3.4*NumNodes^3           | Quadratic          | -89 + 1.2*NumEdges^2                     |
| (solve) failures                       | Cubic              | -55 + 0.54*NumNodes^3               | Cubic              | 17 + 0.0027*NumEdges^3                   |
| (solve) restarts                       | Constant           | -0                                  | Constant           | -0                                       |
| (solve) variables                      | Cubic              | -1.1E+02 + 7.1*NumNodes^3           | Linear             | -16 + 1.2E+02*NumEdges                   |
| (solve) intVars                        | Quadratic          | -12 + 2.1*NumNodes^2                | Linear             | 3 + 4*NumEdges                           |
| (solve) boolVariables                  | Cubic              | -1.2E+02 + 6.9*NumNodes^3           | Linear             | -21 + 1.2E+02*NumEdges                   |
| (solve) propagators                    | Cubic              | 8.3 + 0.26*NumNodes^3               | Linear             | -1.8 + 5.2*NumEdges                      |
| (solve) propagations                   | Cubic              | -7.3E+03 + 61*NumNodes^3            | Quadratic          | -2.9E+03 + 22*NumEdges^2                 |
| (solve) peakDepth                      | Cubic              | -8.3 + 0.16*NumNodes^3              | Quadratic          | 2.9 + 0.058*NumEdges^2                   |
| (solve) nogoods                        | Cubic              | -55 + 0.54*NumNodes^3               | Cubic              | 17 + 0.0027*NumEdges^3                   |
| (solve) backjumps                      | Cubic              | -2.8E+02 + 2.7*NumNodes^3           | Quadratic          | -68 + 0.91*NumEdges^2                    |
| (solve) peakMem                        | Constant           | -0                                  | Constant           | -0                                       |
| (solve) time                           | Cubic              | 0.09 + 8.5E-05*NumNodes^3           | Exponential        | 0.094 * 1^NumEdges                       |
| (solve) initTime                       | Cubic              | 0.093 + 6.4E-05*NumNodes^3          | Linear             | 0.095 + 0.001*NumEdges                   |
| (solve) solveTime                      | Cubic              | -0.0024 + 2.1E-05*NumNodes^3        | Quadratic          | -0.00085 + 7.5E-06*NumEdges^2            |
| (solve) baseMem                        | Constant           | -0                                  | Constant           | -0                                       |
| (solve) trailMem                       | Cubic              | -0.0007 + 1.9E-05*NumNodes^3        | Linearithmic       | -0.00088 + 0.0001*NumEdges*log(NumEdges) |
| (flat) eliminatedImplications          | Linearithmic       | -0.67 + 0.26*NumNodes*log(NumNodes) | Logarithmic        | -0.59 + 1.3*log(NumEdges)                |
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
