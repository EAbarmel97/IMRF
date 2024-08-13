# About this repo:
Julia implementation of the 2D Random Field Ising Model. 

# To use it without the REPL
 1. Clone the repo.

 2. Instantiante the julia-project running `make instantiante`.

 3. Given `NGRID`: size of the spin lattice, `NUM_RUNS`: number of runs and `NUM_GENS`: number of generations. Run `make simulate ARGS="NGRID NUM_RUNS NUM_GENS"`. 
 
 4. Run `make plot_trazes ARG="x"`. With x being true of false. If "true" the plot of the ensambled magnetization is saved under graphs/simulations

 5. Run `make plot_psd` to save all the average PSD by run at each fixed temperature.

 6. Given `r`: number of realization and an array of patterns (suppose those are `pattern1, pattern2, pattern3`). Run `make plot_eigspectra ARGS="r pattern1 pattern2 pattern3"`

 7. To clean the "workspace" run `make cleanup_simulations && make cleanup_graphs`.

