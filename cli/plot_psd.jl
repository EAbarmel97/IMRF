include("../src/RFIM.jl")
using .RFIM: plot_psd

function plot()
    println("plotting psd, wait ...\n")
    RFIM.plot_psd()
end

plot()