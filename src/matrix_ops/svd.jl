function pad_vector(array::Vector{T}, co_dim::Int64)::Vector{T} where {T <: Real}
    return vcat(array,zeros(T,co_dim))
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
    
    return M = hcat(corr_noises_arr...)' #build data matrix from different realizations
end

function centralize_matrix(M::Matrix{Float64})::Matrix{Float64}
    mean_by_row = mean.(eachrow(M)) 
    return M .- mean_by_row
end

"""
   filter_singular_vals_array(atol::Float64,M::Matrix{Float64})

Returns an array of singular valuesfiltered by absulte tolerance
"""
function filter_singular_values(singularvals::Vector{Float64};atol=eps(Float64))::Float64
    return filter(u -> u > atol, singularvals)
end

function compute_filtered_eigvals!(M::Matrix{Float64}; drop_first::Bool = true, atol::Float64 = eps(Float64))::Vector{Float64}
    singularvals = svd(M).S  

    if drop_first 
        return abs2.(filter_singular_values(singularvals; atol = atol))[2:end]
    end
    
    return abs2.(filter_singular_vals_array(singularvals; atol = atol))
end

function linear_fit_log_eigspectrum(eigspectrum::Vector{Float64})::Vector{Float64}
    log10_rank = log10.(collect(Float64, 1:length(eigspectrum)))
    log10_eigspectrum = log10.(eigspectrum)
    beta0, beta1 = intercept_and_exponent(log10_rank, log10_eigspectrum)

    return [beta0, beta1]
end