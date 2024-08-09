function pad_vector(array::Vector{T}, co_dim::Int64)::Vector{T} where {T <: Real}
    return vcat(array,zeros(T,co_dim))
end

function ts_data_matrix(temperature_dir::String, number_of_realizations::Int)::Matrix{Float64}
    if isempty(readdir(joinpath(temperature_dir, "magnetization"),join=true))
        @error "fatal! $(temperature_dir) is empty or does not exist"
        return
    end 

    All_MAGNETIZATION_CSV_INSIDE_TEMPERATURE_DIR = readdir(joinpath(temperature_dir, "magnetization"),join=true)

    if number_of_realizations > length(All_MAGNETIZATION_CSV_INSIDE_TEMPERATURE_DIR)
        @error "impossible to choose the first $(number_of_realizations) of $(length(All_MAGNETIZATION_CSV_INSIDE_MAGN_DIR))"
        return
    end

    realizations = Vector{Float64}[]
    for i in 1:number_of_realizations
        magnetization = vec(load_data_matrix(Float64, All_MAGNETIZATION_CSV_INSIDE_TEMPERATURE_DIR[i]))
        push!(realizations, magnetization)
    end
    
    return M = hcat(corr_noises_arr...)' #build data matrix from different realizations
end

"""
   compute_linear_fit_params(eigvals::Array{Float64,1})::Arraty{Float64,1}

Returns the parameters of the linear fit of an eigenspectrum 
"""
function compute_linear_fit_params(eigvals::Array{Float64,1})::Array{Float64,1}
    return FourierAnalysis.intercept_and_exponent_from_log_psd(collect(Float64,1:length(eigvals)),eigvals)
end

function centralize_matrix(M::Matrix{Float64})::Matrix{Float64}
    mean_by_row = mean.(eachrow(M)) 
    return M .- mean_by_row
end

"""
   filter_singular_vals_array(atol::Float64,M::Matrix{Float64})

Returns an array of singular valuesfiltered by absulte tolerance
"""
function filter_singular_vals_array(M::Matrix{Float64};atol=eps(Float64)::Float64)
    prop_vals = svd(M).S  
    return filter(u -> u > atol, prop_vals)
end

function compute_eigvals(M::Matrix{Float64}; drop_first=true::Bool)::Array{Float64,1}
    if drop_first 
        return abs2.(filter_singular_vals_array(M))[2:end]
    end
    
    return abs2.(filter_singular_vals_array(M))
end