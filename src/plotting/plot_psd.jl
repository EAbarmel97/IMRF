"""
  plot_psd()

Generates and saves PSD plots for all simulation directories within the SIMULATIONS_DIR directory.
"""
function plot_psd()
  #check if ensamblated_magnetization csv exists
  if filter((u) -> endswith(u, ".csv"), readdir(abspath(SIMULATIONS_DIR), join=true)) |> length > 0
    All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[5:end]
  else
    All_SIMULATIONS_DIRS = readdir(abspath(SIMULATIONS_DIR), join=true)[4:end]
  end

  for i in eachindex(All_SIMULATIONS_DIRS)
    str_simulation_temp = match(r"simulations_T_[0-9][0-9]_[0-9]+", All_SIMULATIONS_DIRS[i]).match
    psd_plot_dir = create_dir(joinpath(PSD_GRAPHS_SIMULATIONS, str_simulation_temp), sub_dir)

    plot_mean_psd_by_run(All_SIMULATIONS_DIRS[i], psd_plot_dir)
  end
end

"""
    plot_mean_psd_by_run(temperature_dir::String, destination_dir::String)

Plots and saves the mean Power Spectral Density (PSD) for the given temperature directory.

# Arguments
- `temperature_dir`: Directory with temperature data and Fourier files.
- `destination_dir`: Directory to save the PSD plot.
"""
function plot_mean_psd_by_run(temperature_dir::String, destination_dir::String)
  if isempty(readdir(joinpath(abspath(temperature_dir), "fourier"), join=true))
    @error " impossible to plot PSD. There are no rfts under '$(temperature_dir)/fourier'"
    return
  end

  RFFTS_CSVS_INSIDE_TEMPERATURE_DIR = readdir(joinpath(abspath(temperature_dir), "fourier"), join=true)

  mean_psd_array = mean_psd_by_run(temperature_dir)
  f = FFTW.rfftfreq(temperature_dir)

  f_without_DC = f[2:end]
  average_array_without_DC = mean_psd_array[2:end]

  data = linear_fit_log_psd(f_without_DC, average_array_without_DC) #intercept, exponent & r2

  temperature = parse(temperature_dir)
  num_runs = RFFTS_CSVS_INSIDE_TEMPERATURE_DIR |> length

  plot_file_path = joinpath(destination_dir, "psd_$(match(r"T_[0-9][0-9]_[0-9]+",temperature_dir).match)_r_1_$(num_runs).pdf")

  if !isfile(plot_file_path)
    #= plt = plot(f_without_DC, average_array_without_DC, label=L"S \left( f \right)", xscale=:log10, yscale=:log10, lc=:red)
    #linear fit
    plot!((x) -> exp10(data[1] + data[2] * log10(x)), label=L"\hat{S} \left( f \right)", minimum(f_without_DC), maximum(f_without_DC), xscale=:log10, yscale=:log10, lc=:black)
    #
    title!(string("Mean PSD by run, temp = $(round(temperature, digits=4))",
          "\n beta_fit = $(round(data[2],digits=4)), r**2 = $(round(data[3],digits=4))"
        ); titlefontsize=11)
    xlabel!(L"f")
    ylabel!("power density spectrum")
 =#

    plt = plot(
      f_without_DC, average_array_without_DC,
      label = latexstring("S(f)"),
      xscale = :log10,
      yscale = :log10,
      xlabel = latexstring("f"),
      ylabel = latexstring("S(f)"),
      title = latexstring(
          "Mean\\ PSD\\ by\\ run,\\ T = ",
          string(round(temperature, digits=4)),
          ",\\ \\beta = ",
          string(round(data[2], digits=4)),
          ",\\ R^{2} = ",
          string(round(data[3], digits=4))
      ),
      titlefont  = font(22),
      guidefont  = font(20),
      tickfont   = font(18),
      legendfont = font(18),
      fontfamily = "Times",
      linewidth  = 2,
      lc = :red,
      framestyle = :box,
      grid = false,
      size = (950, 600),
      left_margin = 14mm,
      right_margin = 10mm,
      bottom_margin = 8mm,
      top_margin = 8mm,
      guide_position = :left,
      extra_padding = true,
    )
      plot!(
        (x) -> exp10(data[1] + data[2] * log10(x)),
        label = latexstring("\\hat{S}(f)"),
        xscale = :log10,
        yscale = :log10,
        lc = :black,
      )

    # file saving
    savefig(plt, plot_file_path)
  end
end

