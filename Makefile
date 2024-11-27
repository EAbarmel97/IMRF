include /home/eabarmel/.env
# Define the directory for the Julia environment
CLI := /storage5/eabarmel/IMRF/cli

ICN_UPDATE_PROJECT_TOML := cp $(ICN_JULIA_DEPOT_PATH)/Project.toml Project.toml

# Custom shell command to add a package from the environment and update Project.toml for ICN
ICN_ADD_AND_UPDATE := $(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.add("$(ARG)");' && $(ICN_UPDATE_PROJECT_TOML)

# Custom shell command to remove a package from the environment and update Project.toml for ICN
ICN_REMOVE_AND_UPDATE := $(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.rm("$(ARG)");' && $(ICN_UPDATE_PROJECT_TOML)

DELETE_SIMULS := rm -rf simulations/eigspectra/* && rm -rf simulations/simulations_T_* && rm simulations/imrf_*.txt && rm simulations/*.csv

DELETE_GRAPHS := rm -rf graphs/simulations/* && rm -rf graphs/psd/simulations/*

DELETE_SIMULS_PARTITIONED := rm -rf simulations_partitioned/eigspectra/* && rm -rf simulations_partitioned/simulations_T* && rm simulations_partitioned/imrf_*.txt

DELETE_GRAPHS_PARTITIONED := rm -rf graphs_partitioned/eigspectra/*

# Target to run Julia commands in the ICN environment
julia_env:
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) $(ARGS)

# Target to add a package to the ICN environment
add_to_env:
	@$(ICN_ADD_AND_UPDATE)

# Target to remove a package from the ICN environment
rm_from_env:
	@$(ICN_REMOVE_AND_UPDATE)

# Target to resolve dependencies and instantiate the ICN environment
instantiate:
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) 'using Pkg; Pkg.instantiate()'
	cp Project.toml $(ICN_JULIA_DEPOT_PATH)/Project.toml
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()'

# Target to precompile packages in the ICN environment
precompile:
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.precompile()'

# Target to simulate the Ising model
simulate:
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) --threads $(nthreads) $(CLI)/simulate.jl $(ngrid) $(runs) $(gens) $(nthreads)

simulate_partitioned:
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) --threads $(nthreads) $(CLI)/simulate_partitioned.jl $(ngrid) $(sublattice_ngrid) $(runs) $(gens) $(nthreads)

# Target to plot the time series magnetization traces 
plot_traces:                                                               
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) $(CLI)/plot_traces.jl $(assembled_magn)

# Target to plot the psd of the rfft                                
plot_psd:                                                           
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) $(CLI)/plot_psd.jl   

# Target to plot eigspectra 
plot_eigspectra:
	@julia --project=$(JULIA_DEPOT_PATH) $(CLI)/plot_eigspectra.jl $(realizations) $(transient_length) $(patterns) 

plot_eigspectra_partitioned:
	@julia --project=$(JULIA_DEPOT_PATH) $(CLI)/plot_eigspectra_partitioned.jl $(transient_length) $(patterns)

# Target to precompile packages in the environment
cleanup_simulations:
	@$(DELETE_SIMULS)

cleanup_graphs:
	@$(DELETE_GRAPHS)

cleanup_simulations_partitioned:
	@$(DELETE_SIMULS_PARTITIONED)

cleanup_graphs_partitioned:
	@$(DELETE_GRAPHS_PARTITIONED)

cleanup:
	@($(DELETE_GRAPHS) && $(DELETE_SIMULS))

cleanup_partitioned:
	@($(DELETE_GRAPHS_PARTITIONED) && $(DELETE_SIMULS_PARTITIONED))

.PHONY: julia_env add_to_env rm_from_env instantiate precompile simulate simulate_partitioned plot_traces plot_psd plot_eigspectra plot_eigspectra_partitioned 
.PHONY: cleanup_simulations cleanup_graphs cleanup_simulations_partitioned cleanup_graphs_partitioned cleanup cleanup_partitioned
