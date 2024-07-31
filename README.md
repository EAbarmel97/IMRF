# About this repo:
Julia implementation of the 2D Random Field Ising Model. 

# To use it without the REPL
 1. clone the repo
 2. Instantiante the julia-project running `make instantiante`
 3. Given `NGRID`: size of the spin lattice, `NUM_RUNS`: number of runs and `NUM_GENS`: number of generations, run `make simulate ARGS="NGRID NUM_RUNS NUM_GENS"`. 
 4. run `make plot_trazes ARG="x"`. With x being true of false. If "true" is given the plot
 of the ensambled magnetization is plotted and saved under graphs/simulations