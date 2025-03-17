# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..3)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 736/736 [00:02<00:00, 278.85it/s]
Running tests (random, N=0..10)...
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 128000/128000 [10:26<00:00, 204.47it/s]
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:211: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
/home/lebedevri/.local/lib/python3.13/site-packages/big_o/complexities.py:243: RuntimeWarning: divide by zero encountered in log
  return np.log(t)
| Name                                   | NumNodes (big-O)   | ... (formula)                      | NumEdges (big-O)    | ... (formula)                            |
|----------------------------------------|--------------------|-------------------------------------|--------------------|------------------------------------------|
| (flat) paths                           | Constant           | -0                                  | Constant           | -0                                       |
| (flat) flatBoolVars                    | Cubic              | 0.67 + 1.1*NumNodes^3               | Linearithmic       | 29 + 5.2*NumEdges*log(NumEdges)          |
| (flat) flatIntVars                     | Cubic              | 6.1 + 0.19*NumNodes^3               | Linear             | -1.6 + 3.9*NumEdges                      |
| (flat) flatBoolConstraints             | Cubic              | 7.6 + 0.7*NumNodes^3                | Linear             | -12 + 13*NumEdges                        |
| (flat) flatIntConstraints              | Cubic              | 4.9 + 0.51*NumNodes^3               | Linear             | -24 + 11*NumEdges                        |
| (flat) evaluatedReifiedConstraints     | Quadratic          | -14 + 2.3*NumNodes^2                | Linear             | 14 + 3.7*NumEdges                        |
| (flat) evaluatedHalfReifiedConstraints | Cubic              | -3.9 + 0.2*NumNodes^3               | Linearithmic       | -3.5 + 1*NumEdges*log(NumEdges)          |
| (flat) flatTime                        | Cubic              | 0.087 + 0.00012*NumNodes^3          | Linearithmic       | 0.098 + 0.00046*NumEdges*log(NumEdges)   |
| (solve) nodes                          | Cubic              | -3.5E+02 + 3.4*NumNodes^3           | Quadratic          | -85 + 1.2*NumEdges^2                     |
| (solve) failures                       | Cubic              | -53 + 0.53*NumNodes^3               | Cubic              | 17 + 0.0027*NumEdges^3                   |
| (solve) restarts                       | Constant           | -0                                  | Constant           | -0                                       |
| (solve) variables                      | Cubic              | -1.1E+02 + 7.4*NumNodes^3           | Linear             | -25 + 1.3E+02*NumEdges                   |
| (solve) intVars                        | Cubic              | 10 + 0.2*NumNodes^3                 | Linear             | 3.5 + 4*NumEdges                         |
| (solve) boolVariables                  | Cubic              | -1.2E+02 + 7.2*NumNodes^3           | Linear             | -30 + 1.2E+02*NumEdges                   |
| (solve) propagators                    | Cubic              | 8.4 + 0.26*NumNodes^3               | Linear             | -1.8 + 5.2*NumEdges                      |
| (solve) propagations                   | Cubic              | -7.1E+03 + 61*NumNodes^3            | Quadratic          | -2.8E+03 + 21*NumEdges^2                 |
| (solve) peakDepth                      | Cubic              | -7.7 + 0.18*NumNodes^3              | Quadratic          | 4.5 + 0.065*NumEdges^2                   |
| (solve) nogoods                        | Cubic              | -53 + 0.53*NumNodes^3               | Cubic              | 17 + 0.0027*NumEdges^3                   |
| (solve) backjumps                      | Cubic              | -2.9E+02 + 2.7*NumNodes^3           | Quadratic          | -66 + 0.93*NumEdges^2                    |
| (solve) peakMem                        | Constant           | -0                                  | Constant           | -0                                       |
| (solve) time                           | Cubic              | 0.086 + 0.00015*NumNodes^3          | Linearithmic       | 0.097 + 0.00062*NumEdges*log(NumEdges)   |                                    | (solve) initTime                       | Cubic              | 0.088 + 0.00013*NumNodes^3          | Linearithmic       | 0.1 + 0.0005*NumEdges*log(NumEdges)      |
| (solve) solveTime                      | Cubic              | -0.0024 + 2.1E-05*NumNodes^3        | Quadratic          | -0.00079 + 7.5E-06*NumEdges^2            |
| (solve) baseMem                        | Constant           | -0                                  | Constant           | -0                                       |
| (solve) trailMem                       | Cubic              | -0.00065 + 1.9E-05*NumNodes^3       | Linearithmic       | -0.00085 + 0.0001*NumEdges*log(NumEdges) |
| (flat) eliminatedImplications          | Linearithmic       | -0.68 + 0.27*NumNodes*log(NumNodes) | Logarithmic        | -0.6 + 1.3*log(NumEdges)                 |
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
