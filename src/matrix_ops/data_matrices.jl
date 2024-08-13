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

"""
   ts_data_matrix(temperature_dir::String, number_of_realizations::Int; centralize=true) -> Matrix{Float64}

Creates a data matrix from the first `number_of_realizations` magnetization CSV files in `temperature_dir`.

# Arguments
- `temperature_dir::String`: Path to the directory containing magnetization CSV files.
- `number_of_realizations::Int`: Number of realizations to include in the matrix.
- `centralize::Bool`: Whether to centralize the data (default: true).

# Errors
- Throws an error if `temperature_dir` is empty or if `number_of_realizations` exceeds the available files.
"""
function ts_data_matrix(temperature_dir::String, number_of_realizations::Int; centralize=true)::Matrix{Float64}
    if isempty(readdir(joinpath(temperature_dir, "magnetization"),join=true))
        @error "fatal! $(temperature_dir) is empty or does not exist"
        return
    end 

    All_MAGNETIZATION_CSV_INSIDE_TEMPERATURE_DIR = readdir(joinpath(abspath(temperature_dir), "magnetization"),join=true)

    if number_of_realizations > length(All_MAGNETIZATION_CSV_INSIDE_TEMPERATURE_DIR)
        @error "impossible to choose the first $(number_of_realizations) of $(length(All_MAGNETIZATION_CSV_INSIDE_MAGN_DIR))"
        return
    end

    realizations = Vector{Float64}[]
    for i in 1:number_of_realizations
        magnetization = vec(load_data_matrix(Float64, All_MAGNETIZATION_CSV_INSIDE_TEMPERATURE_DIR[i]; centralize = centralize))
        push!(realizations, magnetization)
    end
    
    return M = hcat(realizations...)' #build data matrix from different realizations
end