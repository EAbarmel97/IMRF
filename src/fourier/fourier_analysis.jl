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

function psd(arr::Vector{ComplexF64})
    return abs2.(arr)
end

"""
    sampling_freq_arr(file_path::String)::Array{Float64,1}

Determines the array containing sampling frecuencies when an abs path is given as argument
"""
function FFTW.rfftfreq(file_path::String; fs::Int64=1, ext=".csv")::Vector{Float64}
    if !isdir(abspath(file_path))
       @error "file $file_path does not exist"
       return
    end

    magnetization_csv_file_path = readdir(joinpath((abspath(file_path)), "magnetization"), join=true) |> first 

    sampling_rfft_freq = rfftfreq(__count_lines_in_file(magnetization_csv_file_path; ext=ext),fs)
    freq_arr = convert(Vector{Float64},sampling_rfft_freq) 
    
    return freq_arr
end

function mean_psd_by_run(temperature_dir::String; ext=".csv")::Vector{Float64}
    #getting all the ../temperature_dir/fourier subdirs  
    RFFTS_CSVS_INSIDE_TEMPERATURE_DIR = readdir(abspath(joinpath(temperature_dir,"fourier")), join=true)
    
    size = __count_lines_in_file(RFFTS_CSVS_INSIDE_TEMPERATURE_DIR[1]; ext=ext)
    tmp_psd = zeros(Float64,size) 
    for i in eachindex(RFFTS_CSVS_INSIDE_TEMPERATURE_DIR)
        rfft_data_matrix  = load_data_matrix(ComplexF64, RFFTS_CSVS_INSIDE_TEMPERATURE_DIR[i]; drop_header=false)
        rfft_vector_data = vec(rfft_data_matrix)

        tmp_psd += psd(rfft_vector_data)/length(RFFTS_CSVS_INSIDE_TEMPERATURE_DIR) 
    end

    return tmp_psd
end

function linear_fit_log_psd(f::Vector{Float64}, average_psd::Vector{Float64})::Vector{Float64}
    log10_f = log10.(f)
    log10_mean_psd = log10.(average_psd)
    return intercept_exponent_r2(log10_f,log10_mean_psd)
end