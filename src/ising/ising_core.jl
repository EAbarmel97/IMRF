function do_model(INIT_MAGN, TEMP, N_GRID, NUM_RUNS, NUM_GENERATIONS;
    display_lattice::Bool=false,
    flip_strategy::ISING_LATTICE_STRATEGY=random_strategy,
    trans_dynamics::ISING_LATTICE_DYNAMICS=metropolis_dynamics)
    ising_model = IsingLattice(TEMP, N_GRID; flip_strategy = flip_strategy, 
    trans_dynamics = trans_dynamics)

    str_temp = replace(string(round(TEMP, digits=2)), "." => "_") #stringified temperature with "." replaced by "_"
    #= aux_dir = "../scripts/simulations_T_" * str_temp #folder containing simulations al temp str_temp  =#
    aux_dir = create_dir(joinpath(SIMULATIONS_DIR,"simulations_T_"), sub_dir, str_temp)
    create_dir(joinpath(aux_dir,"fourier"), sub_dir)
 
    #= Global magnetization time series realization will be saved on subdirectories over folder simultations=#
    magnetization_aux_dir = create_dir(joinpath(aux_dir,"magnetization"), sub_dir)

    #= Subdirectory containg a .csv file with the unicode representation of how the spin grid evolves with each generation at each run =#
    if display_lattice
        grid_evolution_aux_dir = create_dir(joinpath(aux_dir,"grid_evolution"), sub_dir)
    end    
    
    rfim_info(N_GRID,NUM_RUNS,NUM_GENERATIONS)

    for run in 1:NUM_RUNS
        reset_stats(ising_model)
        set_magnetization(INIT_MAGN, ising_model) #populates the spin grid with a given initial magnetization 
        update_magnetization(ising_model) #updates global magnetization 
        update_energy(ising_model) #updates global energy
        
        #= Creation of generic .csv files containing global magnetization time series =#
        magnetization_file_path = create_file(magnetization_aux_dir, "global_magnetization_r$(run).csv")
        write_to_csv(magnetization_file_path,ising_model.global_magnetization)

        #= Initial observations of the global magnetizaton are saved to their respective .txt files=#
        if display_lattice
            #= Creation of generic .txt files containing snapshots of the spin grid evolution at each generation =#
            generic_spin_grid_file = create_file(grid_evolution_aux_dir, "grid_evolution_r$(run).txt")

            #= Initial spin grid state =#
            open(generic_spin_grid_file, "w+") do io
                stringified_grid_spin = display(ising_model, ising_model.cur_gen)
                write(io, stringified_grid_spin)
            end
        end

        for generation in 1:NUM_GENERATIONS
            do_generation(ising_model)
            setfield!(ising_model, :cur_gen, generation)

            write_to_csv(magnetization_file_path,ising_model.global_magnetization)

            if display_lattice
                open(generic_spin_grid_file, "a+") do io
                    stringified_grid_spin = display(ising_model, ising_model.cur_gen)
                    write(io, stringified_grid_spin)
                end
            end

            if generation == NUM_GENERATIONS
                do_generation(ising_model)
                setfield!(ising_model, :cur_gen, NUM_GENERATIONS)

                write_to_csv(magnetization_file_path,ising_model.global_magnetization)

                if display_lattice
                    open(generic_spin_grid_file, "a+") do io
                        stringified_grid_spin = display(ising_model, ising_model.cur_gen)
                        write(io, stringified_grid_spin)
                    end
                end
            end
        end
    end
end

function do_simulations(arr::Vector{Float64}, N_GRID::Int64, NUM_RUNS::Int64, NUM_GENERATIONS::Int64; include_Tc::Bool=false, display_lattice::Bool=false)
    if include_Tc
        push!(arr, CRITICAL_TEMP)
        sort!(arr)
    end

    for i in eachindex(arr)
        #= random initial magnetization on the interval [-1 ,1] =#
        rand_magn = rand() * 2 - 1

        temp = arr[i]

        do_model(rand_magn, temp, N_GRID, NUM_RUNS, NUM_GENERATIONS; display_lattice=display_lattice)
    end
end