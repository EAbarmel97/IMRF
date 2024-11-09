include("../src/IMRF.jl")
using .IMRF: do_simulations

function main(ARGS)
  println("simulating, wait ...\n")
  #ARG[1]: N_GRID
  #ARG[2]: SUBLATTICE_NGRID
  #ARG3[3]: NUM_RUNS
  #ARG3[4]: NUM_GENERATIONS
  args = parse.(Int64, ARGS[1:4])
  IMRF.do_partitioned_simulations(IMRF.DEFAULT_TEMPERATURE_ARRAY,args...)
end

main(ARGS)