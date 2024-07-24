"""
path config definitions
"""

#= simulations =#
const REPO_DIR = abspath(joinpath(@__DIR__,"..", ".."))

const SIMULATIONS_DIR = joinpath(REPO_DIR,"simulations")

const GRAPHS_DIR = joinpath(REPO_DIR,"graphs")
const GRAPHS_DIR_SIMULATIONS = joinpath(GRAPHS_DIR,"simulations")
const PSD_GRAPHS = joinpath(GRAPHS_DIR,"psd")
const PSD_GRAPHS_SIMULATIONS = joinpath(PSD_GRAPHS,"simulations")

#const ALL_GLOBAL_MAGN_DIRS = joinpath.(AUTOMATED_SIMULS_DIR, readdir(AUTOMATED_SIMULS_DIR), "magnetization")
#const ALL_AUTOMATED_RFFTS = joinpath.(AUTOMATED_SIMULS_DIR, readdir(AUTOMATED_SIMULS_DIR), "fourier")