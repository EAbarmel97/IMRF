include("../src/RFIM.jl")
using .RFIM: filter_dir_names_in_dir, plot_eigen_spectra
using.RFIM: SIMULATIONS_DIR

function plot(ARGS)
    println("plotting eigspectra, wait ...\n")
    #number of runs: ARGS[1]
    #string regexes: ARGS[2:5]
    arg1 = parse(Int64,ARGS[1])
    rgxs = Regex.(ARGS[2:end])
    temperature_dirs::Vector{String} = RFIM.filter_dir_names_in_dir(RFIM.SIMULATIONS_DIR, rgxs...)
    
    if isempty(temperature_dirs)
        @error "no dir in $(RFIM.SIMULATIONS_DIR) matched each of the $(length(temperature_dirs)) different searching criteria"
        return
    end

    RFIM.plot_eigen_spectra(arg1, temperature_dirs...)
end

plot(ARGS)