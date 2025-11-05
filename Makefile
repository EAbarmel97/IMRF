# Define the directory for the Julia environment
include $(shell pwd)/.env

DELETE_SIMULS := rm -rf simulations/eigspectra/* && rm -rf simulations/simulations_T_* && rm simulations/*.txt

DELETE_GRAPHS := rm -rf graphs/simulations/* && rm -rf graphs/psd/simulations/* && rm -rf graphs/eigspectra/*

DELETE_SIMULS_PARTITIONED := rm -rf simulations_partitioned/eigspectra/* && rm -rf simulations_partitioned/simulations_T* && rm simulations_partitioned/imrf_*.txt

DELETE_GRAPHS_PARTITIONED := rm -rf graphs_partitioned/eigspectra/*

# Custom shell command to add a package from the environment and update Project.toml
ADD_AND_UPDATE := $(JULIA_BIN) --project=. -e 'using Pkg; Pkg.add("$(ARG)");'

# Custom shell command to remove a package from the environment and update Project.toml
REMOVE_AND_UPDATE := $(JULIA_BIN) --project=. -e 'using Pkg; Pkg.rm("$(ARG)");'

# Target to run Julia commands in the environment
julia_env:
	@$(JULIA_BIN) --project=. $(ARGS)

# Target to add a package to the environment
add_to_env:
	@$(ADD_AND_UPDATE)

# Target to remove a package from the environment
rm_from_env:
	@$(REMOVE_AND_UPDATE)

# Target to resolve dependencies and instantiate the environment
instantiate:
	@$(JULIA_BIN) --project=. -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()'

# Target to precompile packages in the environment
precompile:
	@$(JULIA_BIN) --project=. -e 'using Pkg; Pkg.precompile()'

# Target to simulate the RFIM
simulate:
	@$(JULIA_BIN) --project=. --threads $(nthreads) cli/simulate.jl $(ngrid) $(runs) $(gens) $(nthreads)

# Target to simulate the RFIM
simulate_partitioned:
	@$(JULIA_BIN) --project=. --threads $(nthreads) cli/simulate_partitioned.jl $(ngrid) $(sublattice_ngrid) $(runs) $(gens) $(nthreads)

# Target to plot the trazes of the times series
plot_traces:
	@$(JULIA_BIN) --project=. cli/plot_traces.jl $(assembled_magn)

# Target to plot the trazes of the times series
plot_psd:
	@$(JULIA_BIN) --project=. cli/plot_psd.jl 

plot_eigspectra:
	@$(JULIA_BIN) --project=. cli/plot_eigspectra.jl $(realizations) $(transient_length) $(patterns) 

plot_eigspectra_partitioned:
	@$(JULIA_BIN) --project=. cli/plot_eigspectra_partitioned.jl $(transient_length) $(patterns)

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
