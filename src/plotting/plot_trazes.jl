"""
    plot_traze(file_path::String, run::Int64, save_to::String; statistic::Function = mean)

Plot the time series of magnetization data and save the plot as a PDF file.

# Arguments
- `file_path::String`: The path to the file containing the magnetization data matrix.
- `run::Int64`: The run number to be included in the output file name.
- `save_to::String`: The directory path where the output PDF file should be saved.
- `statistic::Function = mean`: A function to calculate a statistic on the magnetization data (default is `mean`).
"""
function plot_traze(file_path::String, run::Int64, save_to::String; statistic::Function = mean)
    magnetization_data = load_data_matrix(Float64, file_path::String; drop_header=false, centralize=false)
    ts = vec(magnetization_data)

    x = collect(0:(length(ts)-1))
    y = ts
    
    plt = plot(x, y, label= L"M_n") #plot reference 
    hline!(plt, [statistic(y), statistic(y)], label=L"\overline{M}_n",linewidth=3)
    ylims!(-1.0, 1.0)
    xlims!(0, length(ts))
    xlabel!(L"n")
    ylabel!(L"M_n")

    savefig(plt, joinpath(save_to, "global_magnetization_r$run.pdf")) 
end

"""
    plot_trazes(statistic::Function = mean)

Generate and save plots of magnetization time series for multiple simulation runs.

# Arguments
- `statistic::Function = mean`: A function to calculate a statistic on the magnetization data (default is `mean`).
"""
function plot_trazes(statistic::Function = mean)
    if filter(endswith(".csv"),readdir(abspath(SIMULATIONS_DIR), join=true)) |> length > 0
        All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
    else
        All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[3:end]
    end

    All_MAGNETIZATION_DIRS = joinpath.(All_SIMULATIONS_DIRS, "magnetization")
    for i in eachindex(All_MAGNETIZATION_DIRS)
        num_runs = length(readdir(All_MAGNETIZATION_DIRS[i]))

        str_simulation_temp = match(r"simulations_T_[0-9][0-9]_[0-9]+", All_MAGNETIZATION_DIRS[i]).match

        ts_plot_dir = create_dir(joinpath(GRAPHS_DIR_SIMULATIONS, str_simulation_temp), sub_dir)
        for run in 1:num_runs
            plot_traze(joinpath(All_MAGNETIZATION_DIRS[i],"global_magnetization_r$run.csv"),run,ts_plot_dir; statistic = statistic)
        end    
    end    
end

function plot_ensamblated_magnetization(emsamblated_magnetization_file_path::String, save_to::String)
    magnetization_data = load_data_matrix(Float64, emsamblated_magnetization_file_path::String; drop_header=false, centralize=false)
    
    if isfile(file_path)
        plt = plot(magnetization_data[1], magnetization_data[2], label = L"\overline{M}_n")
        ylims!(0.0, 1.0)
        xlims!(0,max(magnetization_data[1]))
        vline!(plt, [CRITICAL_TEMP, CRITICAL_TEMP], label=L"T_c", linewidth=1, fillalpha=0.02)
        xlabel!(L"T")
        ylabel!("spontaneus magnetization")
        savefig(plt,joinpath(save_to, "ensamblated_magnetization.pdf")) #saving plot reference as a file with pdf extension at a given directory 
    end
end