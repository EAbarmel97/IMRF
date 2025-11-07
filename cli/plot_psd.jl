include("../src/IMRF.jl")
using .IMRF: plot_psd

function plot()
  println("plotting psd, wait ...\n")
  IMRF.plot_psd(;ext=".txt")
end

plot()
