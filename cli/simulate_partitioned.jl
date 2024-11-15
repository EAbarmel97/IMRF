include("../src/IMRF.jl")
using .IMRF: do_simulations

function main(ARGS)
  println("simulating, wait ...\n")
  #ARG[1]: N_GRID
  #ARG[2]: SUBLATTICE_NGRID
  #ARG3[3]: NUM_RUNS
  #ARG3[4]: NUM_GENERATIONS
  args = parse.(Int64, ARGS[1:4])
  temperatures = Float64[0.5, 1.8, 2.26, 2.26918531421302, 2.31, 3.29]
  IMRF.do_partitioned_simulations(temperatures, args...)
end

main(ARGS)