function plot_eigen_spectrum(eigvals::Vector{Float64}, at_temperature::Float64, num_realizations::Int64, dir_to_save::String=".")
  #compute linear fit 
  fit_data = linear_fit_log_eigspectrum_r2(eigvals) #intercept, exponent,  r2
  x = collect(Float64, 1:length(eigvals))
  str_temp = replace(string(round(at_temperature, digits=6)), "." => "_")
  full_file_path = joinpath(dir_to_save, "eigspectrum_magnetization_data_matrix_$(str_temp).pdf")
  #persist graph if doesn't exist
  if !isfile(full_file_path)
    #plot styling
    annot = string("R^2: ", round(fit_data[3],digits=3))
    plt = plot(x, eigvals, label=L"{\lambda}_n", xscale=:log10, yscale=:log10, lw=3, ls=:dot, alpha=0.2)
    #linear fit
    plot!(u -> exp10(fit_data[1] + fit_data[2] * log10(u)), label="linear fit", minimum(x), maximum(x), xscale=:log10, yscale=:log10)
    
    title!(
      string("Eigen spectrum magnetization data matrix at T = $(at_temperature)",
              "\n beta_fit = $(round(fit_data[2],digits=4)), r**2 = $(round(fit_data[3],digits=4))"); 
      titlefontsize=11
      )
    xlabel!(L"n")
    ylabel!("Eigen spectrum")

    #file saving
    savefig(plt, full_file_path)
  end
end

function plot_eigen_spectra(r::Int64, transient_length::Int64, temperature_dirs::Vararg{String}; persist_eigspectra::Bool=false)
  num_runs, num_gens = runs_and_gens_imrf_details()
  if r > num_runs
    @error "impossible to plot eigspectra. 
    Magnetization data matrix at fixed temp can not have more than $(num_runs) rows"
  end

  if transient_length > num_gens
   @error "impossible to discard $(transient_length) generations out of $(num_gens)"
  end

  if r < num_runs
    for temperature_dir in collect(temperature_dirs)
      magnetization_data_matrix = ts_data_matrix(temperature_dir, r)
      eigspectrum = compute_filtered_eigvals!(magnetization_data_matrix[transient_length+1:end,:])
      at_temperature = parse(temperature_dir)
      if persist_eigspectra
        create_csvfile_and_write_eigspectrum(SIMULATIONS_EIGSPECTRA_DIR,at_temperature,eigspectrum)
      end
      plot_eigen_spectrum(eigspectrum, at_temperature, r, GRAPHS_DIR_EIGSPECTRA)
    end
  end
end

function plot_partitioned_eigen_spectra(transient_length::Int64, temperature_dirs::Vararg{String}; r::Int64=1, persist_eigspectra::Bool=false)
  num_gens = gens_imrf_partitioned_details()
  if transient_length > num_gens
    @error "impossible to discard $(transient_length) generations out of $(num_gens)"
  end 
  
  for temperature_dir in collect(temperature_dirs)
    CSVS_INSIDE_TEMPERATURE_DIR = readdir(joinpath(abspath(temperature_dir), "magnetization"),join=true)
    for i in eachindex(CSVS_INSIDE_TEMPERATURE_DIR)
      magnetization_data_matrix = load_data_matrix(Float64,CSVS_INSIDE_TEMPERATURE_DIR[i]; drop_header=true)
      eigspectrum = compute_filtered_eigvals!(magnetization_data_matrix[transient_length + 1:end,:])
      at_temperature = parse(temperature_dir)
      if persist_eigspectra
        create_csvfile_and_write_eigspectrum(SIMULATIONS_PARTITIONED_EIGSPECTRA_DIR, at_temperature, eigspectrum)
      end
      plot_eigen_spectrum(eigspectrum, at_temperature, r, GRAPHS_PARTITIONED_EIGSPECTRA_DIR)
    end  
  end
end