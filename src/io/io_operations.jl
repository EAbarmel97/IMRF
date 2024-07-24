@enum DIRS dir = 1 sub_dir = 2

struct RFFTConfig
    destination_dir::String
    at_temp::Float64
    run::Int64
end

function write_to_csv(file_to_write::String, value::Any)
    if !isfile(file_to_write)
       @error "file $file_to_write does not exist"
    end 

    CSV.write(file_to_write, DataFrame(col1 = [value]); append = true)
end 

#= Function to write over a .txt file a vector with the rfft of a signal(time series) =#
function write_rfft(arr::Vector{ComplexF64}, rfft_conf::RFFTConfig)
    if rfft_conf.at_temp != CRITICAL_TEMP    
        rounded_temp = round(rfft_conf.at_temp, digits=2)
        str_rounded_temp = replace("$rounded_temp","." => "_")
        file_name = "$destination_dir/rfft_global_magnetization_$(str_rounded_temp)_r$(rfft_conf.run).txt"
    else
        str_Tc_temp = replace("$(rfft_conf.at_temp)","$(CRITICAL_TEMP)" => "Tc",)
        file_name = "$destination_dir/rfft_global_magnetization_$(str_Tc_temp)_r$(rfft_conf.run).txt"
    end

    #if file doesn't exist 
    if !isfile(file_name)  
        touch(file_name)
        fourier_transform_file = open(file_name,"a+")
        for i in eachindex(arr)
            write(fourier_transform_file,"$(arr[i])\n")
            #for the last index
            if i == length(arr)
               write(fourier_transform_file,"$(arr[i])")
            end    
        end
        close(fourier_transform_file)    
    end
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
        write(
            io,
            "details: 
            ngrid:$N_GRID,
            nruns:$NUM_RUNS,
            ngens:$NUM_GENERATIONS")
    end
end


function filter_directory_names(dir_names::Vector{String}, rgx::Regex)::Vector{String}
    filtered_array = filter(str -> contains(str, rgx), dir_names)
    if isempty(filtered_array)
        throw(ErrorException("Impossible to graph the given array of temperatures!"))
    end
    
    return filtered_array
end