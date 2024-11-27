include("../src/IMRF.jl")
using .IMRF: filter_dir_names_in_dir, plot_eigen_spectra
using .IMRF: SIMULATIONS_DIR

function plot(ARGS)
  println("plotting eigspectra, wait ...\n")
  #transient_length:ARG
  #string regexes: ARGS[2:end]
  arg = parse(Int64, ARGS[1])
  rgxs = Regex.(ARGS[2:end])
  temperature_dirs::Vector{String} = IMRF.filter_dir_names_in_dir(IMRF.SIMULATIONS_PARTITIONED_DIR, rgxs...)
  if isempty(temperature_dirs)
    @error "no dir in $(IMRF.SIMULATIONS_PARTITIONED_DIR) matched each of the $(length(temperature_dirs)) different searching criteria"
    return
  end
  
  IMRF.plot_partitioned_eigen_spectra(arg, temperature_dirs... ;persist_eigspectra=true)
end

plot(ARGS)