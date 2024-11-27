include("../src/IMRF.jl")
using .IMRF: do_simulations

function main(ARGS)
  println("simulating, wait ...\n")
  #ARG[1]: N_GRID
  #ARG[2]: SUBLATTICE_NGRID
  #ARG3[3]: NUM_RUNS
  #ARG3[4]: NUM_GENERATIONS
  args = parse.(Int64, ARGS[1:4])
  temperatures = Float64[0.5, 1.0, 1.5, 2.0, 2.1, 2.2, 2.26918531421302, 2.3, 2.4, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
  IMRF.do_partitioned_simulations(temperatures, args...)
end

main(ARGS)