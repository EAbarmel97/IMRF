import FFTW

"""
   rrfft(file_path::AbstractString)::Vector{ComplexF64}

Function wrapper to the FFTW's rfft method. Takes a .csv file of numbers, parses it
an computes its rfft
"""
function FFTW.rfft(file_path::String)::Vector{ComplexF64}
    data_matrix = load_data_matrix(Float64, file_path; drop_header = false, centralize = false)
    ts = vec(data_matrix)
     
    return rfft(ts)
end

#= Function to compute the power spectral density =#
function psd(arr::Vector{ComplexF64})
    return abs2.(arr)
end

"""
    sampling_freq_arr(file_path::String)::Array{Float64,1}

Determines the array containing sampling frecuencies when an abs path is given as argument
"""
function FFTW.rfftfreq(file_path::String; fs::Int64=1)::Vector{Float64}
    open(file_path,"r") do io
        num_lines = countlines(io)
        sampling_freq_arr = rfftfreq(num_lines,fs)
        freq_arr = convert(Vector{Float64},sampling_freq_arr) 
        deleteat!(freq_arr,1)
    end 
    
    
    return freq_arr
end

function sampling_freq_arr(N::Int64)
    freq_arr = rfftfreq(N)
    freq_arr = convert.(Float64,freq_arr) 

    deleteat!(freq_arr,1)

    return freq_arr
end

""""
    mean_psd(psd_array::Array{Array{Float64,1},1})::Array{Float64,1}

returns the average psd when array of psd at different runs is given
"""
function mean_psd(psd_array::Array{Array{Float64,1},1})::Array{Float64,1}
    sum = zeros(length(first(psd_array)))
    for i in eachindex(psd_array)
        psd = psd_array[i]
        sum += psd    
    end

    return sum/length(psd_array)
end

"""
    psd_arr_by_run(temp_dir_name::String,simuls_dir::String)::Array{Array{Float64,1},1}

returns an array with the psd at each run.
"""
function psd_arr_by_run(temp_dir_name::String,simuls_dir::String)::Array{Array{Float64,1},1}
    rffts_at_temp = joinpath(simuls_dir,temp_dir_name,"fourier")
    psd_array = Array{Float64,1}[]
    for rfft_file_name in file_names_in_fourier_dir(temp_dir_name,simuls_dir)
        rfft_path = joinpath(rffts_at_temp,rfft_file_name)#abs path to the strigified file  for the rfft 

        #fetching and appending psd to the array containg the power spectra densities
        rfft = utilities.get_array_from_txt(Complex{Float64},rfft_path)
        #rfft of the M_n with initial temperature x_y_z
        rfft = rfft[2:end-1]#discarting the DC associated entry and the last element array 
        
        rfft = convert.(ComplexF64,rfft) #casting array to ComplexF64
        
        psd = compute_psd(rfft) #array with the psd associated with RFFT[M_n]
        push!(psd_array,psd)
    end
    
    return psd_array
end

"""
    create_graphs_temp_sub_dir(temp_name_dir::String,destination_dir::String)::Nothing

creates under /graphs/ the folder corresponding to a the simulations made a given temperature

Ex: /graphs/psd/T_1_34
"""
function create_graphs_temp_sub_dir(temp_name_dir::String,destination_dir::String)::Nothing
    dashed_str_temp = replace(temp_name_dir, "simulations_" => "")
    at_temp = joinpath(destination_dir,dashed_str_temp) # subdir ../graphs/automated/psd/T_x_y_z or ../graphs/psd/T_x_y_z
    mkpath(at_temp) #sub dir graphs/psd/T_x_y_z

    return nothing
end

"""
    psd_graph_file_path(temp_dir_name::String,destination_dir::String)::String

Builds the absolute path to the psd graph. Of all superimposed psd ar different runs

Ex: "graphs/automated/psd_T_0_32_r_1_10.pdf"
"""
function psd_graph_file_path(temp_dir_name::String,destination_dir::String)::String
    NUM_RUNS = num_runs(temp_dir_name, determine_simulation_dir(destination_dir))
    
    t_dashed_str_temp = replace(temp_dir_name,"simulations_" => "")
    at_temp = joinpath(destination_dir,t_dashed_str_temp)
    full_file_path = joinpath(at_temp,"psd_$(t_dashed_str_temp)_r1_$(NUM_RUNS).pdf")
    
    return full_file_path
end

"""
    intercept_and_exponent(x::Array{Float64,1},y::Array{Float64,1})::Array{Float64,1}

Returns an array with the parameter estimators for a linear fit
"""

function intercept_and_exponent(x::Array{Float64,1},y::Array{Float64,1})::Array{Float64,1}
    X = hcat(ones(length(x)),x)

    return inv(X'*X)*(X'*y)
end

"""
    intercept_and_exponent_from_log_psd(f::Array{Float64,1},average_psd::Array{Float64,1})::Array{Float64,1}

Gives a 2 dimensional array containing the parameter estimators of a 2d linear fit
"""
function intercept_and_exponent_from_log_psd(f::Array{Float64,1},average_psd::Array{Float64,1})::Array{Float64,1}
    log10_f = log10.(f)
    log10_mean_psd = log10.(average_psd)
    beta0, beta1 = intercept_and_exponent(log10_f,log10_mean_psd)

    return [beta0,beta1]
end

"""
    plot_psd(temp_name_dir::AbstractString,destination_dir::AbstractString)

Plots all psd in log-log superimposed on a same canvas, highlighting the mean psd in red, and the linear fit as well
"""
function plot_psd(temp_name_dir::AbstractString,destination_dir::AbstractString)
    simuls_dir = determine_simulation_dir(destination_dir)

    create_graphs_temp_sub_dir(temp_name_dir,destination_dir)

    psd_array = psd_arr_by_run(temp_name_dir,simuls_dir)
    average_psd = mean_psd(psd_array) #mean psd

    #string manipulations
    magn_dir_at_temp = joinpath(simuls_dir,temp_name_dir,"magnetization")
    #all magnetization time series files have the number of lines, so the first file is picked up
    magn_file_name = readdir(magn_dir_at_temp)[1]
    magn_ts_abs_path = joinpath(magn_dir_at_temp,magn_file_name)
    
    f = sampling_freq_arr(magn_ts_abs_path)
    params = intercept_and_exponent_from_log_psd(f,average_psd)

    full_file_path = psd_graph_file_path(temp_name_dir,destination_dir)

    if !isfile(full_file_path)
        #plot styling
        plt = plot(f, psd_array, label=L"PSD \ \left( f \right)", legend=false, xscale=:log10, yscale=:log10,alpha=0.2) #plot reference 
        #
        plot!(f, average_psd, label=L"PSD \ \left( f \right)", legend=false, xscale=:log10, yscale=:log10,lc=:red)
        #linear fit
        plot!((x) -> exp10(params[1] + params[2]*log10(x)),minimum(f),maximum(f),legend=false, xscale=:log10,yscale=:log10,lc=:black)
        
        str_temp = replace(temp_name_dir,"simulations_T_" => "", "_" => ".")
    
        title!("PSD for ts with init temp $(str_temp)")
        xlabel!(L"f")
        ylabel!("power density spectra")
        
        #file saving
        savefig(plt, full_file_path)
    end        
end
