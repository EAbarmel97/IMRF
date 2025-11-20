"""
   do_run(temperature::Float64, 
		  n_grid::Int64, 
		  run::Int64, 
		  num_generations::Int64, 
		  magnetization::Float64, 
		  magnetization_dir::String, 
		  grid_evolution_dir::Union{String,Nothing}; 
		  display_lattice::Bool=false, 
		  flip_strategy::ISING_LATTICE_STRATEGY=random_strategy, 
		  trans_dynamics::ISING_LATTICE_DYNAMICS=metropolis_dynamics
		  )

Simulates the evolution made in one run of an Ising lattice and logs magnetization data 

# Arguments
- `temperature::Float64`: The temperature of the system.
- `n_grid::Int64`: The size of the grid (NxN).
- `run::Int64`: The current simulation run identifier.
- `num_generations::Int64`: Number of generations to simulate.
- `magnetization::Float64`: Initial magnetization of the system.
- `magnetization_dir::String`: Directory to store global magnetization data.
- `grid_evolution_dir::Union{String,Nothing}`: Directory to store spin grid evolution snapshots, if `display_lattice` is true.
- `display_lattice::Bool`: Whether to log spin grid states (default is `false`).
- `flip_strategy::ISING_LATTICE_STRATEGY`: Spin-flipping strategy (default is `random_strategy`).
- `trans_dynamics::ISING_LATTICE_DYNAMICS`: Transition dynamics for spin updates (default is `metropolis_dynamics`).
"""
function do_run(
	temperature::Float64,
	n_grid::Int64,
	run::Int64,
	num_generations::Int64,
	magnetization::Float64,
	magnetization_dir::String,
	grid_evolution_dir::Union{String, Nothing};
	display_lattice::Bool = false,
	flip_strategy::ISING_LATTICE_STRATEGY = random_strategy,
	trans_dynamics::ISING_LATTICE_DYNAMICS = metropolis_dynamics,
)

	i_l = IsingLattice(temperature, n_grid; flip_strategy = flip_strategy, trans_dynamics = trans_dynamics)
	reset_stats(i_l)
	set_magnetization(magnetization, i_l) #populates the spin grid with a given initial magnetization              
	update_magnetization(i_l) #updates global magnetization                                                    
	update_energy(i_l) #updates global energy                                                                  

	#= Creation of generic .csv files containing global magnetization time series =#
	#magnetization_file_path = create_file(magnetization_dir, "global_magnetization_r$(run).csv")
	#create_file(joinpath(magnetization_dir, "global_magnetization_r$(lpad(run,3,'0')).txt"))
	magnetization_file_path = touch(joinpath(magnetization_dir, "global_magnetization_r$(lpad(run,3,'0')).txt"))
	magnetization_file = open(magnetization_file_path, "w")
	#write_to_csv(magnetization_file_path, i_l.global_magnetization)
	write_to_txt(magnetization_file,i_l.global_magnetization)

	#= Initial observations of the global magnetizaton are saved to their respective .txt files=#
	if display_lattice
		#= Creation of generic .txt files containing snapshots of the spin grid evolution at each generation =#
		generic_spin_grid_file = create_file(grid_evolution_dir, "grid_evolution_r$(run).txt")

		#= Initial spin grid state =#
		open(generic_spin_grid_file, "w+") do io
			stringified_grid_spin = display(i_l, i_l.cur_gen)
			write(io, stringified_grid_spin)
		end
	end

	for generation in 1:num_generations
		do_generation(i_l)
		setfield!(i_l, :cur_gen, generation)

		write_to_txt(magnetization_file, i_l.global_magnetization)

		if display_lattice
			open(generic_spin_grid_file, "a+") do io
				stringified_grid_spin = display(i_l, i_l.cur_gen)
				write(io, stringified_grid_spin)
			end
		end
	end

	close(magnetization_file)
end

"""
   do_partitioned_run(
		  temperature::Float64, 
		  n_grid::Int64,
		  sublattice_ngrid::Int64,
		  run::Int64, 
		  num_generations::Int64, 
		  magnetization::Float64, 
		  magnetization_dir::String, 
		  flip_strategy::ISING_LATTICE_STRATEGY=random_strategy, 
		  trans_dynamics::ISING_LATTICE_DYNAMICS=metropolis_dynamics
		  )

Simulates the evolution made in one run of an Ising lattice and logs magnetization data 

# Arguments
- `temperature::Float64`: The temperature of the system.
- `n_grid::Int64`: The size of the grid (NxN).
- `sublattice_ngrid::Int64`: number of sublattices to partition the original. It should divide `n_grid` otherwise it will throw 
   an error. 
- `run::Int64`: The current simulation run identifier.
- `num_generations::Int64`: Number of generations to simulate.
- `magnetization::Float64`: Initial magnetization of the system.
- `magnetization_dir::String`: Directory to store global magnetization data.
- `flip_strategy::ISING_LATTICE_STRATEGY`: Spin-flipping strategy (default is `random_strategy`).
- `trans_dynamics::ISING_LATTICE_DYNAMICS`: Transition dynamics for spin updates (default is `metropolis_dynamics`).
"""
function do_partitioned_run(
	temperature::Float64,
	n_grid::Int64,
	sublattice_ngrid::Int64,
	run::Int64,
	num_generations::Int64,
	magnetization::Float64,
	magnetization_dir::String,
	flip_strategy::ISING_LATTICE_STRATEGY = random_strategy,
	trans_dynamics::ISING_LATTICE_DYNAMICS = metropolis_dynamics,
)

	if !iszero(n_grid % sublattice_ngrid)
		throw(DivideError())
	end

	num_sublattices = convert(Int64, (n_grid / sublattice_ngrid)^2)

	i_l = IsingLattice(temperature, n_grid; flip_strategy = flip_strategy, trans_dynamics = trans_dynamics)
	reset_stats(i_l)
	set_magnetization(magnetization, i_l) #populates the spin grid with a given initial magnetization              
	update_magnetization(i_l) #updates global magnetization                                                    
	update_energy(i_l) #updates global energy

	#= Creation of generic files containing global magnetization time series =#
    magnetization_file_path = joinpath(magnetization_dir, "sublattices_magnetizations_r$(lpad(run, 3, '0')).csv")
	magnetization_file = open(magnetization_file_path, "w") do io
		for generation in 1:num_generations
			do_generation(i_l)
			i_l.cur_gen = generation
			sublattice_magnetizations = Float64[]

			for sublattice_id in 1:num_sublattices
				push!(sublattice_magnetizations, compute_local_magnetization(i_l, sublattice_ngrid, sublattice_id))
			end
			CSV.write(io, Tables.table(permutedims(sublattice_magnetizations)), header = false, append = true)
		end
	end
end

"""
	do_simulations(temperatures::Vector{Float64}, 
				   N_GRID::Int64, 
				   NUM_RUNS::Int64, 
				   NUM_GENERATIONS::Int64;
				   include_Tc::Bool=false, 
				   display_lattice::Bool=false, 
				   generate_rffts::Bool=false
				   )

Performs multiple simulation runs on a grid with specified parameters, optionally including a critical temperature, visualizing the lattice, 
and generating random Fourier transforms.

# Arguments
- `temperatures::Vector{Float64}`: A vector of temperature values to be used in the simulations.
- `N_GRID::Int64`: The size of the grid for the simulation.
- `NUM_RUNS::Int64`: The number of simulation runs to be performed.
- `NUM_GENERATIONS::Int64`: The number of generations for each simulation run.

# Keyword Arguments
- `include_Tc::Bool=false`: If `true`, the critical temperature (`CRITICAL_TEMP`) is added to the temperature array and sorted.
- `display_lattice::Bool=false`: If `true`, the lattice will be displayed during the simulations.
- `generate_rffts::Bool=false`: If `true`, random Fourier transforms will be generated and saved after the simulation runs.
"""
function do_simulations(
	temperatures::Vector{Float64},
	N_GRID::Int64,
	NUM_RUNS::Int64,
	NUM_GENERATIONS::Int64;
	include_Tc::Bool = false,
	display_lattice::Bool = false,
	generate_rffts::Bool = false,
	write_file_assembled_magnetization::Bool = false,
	ext=".csv"
)
	imrf_info(N_GRID, NUM_RUNS, NUM_GENERATIONS)

	if include_Tc
		push!(temperatures, CRITICAL_TEMP)
		sort!(temperatures)
	end

	temps_runs_cartesian_prod = Iterators.product(temperatures, 1:NUM_RUNS)

	for temp in temperatures
		if temp == CRITICAL_TEMP
			str_temp = __format_str_float(CRITICAL_TEMP, 6)
			aux_dir = create_dir(joinpath(SIMULATIONS_DIR, "simulations_T_"), sub_dir, str_temp)
		else
			str_temp = __format_str_float(temp, 6)
			aux_dir = create_dir(joinpath(SIMULATIONS_DIR, "simulations_T_"), sub_dir, str_temp)
		end

		fourier_dir = create_dir(joinpath(aux_dir, "fourier"), sub_dir)

		#= Global magnetization time series realization will be saved on subdirectories over folder simultations=#
		magnetization_dir = create_dir(joinpath(aux_dir, "magnetization"), sub_dir)

		grid_evolution_dir = nothing
			#= Subdirectory containg a .csv file with the unicode representation of how the spin grid evolves with each generation at each run =#
		if display_lattice
			grid_evolution_dir = create_dir(joinpath(aux_dir, "grid_evolution"), sub_dir)                                     
		end
	end

	@threads for (temp, run) in collect(temps_runs_cartesian_prod)
		begin
			magnetization_dir = joinpath(SIMULATIONS_DIR, "simulations_T_" * __format_str_float(temp, 6), "magnetization")
			grid_evolution_dir = nothing
            if display_lattice
			    grid_evolution_dir = joinpath(SIMULATIONS_DIR, "grid_evolution", "simulations_T_" * __format_str_float(temp, 6) )                                                                 #random initial magnetization on the interval [-1 ,1]#                                      
		    end
			#rand_magn = rand() * 2 - 1
			init_magn=0.5
			do_run(temp, N_GRID, run, NUM_GENERATIONS, init_magn, magnetization_dir, grid_evolution_dir)
		end
	end

	if write_file_assembled_magnetization
		write_file_assembled_magnetization_by_temprature(SIMULATIONS_DIR; statistic = mean, ext=ext)
	end

	if generate_rffts
		write_rffts(NUM_RUNS; ext=ext)
	end
end

"""
	do_partitioned_simulations(temperatures::Vector{Float64}, 
				   N_GRID::Int64,
				   SUBLATTICE_NGRID::Int64
				   NUM_RUNS::Int64, 
				   NUM_GENERATIONS::Int64;
				   include_Tc::Bool=false, 
				   display_lattice::Bool=false, 
				   generate_rffts::Bool=false
				   )

Performs multiple simulation runs on a grid with specified parameters, optionally including a critical temperature, visualizing the lattice, 
and generating random Fourier transforms.

# Arguments
- `temperatures::Vector{Float64}`: A vector of temperature values to be used in the simulations.
- `N_GRID::Int64`: The size of the grid for the simulation.
- `SUBLATTICE_NGRID::Int64`: The size of sublattices 
- `NUM_RUNS::Int64`: The number of simulation runs to be performed.
- `NUM_GENERATIONS::Int64`: The number of generations for each simulation run.

# Keyword Arguments
- `include_Tc::Bool=false`: If `true`, the critical temperature (`CRITICAL_TEMP`) is added to the temperature array and sorted.
"""
function do_partitioned_simulations(
	temperatures::Vector{Float64},
	N_GRID::Int64,
	SUBLATTICE_NGRID::Int64,
	NUM_RUNS::Int64,
	NUM_GENERATIONS::Int64;
	include_Tc::Bool = false,
) 
	imrf_partitioned_info(N_GRID, SUBLATTICE_NGRID, NUM_RUNS, NUM_GENERATIONS)

	if include_Tc
		push!(temperatures, CRITICAL_TEMP)
		sort!(temperatures)
	end

	temps_runs_cartesian_prod = Iterators.product(temperatures, 1:NUM_RUNS)

	for temp in temperatures
		if temp == CRITICAL_TEMP
			str_temp = __format_str_float(CRITICAL_TEMP, 6)
			aux_dir = create_dir(joinpath(SIMULATIONS_PARTITIONED_DIR, "simulations_T_"), sub_dir, str_temp)
		else
			str_temp = __format_str_float(temp, 6)
			aux_dir = create_dir(joinpath(SIMULATIONS_PARTITIONED_DIR, "simulations_T_"), sub_dir, str_temp)
		end

		#Global magnetization time series realization will be saved on subdirectories over folder simultations
		magnetization_dir = create_dir(joinpath(aux_dir, "magnetization"), sub_dir)
	end

	@threads for (temp, run) in collect(temps_runs_cartesian_prod)
		begin
			#Global magnetization time series realization will be saved on subdirectories over folder simultations
			magnetization_dir = joinpath(SIMULATIONS_PARTITIONED_DIR, "simulations_T_" * __format_str_float(temp, 6), "magnetization")

			rand_magn = rand() * 2 - 1
			do_partitioned_run(temp, N_GRID, SUBLATTICE_NGRID, run, NUM_GENERATIONS, rand_magn, magnetization_dir)
		end
	end
end
