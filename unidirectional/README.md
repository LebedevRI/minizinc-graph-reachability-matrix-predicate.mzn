# Correctness + perf

```
$ ./unreachable.test.py
Generating tests (exhaustive, N=0..5)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 59810/59810 [03:30<00:00, 284.33it/s]

Compile time big-O: 
 + 3.11e-14*NumNodes^2
 + 8.17e-14*NumEdges^2
 + 4.31e-14*NumEdges^3

      message: `ftol` termination condition is satisfied.
     success: True
      status: 2
         fun: [ 8.928e-04  3.286e-04 ...  4.673e-02  4.855e-02]
           x: [ 7.424e-02  3.357e-03  3.108e-14  1.075e-05  1.594e-04
                8.166e-14  4.312e-14]
        cost: 0.5408603567188084
         jac: [[ 1.000e+00  5.000e+00 ...  3.600e+01  2.160e+02]
               [ 1.000e+00  5.000e+00 ...  2.500e+01  1.250e+02]
               ...
               [ 1.000e+00  5.000e+00 ...  6.400e+01  5.120e+02]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]]
        grad: [-2.594e-10  1.518e-08  5.507e-03 -8.422e-07 -6.847e-08
                3.906e+00  8.786e+01]
  optimality: 8.42166084424889e-07
 active_mask: [ 0  0 -1  0  0 -1 -1]
        nfev: 39
        njev: 39

Solve time big-O: 
 + 4.81e-13 
 + 9.73e-15*NumNodes^1
 + 1.07e-11*NumNodes^2
 + 2.66e-18*NumEdges^2
 + 2.16e-19*NumEdges^3

      message: `gtol` termination condition is satisfied.
     success: True
      status: 1
         fun: [-1.203e-03  7.672e-04 ... -1.423e-04  8.275e-04]
           x: [ 4.807e-13  9.735e-15  1.069e-11  4.931e-06  3.016e-05
                2.664e-18  2.161e-19]
        cost: 0.009598884988101828
         jac: [[ 1.000e+00  5.000e+00 ...  3.600e+01  2.160e+02]
               [ 1.000e+00  5.000e+00 ...  2.500e+01  1.250e+02]
               ...
               [ 1.000e+00  5.000e+00 ...  6.400e+01  5.120e+02]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]]
        grad: [ 7.184e-03  2.091e-02  4.607e-02 -2.223e-10 -7.756e-12
                5.406e+00  1.011e+02]
  optimality: 2.2234891705608106e-10
 active_mask: [-1 -1 -1  0  0 -1 -1]
        nfev: 39
        njev: 39
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
