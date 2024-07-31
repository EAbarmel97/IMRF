function swap!(val1::Int, val2::Int, obj::Union{Array{Float64,1},Array{Int,1}})
    temp = obj[val1]
    obj[val1] = obj[val2]
    obj[val2] = temp
    setindex!(obj, obj[val1], val1)
    setindex!(obj, obj[val2], val2)
end

#= Function to push fill in values in arithmetic progression on an array given the end points=#
function push_arith_progression!(Ti::Float64, Tf::Float64, delta::Float64, arr::AbstractArray)
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
        throw(ErrorException("Illegal choice. $Tf is not in arithmetic progression with respect~ to $Ti"))
    end  
end

function default_temperature_array()::Vector{Float64}
    default_array = Float64[0.0]
    push_arith_progression!(0.0,1.0,0.1,default_array)
    push_arith_progression!(1.0,2.2,0.1,default_array)
    push_arith_progression!(2.21,2.26,0.01,default_array)
    push!(default_array, CRITICAL_TEMP)
    push_arith_progression!(2.27,2.5,0.01,default_array)
    push_arith_progression!(2.6,3.5,0.01,default_array)

    return default_array
end

#= IO handling auxiliary functions =#
function count_runs_in_dir(simuls_dir::String, aux_dir_name::String)::Int64
    temp_abs_dir = joinpath(simuls_dir,aux_dir_name,"magnetization") #abs path to the simulations at a given temp 
    return length(readdir(temp_abs_dir)) #number of runs contained in a given simulations dir
end

const DEFAULT_TEMPERATURE_ARRAY = default_temperature_array()

function average_by_realization()
    
end
