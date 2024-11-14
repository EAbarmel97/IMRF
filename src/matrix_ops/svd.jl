function pad_vector(array::Vector{T}, co_dim::Int64)::Vector{T} where {T <: Real}
    return vcat(array,zeros(T,co_dim))
end

function centralize_matrix(M::Matrix{Float64})::Matrix{Float64}
    mean_by_row = mean.(eachrow(M)) 
    return M .- mean_by_row
end

function filter_singular_values(singularvals::Vector{Float64};atol=eps(Float64))::Vector{Float64}
    return filter(u -> u > atol, singularvals)
end

function compute_filtered_eigvals!(M::Matrix{Float64}; drop_first::Bool = false, atol::Float64 = eps(Float64))::Vector{Float64}
    singularvals = svd(M).S  

    if drop_first 
        return abs2.(filter_singular_values(singularvals; atol = atol))[2:end]
    end
    
    return abs2.(filter_singular_values(singularvals; atol = atol))
end

function linear_fit_log_eigspectrum(eigspectrum::Vector{Float64})::Vector{Float64}
    log10_rank = log10.(collect(Float64, 1:length(eigspectrum)))
    log10_eigspectrum = log10.(eigspectrum)
    beta0, beta1 = intercept_and_exponent(log10_rank, log10_eigspectrum)

    return [beta0, beta1]
end

function linear_fit_log_eigspectrum_r2(eigspectrum::Vector{Float64})::Vector{Float64}
    log10_rank = log10.(collect(Float64, 1:length(eigspectrum)))
    log10_eigspectrum = log10.(eigspectrum)
    beta0, beta1,r2  = intercept_exponent_r2(log10_rank, log10_eigspectrum)
    
    return [beta0, beta1, r2]
end