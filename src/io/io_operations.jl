@enum DIRS dir = 1 sub_dir = 2

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

function imrf_info(N_GRID, NUM_RUNS, NUM_GENERATIONS)
  io = create_file(joinpath(SIMULATIONS_DIR, "imrf_details.txt"))
  open(io, "w+") do io
    write(io, "details: ngrid:$N_GRID, nruns:$NUM_RUNS, ngens:$NUM_GENERATIONS")
  end
end

function imrf_partitioned_info(N_GRID, SUBLATTICE_NGRID, NUM_RUNS, NUM_GENERATIONS)
  io = create_file(joinpath(SIMULATIONS_PARTITIONED_DIR, "imrf_partitioned_details.txt"))
  open(io, "w+") do io
    write(io, "details: ngrid:$N_GRID, sublattice_ngrid:$SUBLATTICE_NGRID ,nruns:$NUM_RUNS, ngens:$NUM_GENERATIONS")
  end
end

function simulations_dir(dir::String; ext=".csv")::Vector{String}
  All_SIMULATIONS_DIRS = String[]
  if isequal(abspath(dir), SIMULATIONS_DIR)
    if filter((u) -> endswith(u, ext), readdir(abspath(RFIM.SIMULATIONS_DIR), join=true)) |> length > 0
      All_SIMULATIONS_DIRS = readdir(abspath(RFIM.SIMULATIONS_DIR), join=true)[4:end]
    else
      All_SIMULATIONS_DIRS = readdir(abspath(RFIM.SIMULATIONS_DIR), join=true)[3:end]
    end

    return All_SIMULATIONS_DIRS
  else
    return dir
  end
end

"""
    filter_dir_names_in_dir(dir::String, rgxs::Vararg{Regex})::Vector{String}

Filters and returns a vector of directory names in the specified directory (`dir`) that match any of the given regular expressions (`rgxs`).

# Arguments
- `dir::String`: The path to the directory to search in.
- `rgxs::Vararg{Regex}`: One or more regular expressions to match directory names against.

# Returns
- `Vector{String}`: A vector of directory names that match any of the provided regular expressions.

# Notes
- If `dir` is equal to `SIMULATIONS_DIR`, it first filters out directories containing `.csv` files, and then excludes the first few entries in the list.
- Issues a warning if no directories match a given regular expression.
"""
function filter_dir_names_in_dir(dir::String, rgxs::Vararg{Regex})::Vector{String}
  dir_paths_array = String[]
  dirs_to_search_in = String[]

  if isequal(abspath(dir), SIMULATIONS_DIR)
    if filter((u) -> endswith(u, ".csv"), readdir(abspath(SIMULATIONS_DIR), join=true)) |> length > 0
      dirs_to_search_in = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
    else
      dirs_to_search_in = readdir(abspath(SIMULATIONS_DIR), join=true)[3:end]
    end
  else
    dirs_to_search_in = readdir(abspath(dir), join=true)
  end

  for rgx in rgxs
    dir_paths = filter(dir_name -> contains(dir_name, rgx), dirs_to_search_in)
    if isempty(dir_paths)
      @warn "there is no sub dir in $(dir) matching '$(rgx)'"
    else
      first_match = dir_paths |> first
      push!(dir_paths_array, first_match)
    end
  end

  return dir_paths_array
end

function write_to_csv(file_to_write::String, value::Any)
  if !isfile(file_to_write)
    @error "file $file_to_write does not exist"
  end
  
  open(file_to_write, "a+") do io
    seekend(io)
    fz = filesize(file_to_write)
    if fz > 0
      seek(io,fz-1)
      lastbyte = read(io, UInt8)
      if lastbyte != UInt8('\n')
        write(io, "\n")
      end
    end
  end

  CSV.write(file_to_write, DataFrame(col1=[value]); append=true, delim=',')
  return
end

function write_to_txt(stream::IOStream, value::Any)
  write(stream, string(value) * "\n")
  return
end

function write_to_csv(file_to_write::String, value::Vector{<:Any})
  if !isfile(file_to_write)
    @error "file $file_to_write does not exist"
  end

  CSV.write(file_to_write, DataFrame(col1=value); append=true, delim=',')
  return
end

function write_to_txt(stream::IOStream, value::Vector{<:Any})
  for v in value
    write_to_txt(stream, v)
  end
  return
end

function write_rffts(num_runs::Int64; ext=".csv")
  if ext != ".csv" && ext != ".txt"
    @error "unsupported file extension $ext"
    return
  end

  #check if assembled_magnetization file exists
  if filter((u) -> endswith(u, ext), readdir(abspath(SIMULATIONS_DIR), join=true)) |> length > 0
    All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[5:end]
  else
    All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
  end

  All_MAGNETIZATION_DIRS = joinpath.(All_SIMULATIONS_DIRS, "magnetization")
  All_FOURIER_DIRS = joinpath.(All_SIMULATIONS_DIRS, "fourier")
  for i in eachindex(All_MAGNETIZATION_DIRS)
    for run in 1:num_runs
      global_magn_ts_path = joinpath(All_MAGNETIZATION_DIRS[i], "global_magnetization_r$(lpad(run,3,'0'))$(ext)")
      rfft_path = create_file(joinpath(All_FOURIER_DIRS[i], "rfft_global_magnetization_r$(lpad(run,3,'0'))$(ext)"))
      if isfile(rfft_path)
        rfft_magnetiaztion_ts = FFTW.rfft(global_magn_ts_path)
        write_rfft(rfft_magnetiaztion_ts, rfft_path; ext=ext)
      end
    end
  end
end

function write_rfft(arr::Vector{ComplexF64}, file_path::String; ext=".csv")
  if ext == ".csv"
    write_to_csv(file_path, arr)
  elseif ext == ".txt"
    io = open(file_path, "w+")
    write_to_txt(io, arr)
    close(io)
  else
    @error "unsupported file extension $ext"
  end
end

function write_file_assembled_magnetization_by_temprature(write_to::String; statistic::Function=mean, ext=".csv")
  #this gets an array of dirs with the structure: ../simulations/simulations_T_xy_abcdefg_/
  All_TEMPERATURES_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
  All_MAGNETIZATION_DIRS = joinpath.(All_TEMPERATURES_DIRS, "magnetization")
  temperatures = Float64[]
  magnetizations = Float64[]

  for i in eachindex(All_MAGNETIZATION_DIRS)
    temperature = parse(Float64,
      replace(
        match(r"[0-9][0-9]_[0-9]+",
          All_MAGNETIZATION_DIRS[i]).match,
        "_" => ".")
    )
    
    magnetization = sample_magnetization_by_run(All_TEMPERATURES_DIRS[i]; statistic=statistic, ext=ext)
    push!(magnetizations, magnetization)
    push!(temperatures, temperature)
  end
 
  assembled_magnetization_file_path = create_file(joinpath(write_to, "$(statistic)_assembled_magnetization$(ext)"))
  if ext == ".csv"
    CSV.write(assembled_magnetization_file_path, DataFrame(t=temperatures, M_n=magnetizations); append=true, delim=',')
  elseif ext == ".txt"
    io = open(assembled_magnetization_file_path, "w+")
    for (t,m) in zip(temperatures, magnetizations)
      write_to_txt(io, "$(t), $(m)")
    end
    close(io)
  else
    @error "unsupported file extension $ext"
    return
  end
end

function create_file_and_write_eigspectrum(dir_to_save::String, at_temperature::Float64,eigspectrum::Vector{Float64}; ext=".csv")
  if contains(dir_to_save,"simulations_partitioned")
    file_name = create_file(joinpath(dir_to_save, string("eigspectrum_partitioned_ising_T_",__format_str_float(at_temperature,6),ext)))
  else
    file_name = create_file(joinpath(dir_to_save, string("eigspectrum_T_",__format_str_float(at_temperature,6),ext)))
  end 
  
  if ext == ".csv"
    write_to_csv(file_name, eigspectrum)
  elseif ext == ".txt"
    io = open(file_name, "w+")
    write_to_txt(io, eigspectrum)
    close(io)
  else
    @error "unsupported file extension $ext"
    return
  end
end

function __count_lines_in_file(file_path::String; ext=".csv")::Int64
  n = 0
  if ext == ".csv"
    for _ in CSV.Rows(file_path; header=false, reusebuffer=true)
      n += 1
    end
  elseif ext == ".txt"
    io = open(file_path, "r")
    for _ in eachline(io)
      n += 1
    end
    close(io)
  else
    @error "unsupported file extension $ext"
    return
  end

  return n
end

function runs_and_gens_imrf_details()::Vector{Int64}
  if !isfile(joinpath(SIMULATIONS_DIR), "imrf_details.txt")
    @error "$(SIMULATIONS_DIR)/imrf_details.txt does not exit. Impossible to parse Int64"
  end

  imrf_string = read(joinpath(SIMULATIONS_DIR, "imrf_details.txt"),String)
     
  runs = parse(Int64, replace(match(r"nruns:[0-9]+", imrf_string).match, "nruns:" => ""))
  gens = parse(Int64, replace(match(r"ngens:[0-9]+", imrf_string).match, "ngens:" => ""))

  return Int64[runs, gens]
end

function gens_imrf_partitioned_details()::Int64
  if !isfile(joinpath(SIMULATIONS_PARTITIONED_DIR), "imrf_partitioned_details.txt")
    @error "$(SIMULATIONS_PARTITIONED_DIR)/imrf_partitioned_details.txt does not exit. Impossible to parse Int64"
  end

  imrf_string = read(joinpath(SIMULATIONS_PARTITIONED_DIR, "imrf_partitioned_details.txt"),String)

  return parse(Int64, replace(match(r"ngens:[0-9]+", imrf_string).match, "ngens:" => ""))
end
