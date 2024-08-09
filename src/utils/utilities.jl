function swap!(val1::Int, val2::Int, obj::Union{Array{Float64,1},Array{Int,1}})
    temp = obj[val1]
    obj[val1] = obj[val2]
    obj[val2] = temp
    setindex!(obj, obj[val1], val1)
    setindex!(obj, obj[val2], val2)
end

"""
    format_str_float(f::Float64, decimal_places::Int64)::String

Format a floating-point number as a string with specified decimal precision.

# Arguments
- `f::Float64`: The floating-point number to format.
- `decimal_places::Int64`: The number of decimal places to include in the formatted string.

# Returns
- `String`: A formatted string representing the floating-point number, with the integer and decimal parts separated by an underscore.
"""
function __format_str_float(f::Float64,decimal_places::Int64)::String
    integer_part = floor(Int, f)
    decimal_part = floor(Int, (f - integer_part) * 10^decimal_places)

    return @sprintf("%02d_%d", integer_part, decimal_part)
end

function Base.parse(str::String)::Float64
    if !contains(str, r"[0-9][0-9]_[0-9]+")
       @error "error ocurred while parsing $(str)"
    end 

    return parse(Float64,replace(match(r"[0-9][0-9]_[0-9]+", str).match, "_" => "."))
end

#= Function to push fill in values in arithmetic progression on an array given the end points=#
function __push_arith_progression!(Ti::Float64, Tf::Float64, delta::Float64, arr::AbstractArray)
    val = cld(Tf-Ti,delta)
    umbral = round(abs(Tf - (Ti + val*delta)), digits=2)
    #= If the umbral lies in the interval (0,0.1], then Tf is taken to be in arithmetic 
       progression with Ti =#
    if umbral <= 0.1 
        for i in 1:val
            new_val = Ti + i*delta
            push!(arr,new_val) 
        end  
    else
        throw(ErrorException("Ilegal choice. $Tf is not in arithmetic progression with respect~ to $Ti"))
    end  
end

function default_temperature_array()::Vector{Float64}
    default_array = Float64[0.0]
    __push_arith_progression!(0.0,1.0,0.1,default_array)
    __push_arith_progression!(1.0,2.2,0.1,default_array)
    __push_arith_progression!(2.21,2.26,0.01,default_array)
    push!(default_array, CRITICAL_TEMP)
    __push_arith_progression!(2.27,2.5,0.01,default_array)
    __push_arith_progression!(2.6,3.5,0.01,default_array)

    return default_array
end

const DEFAULT_TEMPERATURE_ARRAY = default_temperature_array()

"""
    sample_magnetization_by_run(temperature_dir::String; statistic::Function = mean)::Float64

Calculate a statistical measure of magnetization from data files in a given directory.

# Arguments
- `temperature_dir::String`: The directory containing magnetization data files for different runs.
- `statistic::Function`: A function to apply to the collected magnetization data across all runs. Default is `mean`.

# Returns
- `Float64`: The computed statistic of the magnetization data across all runs.
"""
function sample_magnetization_by_run(temperature_dir::String; statistic::Function = mean)::Float64
    if !isdir(temperature_dir)
        @error "dir $(temperature_dir) does not exits!"
    end

    magnetization_per_run = Float64[]
    for run in eachindex(readdir(temperature_dir))
        magnetization_data = load_data_matrix(Float64, 
                                    joinpath(temperature_dir, 
                                    "magnetization",
                                    "global_magnetization_r$run.csv"); 
                                    drop_header=false, 
                                    centralize=false)

        ts = vec(magnetization_data)

        push!(magnetization_per_run, mean(ts))
    end
    
    return statistic(magnetization_per_run)
end

function intercept_and_exponent(x::Vector{Float64}, y::Vector{Float64})::Vector{Float64}
    data = DataFrame(X=x,Y=y)
    return GLM.coef(GLM.lm(@formula(Y ~ X), data))
end
