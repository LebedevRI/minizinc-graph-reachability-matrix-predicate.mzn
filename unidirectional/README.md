# Correctness + perf

```
$ ./unreachable.test.py 
Generating tests (exhaustive, N=0..5)...
Running tests (exhaustive)...
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 59809/59809 [03:08<00:00, 317.17it/s]

Compile time big-O: 
 + 1.45e-09*NumNodes^2

      message: `ftol` termination condition is satisfied.
     success: True
      status: 2
         fun: [ 1.959e-04  5.031e-04 ...  4.564e-02  4.582e-02]
           x: [ 7.678e-02  8.283e-04  1.445e-09  2.500e-05  6.239e-05
                6.190e-07  5.268e-07]
        cost: 1.3283835734284513
         jac: [[ 1.000e+00  5.000e+00 ...  1.600e+01  6.400e+01]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]
               ...
               [ 1.000e+00  5.000e+00 ...  3.600e+01  2.160e+02]
               [ 1.000e+00  5.000e+00 ...  8.100e+01  7.290e+02]]
        grad: [ 4.422e-03  6.160e-03  7.440e-02  8.214e-01  2.858e-02
                1.925e+00  3.581e+01]
  optimality: 0.00033956186056589654
 active_mask: [ 0  0 -1  0  0  0  0]
        nfev: 30
        njev: 30

Solve time big-O: 
 + 3.21e-11 
 + 1.46e-10*NumNodes^1
 + 1.78e-13*NumNodes^2
 + 7.42e-23*NumEdges^2
 + 4.71e-21*NumEdges^3

      message: `gtol` termination condition is satisfied.
     success: True
      status: 1
         fun: [-4.780e-04  6.251e-04 ...  5.907e-04  6.938e-04]
           x: [ 3.208e-11  1.455e-10  1.778e-13  3.076e-06  3.436e-05
                7.423e-23  4.706e-21]
        cost: 0.00837812071353056
         jac: [[ 1.000e+00  5.000e+00 ...  1.600e+01  6.400e+01]
               [ 1.000e+00  5.000e+00 ...  4.900e+01  3.430e+02]
               ...
               [ 1.000e+00  5.000e+00 ...  3.600e+01  2.160e+02]
               [ 1.000e+00  5.000e+00 ...  8.100e+01  7.290e+02]]
        grad: [ 1.150e-02  3.412e-02  7.623e-02 -2.742e-09 -1.230e-11
                3.079e+00  6.002e+01]
  optimality: 2.7423485498504624e-09
 active_mask: [-1 -1 -1  0  0 -1 -1]
        nfev: 40
        njev: 40
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
