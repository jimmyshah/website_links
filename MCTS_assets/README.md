## Parallel Monte Carlo Tree Search

#### Abstract

We present two novel techniques for parallelizing Monte Carlo Tree Search. Our solutions use MPI to capitalize on the benefits of root parallelization, but go further in that they search more extensively promising move paths. Our first implementation, Top-K parallelization, performs two rounds of simulation. In the first round, Top-K parallelization runs MCTS for a
given number of exploratory rollouts on child processes and then more fully explores the top k moves in a second round, splitting work evenly among child processes. Smart-K parallelization uses a similar narrowing of search on promising moves, but delegates work to child processes by calculating a weight based on current move values and number of visits. Our experiments show negatives results for Top-K parallelization and promising results for Smart-K parallelization.



#### Notes
This was the final project for my Parallel and Distributed Computing course. The slides included were used for our final presentation, and the paper was submitted as the final report.
