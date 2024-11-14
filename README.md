# About this repo:
parallel Julia implementation of the 2D Ising Model. 

# To use it without the REPL
 1. Clone the repo.

 2. Instantiante the julia-project running `make instantiante`.

# 2D Ising Model

 1. Given `NGRID`: size of the spin lattice, `NUM_RUNS`: number of runs and `NUM_GENS`: number of generations and `NTHREADS`: the number of threads. Run `make simulate ngrid=NGRID runs=NUM_RUNS gens=NUM_GENS nthreads=NTHREADS`.
 
 2. Run `make plot_traces assembled_magn=true`. If "true" the plot of the assembled magnetization is saved under graphs/simulations

 3. Run `make plot_psd` to save all the average PSD by run at each fixed temperature.

 4. Given `r`: number of realization and an array of patterns (suppose those are `pattern1, pattern2, pattern3`). Run `make plot_eigspectra realizations=r patterns="pattern1 pattern2 pattern3"`

 5. To clean the "workspace" run `make cleanup`. This will delete all the simulations info and graphs persisted under the dirs 
 "simulations" and graphs". If instead you want to just delete all the persisted simulations, run:`make cleanup_simulations` else
 if you want to delete the plots saved in the "graphs" dir run `make cleanup_graphs`.

 # Partitioned Ising Model

 1. Given `NGRID`: size of the spin lattice, `SUBLATTICE_NGRID`:size of the sublattices, `NUM_RUNS`: number of runs (realizations), `NUM_GENS`: number of generations and `NTHREADS`: the number of threads. Run `make simulate_partitioned ngrid=NGRID sublattice_ngrid=SUBLATTICE_NGRID runs=NUM_RUNS gens=NUM_GENS nthreads=NTHREADS`.
Make sure the value of `sublattice_grid` divides `ngrid` otherwise an error will be thrown. 
 
 2. Given an array of patterns (suppose those are `pattern1, pattern2, pattern3`). Run `make plot_eigspectra_partitioned patterns="pattern1 pattern2 pattern3"`

 3. To clean the "workspace" run `make cleanup_partitioned`. This will delete all the simulations info and graphs persisted under the dirs 
 "simulations" and graphs". If instead you want to just delete all the persisted simulations, run:`make cleanup_simulations_partitioned` else
 if you want to delete the plots saved in the "graphs" dir run `make cleanup_graphs_partitoned`.