include .env
# Define the directory for the Julia environment
JULIA_DEPOT_PATH := $(shell pwd)/.julenv

DELETE_SIMULS := rm -rf simulations/* 

ICN_UPDATE_PROJECT_TOML := cp $(JULIA_DEPOT_PATH)/Project.toml Project.toml

ICN_UPDATE_PROJECT_TOML := cp $(ICN_JULIA_DEPOT_PATH)/Project.toml Project.toml

# Custom shell command to add a package from the environment and update Project.toml for ICN
ICN_ADD_AND_UPDATE := $(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.add("$(ARG)");' && $(ICN_UPDATE_PROJECT_TOML)

# Custom shell command to remove a package from the environment and update Project.toml for ICN
ICN_REMOVE_AND_UPDATE := $(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.rm("$(ARG)");' && $(ICN_UPDATE_PROJECT_TOML)

DELETE_SIMULS := rm -rf simulations/*

DELETE_GRAPHS := rm -rf graphs/simulations/* && rm -rf graphs/psd/simulations/* && rm -rf graphs/eigspectra/*

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
	@$(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.instantiate()'
	cp Project.toml $(JULIA_DEPOT_PATH)/Project.toml
	@$(ICN_JULIA_BIN)  --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()'


# Target to precompile packages in the environment
precompile:
	@$(ICN_JULIA_BIN) --project=$(ICN_JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.precompile()'

# Target to simulate the RFIM
simulate:
	@$(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) cli/simulate.jl $(ARGS)

# Target to plot the trazes of the times series
plot_trazes:
	@$(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) cli/plot_trazes.jl $(ARG)

# Target to plot the psd of the rfft
plot_psd:
	@$(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) cli/plot_psd.jl

plot_eigspectra:
	@julia --project=$(JULIA_DEPOT_PATH) cli/plot_eigspectra.jl $(ARGS)

# Target to precompile packages in the environment
cleanup_simulations:
	@$(DELETE_SIMULS)

cleanup_graphs:
	@$(DELETE_GRAPHS)

.PHONY: julia_env add_to_env rm_from_env instantiate precompile simulate plot_trazes plot_psd plot_eigspectra cleanup_simulations cleanup_graphs