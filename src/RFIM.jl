module RFIM
using Base.Threads
using LinearAlgebra

using DataFrames, CSV, GLM
using LaTeXStrings
using Plots

import FFTW

include("fourier/fourier_analysis.jl")

include("io/io_operations.jl")

include("ising/ising_lattice.jl")
include("ising/ising_lattice_methods.jl")
include("ising/ising_core.jl")

include("plotting/plot_psd.jl")
include("plotting/plot_trazes.jl")

include("utils/utilities.jl")
include("utils/paths.jl")

export do_simulations #ising_core exports

export plot_sample_magnetization

export DEFAULT_TEMPERATURE_ARRAY
end #end of module