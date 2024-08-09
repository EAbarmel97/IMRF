module RFIM
using Base.Threads
using LinearAlgebra
using Statistics 
using Printf

using DataFrames, CSV, GLM
using LaTeXStrings
using Plots

using FFTW

include("io/io_operations.jl")

include("fourier/fourier_analysis.jl")

include("ising/ising_lattice.jl")
include("ising/ising_lattice_methods.jl")
include("ising/ising_core.jl")

include("plotting/plot_psd.jl")
include("plotting/plot_trazes.jl")

include("utils/utilities.jl")
include("utils/paths.jl")

include("matrix_ops/svd.jl")

export do_simulations #ising_core.jl exports

export plot_traze, plot_trazes, plot_psd, plot_ensamblated_magnetization  #plot_trazes.jl exports

export DEFAULT_TEMPERATURE_ARRAY #utilities.jl exports

export ts_data_matrix #svd exports
end #end of module