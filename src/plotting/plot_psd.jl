"""
    plot_psd()

Generates and saves PSD plots for all simulation directories within the SIMULATIONS_DIR directory.
"""
function plot_psd()
    #check if ensamblated_magnetization csv exists
    if filter((u) -> endswith(u,".csv"), readdir(abspath(SIMULATIONS_DIR), join=true)) |> length > 0
        All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
    else
        All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[3:end]
    end 
    
    for i in eachindex(All_SIMULATIONS_DIRS)
        str_simulation_temp = match(r"simulations_T_[0-9][0-9]_[0-9]+", All_SIMULATIONS_DIRS[i]).match
        psd_plot_dir = create_dir(joinpath(PSD_GRAPHS_SIMULATIONS, str_simulation_temp), sub_dir)

        plot_mean_psd_by_run(All_SIMULATIONS_DIRS[i], psd_plot_dir)
    end
end

"""
    plot_mean_psd_by_run(temperature_dir::String, destination_dir::String)

Plots and saves the mean Power Spectral Density (PSD) for the given temperature directory.

# Arguments
- `temperature_dir`: Directory with temperature data and Fourier files.
- `destination_dir`: Directory to save the PSD plot.
"""
function plot_mean_psd_by_run(temperature_dir::String, destination_dir::String)
    if isempty(readdir(joinpath(abspath(temperature_dir), "fourier"), join=true))
       @error " impossible to plot PSD. There are no rfts under '$(temperature_dir)/fourier'"
       return
    end

    RFFTS_CSVS_INSIDE_TEMPERATURE_DIR = readdir(joinpath(abspath(temperature_dir), "fourier"), join=true)

    mean_psd_array = mean_psd_by_run(temperature_dir) 
    f = FFTW.rfftfreq(temperature_dir)

    f_without_DC = f[2:end]
    average_array_without_DC = mean_psd_array[2:end]

    params = linear_fit_log_psd(f_without_DC, average_array_without_DC)
    
    temperature = parse(temperature_dir)
    num_runs = RFFTS_CSVS_INSIDE_TEMPERATURE_DIR |> length
    
    plot_file_path = joinpath(destination_dir, "psd_$(match(r"T_[0-9][0-9]_[0-9]+",temperature_dir).match)_r_1_$(num_runs).pdf")

    if !isfile(plot_file_path)
        plt = plot(f_without_DC, average_array_without_DC, label=L"S \left( f \right)", xscale=:log10, yscale=:log10,lc=:red)
        #linear fit
        plot!((x) -> exp10(params[1] + params[2]*log10(x)), label=L"\hat{S} \left( f \right)",minimum(f_without_DC), maximum(f_without_DC), xscale=:log10, yscale=:log10, lc=:black)
        #
        title!("mean PSD by run, temp = $(round(temperature, digits=4))")
        xlabel!(L"f")
        ylabel!("power density spectrum")
        
        #file saving
        savefig(plt, plot_file_path)
    end        
end

