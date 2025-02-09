# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..5)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 59809/59809 [02:49<00:00, 353.41it/s]

Compile time big-O: 
 + 7.63e-24*NumNodes^1
 + 1.90e-23*NumNodes^2
 + 1.35e-23*NumNodes^3
 + 5.68e-16*NumEdges^1
 + 3.93e-15*NumEdges^2

      message: Both `ftol` and `xtol` termination conditions are satisfied.
     success: True
      status: 4
         fun: [ 7.429e-04  2.059e-03 ...  4.078e-02  4.079e-02]
           x: [ 7.583e-02  7.631e-24  1.905e-23  1.349e-23  5.681e-16
                3.928e-15  3.423e-07]
        cost: 0.40020372191732184
         jac: [[ 1.000e+00  5.000e+00 ...  1.600e+01  6.400e+01]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]
               ...
               [ 1.000e+00  5.000e+00 ...  2.500e+01  1.250e+02]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]]
        grad: [ 3.558e-13  5.530e+00  4.967e+01  3.361e+02  5.958e+00
                2.998e+01 -6.341e-08]
  optimality: 6.341027291439927e-08
 active_mask: [ 0 -1 -1 -1 -1 -1  0]
        nfev: 31
        njev: 31

Solve time big-O: 
 + 1.82e-10*NumNodes^2
 + 5.75e-11*NumEdges^2
 + 2.34e-10*NumEdges^3

      message: `gtol` termination condition is satisfied.
     success: True
      status: 1
         fun: [-6.841e-04 -6.051e-04 ...  3.423e-04  3.949e-04]
           x: [ 8.075e-07  7.969e-07  1.817e-10  1.647e-06  2.631e-05
                5.748e-11  2.344e-10]
        cost: 0.007692012222431438
         jac: [[ 1.000e+00  5.000e+00 ...  1.600e+01  6.400e+01]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]
               ...
               [ 1.000e+00  5.000e+00 ...  2.500e+01  1.250e+02]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]]
        grad: [ 2.740e-03  8.479e-03  1.957e-02  7.597e-11  4.063e-12
                1.444e+00  2.862e+01]
  optimality: 6.756907081657159e-09
 active_mask: [ 0  0 -1  0  0 -1 -1]
        nfev: 34
        njev: 34
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
