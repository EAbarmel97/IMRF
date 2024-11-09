include("../src/IMRF.jl")
using .IMRF: filter_dir_names_in_dir, plot_eigen_spectra
using .IMRF: SIMULATIONS_DIR

function plot(ARGS)
  println("plotting eigspectra, wait ...\n")
  #string regexes: ARGS[1:5]
  rgxs = Regex.(ARGS[1:end])
  temperature_dirs::Vector{String} = IMRF.filter_dir_names_in_dir(IMRF.SIMULATIONS_PARTITIONED_DIR, rgxs...)

  if isempty(temperature_dirs)
    @error "no dir in $(IMRF.SIMULATIONS_DIR) matched each of the $(length(temperature_dirs)) different searching criteria"
    return
  end

  IMRF.plot_partitioned_eigen_spectra(temperature_dirs...)
end

plot(ARGS)