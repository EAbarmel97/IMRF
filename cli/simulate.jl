include("../src/IMRF.jl")
using .IMRF: do_simulations

function main(ARGS)
  println("simulating, wait ...\n")
  #ARG[1]: N_GRID
  #ARG[2]: NUM_RUNS
  #ARG3[3]: NUM_GENERATIONS
  args = parse.(Int64, ARGS[1:3])
  IMRF.do_simulations(
    IMRF.DEFAULT_TEMPERATURE_ARRAY,
    args...;
    generate_rffts=true, #writes a csv per run (at each fixed temp) containing the rfft of magnetization
    write_csv_assembled_magnetization=true
  )
end

main(ARGS)
