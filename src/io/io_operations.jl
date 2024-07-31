@enum DIRS dir = 1 sub_dir = 2

function load_data_matrix(::Type{T}, file_path::String; drop_header=false, centralize::Bool=false)::Matrix{T} where {T <: Any}
    df = DataFrames.DataFrame(CSV.File(file_path; header=drop_header))
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

    CSV.write(file_to_write, DataFrame(col1 = [value]); append = true)
    return
end

function write_to_csv(file_to_write::String, value::Vector{<:Any})
    if !isfile(file_to_write)
       @error "file $file_to_write does not exist"
    end 

    CSV.write(file_to_write, DataFrame(col1 = value); append = true)
    return
end

function write_rffts(num_runs::Int64)
    #first two join abs path do not exist nor contain magnetization ts simulations
    All_MAGNETIZATION_DIRS = joinpath.(readdir(abspath(SIMULATIONS_DIR), join=true),"magnetization")[3:end]
    All_FOURIER_DIRS = joinpath.(readdir(abspath(SIMULATIONS_DIR), join=true),"fourier")[3:end]
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