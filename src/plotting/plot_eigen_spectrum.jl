function plot_eigen_spectrum(eigvals::Vector{Float64}, at_temperature::Float64, num_realizations::Int64, dir_to_save::String=".")
  #compute linear fit 
  fit_data = linear_fit_log_eigspectrum_r2(eigvals) #intercept, exponent,  r2
  x = collect(Float64, 1:length(eigvals))
  str_temp = replace(string(round(at_temperature, digits=6)), "." => "_")
  full_file_path = joinpath(dir_to_save, "eigspectrum_magnetization_data_matrix_$(str_temp).png")
 
  #persist graph if doesn't exist
  if !isfile(full_file_path)
      plt = plot(
          x, eigvals,
          lw = 2,
          lc = :red,
          ls = :dot,          
          alpha = 0.6,
          label = "",          
          xscale = :log10,
          yscale = :log10,
          title = latexstring(
              "Eigen\\ spectrum:\\ T = ",
              string(round(at_temperature, digits = 4)),
              ",\\ \\beta = ",
              string(round(fit_data[2], digits = 4))
          ),
          xlabel = L"n",
          ylabel = L"\lambda_n",
          titlefont  = font(16, "Times New Roman"),
          guidefont  = font(20, "Times New Roman"),
          tickfont   = font(18, "Times New Roman"),
          legendfont = font(18),
          fontfamily = "Times New Roman",
          framestyle = :box,
          grid = false,
          legend = :topright,
          size = (950, 600),
          left_margin = 14mm,
          right_margin = 10mm,
          bottom_margin = 8mm,
          top_margin = 8mm,
          guide_position = :left,
          extra_padding = true,
      )

      scatter!(
          plt,
          x, eigvals,
          markershape = :circle,
          markersize = 4,
          markercolor = :red,
          markerstrokewidth = 0.8,
          markeralpha = 0.9,
          label = L"\lambda_n",
      )

      # Linear fit
      plot!(
          plt,
          u -> exp10(fit_data[1] + fit_data[2] * log10(u)),
          label = L"linear fit",
          xscale = :log10,
          yscale = :log10,
          lc = :black,
          lw = 2
      )


      # Define position and proportional size based on axis range
      xmin, xmax = extrema(x)
      ymin, ymax = extrema(eigvals)
      xrange = log10(xmax / xmin)
      yrange = log10(ymax / ymin)

      # define box dimensions relative to log-scale range
      x_annot = xmin * 10^(0.02 * xrange)
      y_annot = ymin * 10^(0.08 * yrange)

      # Place R² text centered within the box
      annotate!(
          x_annot,
          y_annot,
          text(latexstring("R^{2} = ", round(fit_data[3], digits = 4)), 
          "Times New Roman", 
          16, 
          :left, 
          :bottom, 
          :black)
      )

      savefig(plt, full_file_path)
    end
end

function plot_eigen_spectra(r::Int64, transient_length::Int64, temperature_dirs::Vararg{String}; persist_eigspectra::Bool=false,  ext=".csv")
  num_runs, num_gens = runs_and_gens_imrf_details()
  if r > num_runs
    @error "impossible to plot eigspectra. 
    Magnetization data matrix at fixed temp can not have more than $(num_runs) rows"
  end

  if transient_length > num_gens
   @error "impossible to discard $(transient_length) generations out of $(num_gens)"
  end

  if r <= num_runs
    for temperature_dir in collect(temperature_dirs)
      magnetization_data_matrix = ts_data_matrix(temperature_dir, r)'
      eigspectrum = compute_filtered_eigvals!(magnetization_data_matrix[transient_length+1:end,:])
      at_temperature = parse(temperature_dir)
      if persist_eigspectra
        create_file_and_write_eigspectrum(SIMULATIONS_EIGSPECTRA_DIR, at_temperature, eigspectrum; ext=ext)
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
        create_file_and_write_eigspectrum(SIMULATIONS_PARTITIONED_EIGSPECTRA_DIR, at_temperature, eigspectrum; ext=".csv")
      end
      plot_eigen_spectrum(eigspectrum, at_temperature, r, GRAPHS_PARTITIONED_EIGSPECTRA_DIR)
    end  
  end
end