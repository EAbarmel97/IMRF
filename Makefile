include .env

# Define the directory for the Julia environment
JULIA_DEPOT_PATH := $(shell pwd)/.julenv

DELETE_SIMULS := rm -rf simulations/* 
UPDATE_PROJECT_TOML := cp $(JULIA_DEPOT_PATH)/Project.toml Project.toml

ICN_UPDATE_PROJECT_TOML := cp $(ICN_JULIA_DEPOT_PATH)/Project.toml Project.toml

# Custom shell command to add a package from the environment and update Project.toml
ADD_AND_UPDATE := julia --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.add("$(ARG)");' && $(UPDATE_PROJECT_TOML)

# Custom shell command to remove a package from the environment and update Project.toml
REMOVE_AND_UPDATE := julia --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.rm("$(ARG)");' && $(UPDATE_PROJECT_TOML)

# Custom shell command to add a package from the environment and update Project.toml for ICN
ICN_ADD_AND_UPDATE := $(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.add("$(ARG)");' && $(ICN_UPDATE_PROJECT_TOML)

# Custom shell command to remove a package from the environment and update Project.toml for ICN
ICN_REMOVE_AND_UPDATE := $(ICN_JULIA_BIN) --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.rm("$(ARG)");' && $(ICN_UPDATE_PROJECT_TOML)

# Target to run Julia commands in the environment
julia_env:
	@julia --project=$(JULIA_DEPOT_PATH) $(ARGS)

# Target to add a package to the environment
add_to_env:
	@$(ADD_AND_UPDATE)

# Target to remove a package from the environment
rm_from_env:
	@$(REMOVE_AND_UPDATE)

# Target to resolve dependencies and instantiate the environment
instantiate:
	@julia --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()'

# Target to precompile packages in the environment
precompile:
	@julia --project=$(JULIA_DEPOT_PATH) -e 'using Pkg; Pkg.precompile()'

simulate:
	@julia --project=$(JULIA_DEPOT_PATH) main.jl $(ARGS)

plot_trazes:
	@julia --project=$(JULIA_DEPOT_PATH) cli/plot_trazes.jl $(ARG)

cleanup:
	@$(DELETE_SIMULS)

.PHONY: julia_env add_to_env rm_from_env instantiate precompile simulate cleanup plot_trazes