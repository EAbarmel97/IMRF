include("../src/IMRF.jl")
using .IMRF: plot_traces, plot_assembled_magnetization
using .IMRF: SIMULATIONS_DIR

function __plot(plot_ensamble_magnetization::Bool=false; ext=ext)
  println("plotting traces, wait ...\n")
  IMRF.plot_traces(; ext=ext)

  if plot_ensamble_magnetization
    ensamblated_magnetization_file_path = first(filter((u) -> endswith(u, "assembled_magnetization$(ext)"),
      readdir(abspath(IMRF.SIMULATIONS_DIR), join=true)))

    IMRF.plot_assembled_magnetization(ensamblated_magnetization_file_path, IMRF.GRAPHS_DIR_SIMULATIONS)
  end
end

function plot(ARGS)
  ext = ".txt"
  #ARG[1] = true includes the ensamblated magnetization
  arg = parse(Bool, ARGS[1])

  __plot(arg; ext=ext)
end

plot(ARGS)
