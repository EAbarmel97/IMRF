"""
    plot_traze(file_path::String, run::Int64, save_to::String; statistic::Function = mean)

Plot the time series of magnetization data and save the plot as a PDF file.

# Arguments
- `file_path::String`: The path to the file containing the magnetization data matrix.
- `run::Int64`: The run number to be included in the output file name.
- `save_to::String`: The directory path where the output PDF file should be saved.
- `statistic::Function = mean`: A function to calculate a statistic on the magnetization data (default is `mean`).
"""
function plot_traze(file_path::String, run::Int64, save_to::String,statistic::Function = mean)
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
    All_MAGNETIZATION_DIRS = joinpath.(readdir(abspath(SIMULATIONS_DIR), join=true),"magnetization")[3:end]
    for i in eachindex(All_MAGNETIZATION_DIRS)
        num_runs = length(readdir(All_MAGNETIZATION_DIRS[i]))

        str_simulation_temp = match(r"simulations_T_[0-9]_[0-9]+", All_MAGNETIZATION_DIRS[i]).match

        ts_plot_dir = create_dir(joinpath(GRAPHS_DIR_SIMULATIONS, str_simulation_temp), sub_dir)
        for run in 1:num_runs
            plot_traze(joinpath(All_MAGNETIZATION_DIRS[i],"global_magnetization_r$run.csv"),run,ts_plot_dir,statistic)
        end    
    end    
end

"""
    calculate_median_magnetization(temp_abs_dir::String, num_runs::Int64)::Float64

Calculate median magnetization
"""
function calculate_median_magnetization(temp_abs_dir::String, num_runs::Int64)::Float64
    magnetization_per_run = Float64[]
    
    for run in 1:num_runs
        aux_dir = joinpath(temp_abs_dir, "global_magnetization_r$run.csv")
        abs_mean_val = abs(utilities.median_value(aux_dir))
        push!(magnetization_per_run, abs_mean_val)
    end
    
    return median(magnetization_per_run)
end

# Function 5: Save Graphs
function save_graphs(temp_abs_dir::String, aux_dir_name::String, run::Int64, at_temp::String)
    aux_graph_file_name = replace(aux_dir_name, "simulations_T_" => "magnetization_ts_")
    aux_graph_file_name *= "_r$run.pdf"

    if contains(temp_abs_dir, "automated")
        aux_graph_full_name = joinpath(AUTOMATED_GRAPHS_DIR_SIMULS, at_temp, aux_graph_file_name)
    else
        aux_graph_full_name = joinpath(GRAPHS_DIR_SIMULS, at_temp, aux_graph_file_name)
    end

    if isfile(joinpath(temp_abs_dir, "global_magnetization_r$run.txt"))
        save_traze(aux_graph_full_name, joinpath(temp_abs_dir, "global_magnetization_r$run.txt"))
    end
end

"""
    add_temperature_median_magn_to_dict!(aux_dir_name::String,temperatures_median_magn::Dict{Float64,String},simuls_dir::String)::Nothing

Adds to a dict storing temp-stringified median magnetization
"""
function add_temperature_median_magn_to_dict!(aux_dir_name::String,temperatures_median_magn::Dict{Float64,String},simuls_dir::String)::Nothing
    num_runs = count_runs_in_dir(simuls_dir,aux_dir_name)
    aux_temp = replace(aux_dir_name, "simulations_T_" => "", "_" => ".")
    temp = utilities.parse_int_float64(Float64, aux_temp)
    
    temp_abs_dir = joinpath(simuls_dir,aux_dir_name,"magnetization")
    median_per_temp = calculate_median_magnetization(temp_abs_dir, num_runs)
    temperatures_median_magn[temp] = "$median_per_temp"

    return nothing
end

"""
    write_header(file_name::String,simuls_dir::String)::Nothing

Depending on whether simulations are generated interactively or not, the headers of the file 
are written over such file containing the custom csv (as a .txt) 
"""
function write_header(file_name::String,simuls_dir::String)::Nothing
    open(file_name,"w+") do io
        if contains(simuls_dir,"automated")
            write(io,"temp,median_magn_automated\n") 
        else
            write(io,"temp,median_magn\n") 
        end 
    end
    
    return nothing
end

function graph_and_write_over_file!(dir_names::AbstractArray, simuls_dir::AbstractString, file_to_write::AbstractString)
    rgx_arr = [r"T_0_\d{1,2}",r"T_1_\d{1,2}",r"T_2_\d{1,}",r"T_3_\d{1,2}"]

    write_header(file_to_write,simuls_dir)
    
    for rgx in rgx_arr
        #graph_and_write_over_file!(dir_names, simuls_dir, file_to_write, rgx)
    end    
end

"""
    plot_sample_magnetization(file_path::String, save_to::String)
    
Plot csv file containing sample magnetization at its corresponding temperature 
"""
function plot_sample_magnetization(file_path::String; save_to="."::String)

    #[temps, sample_magnetization] = CSV.read(file_path, CSV.Tables.matrix;delim=',' , header=false)

    if isfile(file_path)
        plt = plot(temps, median_magns, label = L"\overline{M}_n")
        ylims!(0.0, 1.0)
        xlims!(0,3.5)
        vline!(plt, [CRITICAL_TEMP, CRITICAL_TEMP], label=L"T_c", linewidth=1, fillalpha=0.02)
        xlabel!(L"T")
        ylabel!("sample magnetization")
        savefig(plt, save_to) #saving plot reference as a file with pdf extension at a given directory 
    end   
end