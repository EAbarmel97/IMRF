include("../src/RFIM.jl")
using .RFIM: do_simulations

function plot(include_ensamble_magnetization::Bool=false)
    RFIM.plot_trazes()

    if include_ensamble_magnetization
       #plot_ensamblated_magnetization()
       println("here goes the ensamblated magnetization")
    end
end

function plot_trazes(ARGS)
    #ARG[1] = true includes the ensamblated magnetization
    arg1 = parse(Bool, ARGS[1])

    plot(arg1)
end

plot_trazes(ARGS)