include("../src/RFIM.jl")
using .RFIM: plot_trazes, plot_ensamblated_magnetization

function __plot(plot_ensamble_magnetization::Bool=false)
    RFIM.plot_trazes()

    if plot_ensamble_magnetization
       ensamblated_magnetization_file_path = first(filter(endswith("ensamblated_magnetization.csv"), readdir(abspath(RFIM.SIMULATIONS_DIR), join=true)))

       RFIM.plot_ensamblated_magnetization(ensamblated_magnetization_file_path, RFIM.GRAPHS_DIR_SIMULATIONS)
    end
end

function plot(ARGS)
    #ARG[1] = true includes the ensamblated magnetization
    arg = parse(Bool, ARGS[1])

    __plot(arg)
end

plot(ARGS)