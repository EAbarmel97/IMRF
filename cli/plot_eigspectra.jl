include("../src/IMRF.jl")
using .IMRF: filter_dir_names_in_dir, plot_eigen_spectra
using .IMRF: SIMULATIONS_DIR

function plot(ARGS)
  println("plotting eigspectra, wait ...\n")
  #number of runs: ARGS[1]
  #string regexes: ARGS[2:5]
  arg1 = parse(Int64, ARGS[1])
  rgxs = Regex.(ARGS[2:end])
  temperature_dirs::Vector{String} = IMRF.filter_dir_names_in_dir(IMRF.SIMULATIONS_DIR, rgxs...)

  if isempty(temperature_dirs)
    @error "no dir in $(IMRF.SIMULATIONS_DIR) matched each of the $(length(temperature_dirs)) different searching criteria"
    return
  end

  IMRF.plot_eigen_spectra(arg1, temperature_dirs...)
end

plot(ARGS)
