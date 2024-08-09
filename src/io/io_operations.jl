@enum DIRS dir = 1 sub_dir = 2

function create_dir(dir_name::String, type_of_dict::DIRS, args...)::String
    dir_path::String = ""
    if type_of_dict === dir
        dir_path = string(dir_name, args...)
        return mkdir(dir_path)
    else
        dir_path = string(dir_name, args...)
        return mkpath(dir_path)    
    end
end

function create_file(file_name::String, args...)::String
    file_path = joinpath(file_name, args...)
    return touch(file_path)
end

function rfim_info(N_GRID,NUM_RUNS,NUM_GENERATIONS)
    io = create_file(joinpath(SIMULATIONS_DIR, "rfim_details.txt"))
    open(io, "w+") do io
        write(io, "details: ngrid:$N_GRID, nruns:$NUM_RUNS, ngens:$NUM_GENERATIONS")
    end
end

function filter_directory_names(dir_names::Vector{String}, rgx::Regex)::Vector{String}
    filtered_array = filter(str -> contains(str, rgx), dir_names)
    if isempty(filtered_array)
        throw(ErrorException("Impossible to graph the given array of temperatures!"))
    end
    
    return filtered_array
end

"""
    load_data_matrix(::Type{T}, file_path::String; drop_header=false, centralize::Bool=false)::Matrix{T} where {T <: Any}

Load data from a CSV file into a matrix of a specified type, with optional header removal and centralization.

# Arguments
- `::Type{T}`: The type of the elements in the resulting matrix.
- `file_path::String`: The path to the CSV file to load.
- `drop_header::Bool=false`: If `true`, the header row will be dropped. Default is `false`.
- `centralize::Bool=false`: If `true`, the data will be centralized by subtracting the mean of each column. Default is `false`.

# Returns
- `Matrix{T}`: A matrix containing the data from the CSV file, with the specified type `T`.
"""
function load_data_matrix(::Type{T}, file_path::String; drop_header=false, centralize::Bool=false)::Matrix{T} where {T <: Any}
    df = DataFrames.DataFrame(CSV.File(file_path; header=drop_header, delim=',', types = T))
    data = Matrix{T}(df)

    if centralize
        data .-= mean(data, dims=1)
    end

    return data
end

function write_to_csv(file_to_write::String, value::Any)
    if !isfile(file_to_write)
       @error "file $file_to_write does not exist"
    end 

    CSV.write(file_to_write, DataFrame(col1 = [value]); append = true, delim = ',')
    return
end

function write_to_csv(file_to_write::String, value::Vector{<:Any})
    if !isfile(file_to_write)
       @error "file $file_to_write does not exist"
    end 

    CSV.write(file_to_write, DataFrame(col1 = value); append = true, delim = ',')
    return
end

function write_rffts(num_runs::Int64)
    #check if ensamblated_magnetization csv exists
    if filter((u) -> endswith(u, ".csv"), readdir(abspath(SIMULATIONS_DIR), join=true)) |> length > 0
        All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
    else
        All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[3:end]
    end 
    
    All_MAGNETIZATION_DIRS = joinpath.(All_SIMULATIONS_DIRS, "magnetization")
    All_FOURIER_DIRS = joinpath.(All_SIMULATIONS_DIRS, "fourier")
    for i in eachindex(All_MAGNETIZATION_DIRS)
        for run in 1:num_runs
            global_magn_ts_path = joinpath(All_MAGNETIZATION_DIRS[i],"global_magnetization_r$run.csv" )
            rfft_path = create_file(joinpath(All_FOURIER_DIRS[i], "rfft_global_magnetization_r$run.csv"))
            rfft_magnetiaztion_ts = FFTW.rfft(global_magn_ts_path)
            write_rfft(rfft_magnetiaztion_ts, rfft_path)
        end
    end
end

function write_rfft(arr::Vector{ComplexF64}, file_path::String)
    write_to_csv(file_path, arr)
end

function write_csv_ensamblated_magnetization_by_temprature(write_to::String; statistic::Function = mean)
    #this gets an array of dirs with the structure: ../simulations/simulations_T_xy_abcdefg_/
    All_TEMPERATURES_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[3:end]
    All_MAGNETIZATION_DIRS = joinpath.(All_TEMPERATURES_DIRS, "magnetization")
    temperatures = Float64[]
    magnetizations = Float64[]

    for i in eachindex(All_MAGNETIZATION_DIRS)
        temperature = parse(Float64,
                           replace(
                           match(r"[0-9][0-9]_[0-9]+", 
                           All_MAGNETIZATION_DIRS[i]).match, 
                           "_" => ".")
                        )

       magnetization = sample_magnetization_by_run(All_TEMPERATURES_DIRS[i]; statistic = statistic)
       push!(magnetizations ,magnetization)
       push!(temperatures,temperature)
    end    
    
    ensamblated_magnetization_file_path = create_file(joinpath(write_to, "$(statistic)_ensamblated_magnetization.csv"))
    CSV.write(ensamblated_magnetization_file_path, DataFrame(t = temperatures, M_n = magnetizations); append= true, delim=',')
end

function __count_lines_in_csv(file_path::String)
    n::Int64 = 0
    for _ in CSV.Rows(file_path; header=false, reusebuffer=true)
        n += 1
    end

    return n
end