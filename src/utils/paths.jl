"""
path config definitions
"""
const REPO_DIR = abspath(joinpath(@__DIR__,"..", ".."))

const SIMULATIONS_DIR = joinpath(REPO_DIR, "simulations")
const SIMULATIONS_EIGSPECTRA_DIR = joinpath(SIMULATIONS_DIR, "eigspectra")

const GRAPHS_DIR = joinpath(REPO_DIR, "graphs")
const GRAPHS_DIR_EIGSPECTRA  = joinpath(GRAPHS_DIR, "eigspectra")
const GRAPHS_DIR_SIMULATIONS = joinpath(GRAPHS_DIR, "simulations")
const PSD_GRAPHS = joinpath(GRAPHS_DIR, "psd")
const PSD_GRAPHS_SIMULATIONS = joinpath(PSD_GRAPHS, "simulations")


const SIMULATIONS_PARTITIONED_DIR = joinpath(REPO_DIR, "simulations_partitioned")
const SIMULATIONS_PARTITIONED_EIGSPECTRA_DIR = joinpath(SIMULATIONS_PARTITIONED_DIR, "eigspectra")

const GRAPHS_PARTITIONED_DIR = joinpath(REPO_DIR, "graphs_partitioned")
const GRAPHS_PARTITIONED_EIGSPECTRA_DIR  = joinpath(GRAPHS_PARTITIONED_DIR, "eigspectra")