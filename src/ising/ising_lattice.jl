#The critical temperature is Tc = 2/ln(1+sqrt(2)) in units of J/k, with k beeing the Boltzman constant
const CRITICAL_TEMP = 2.26918531421302

@enum ISING_LATTICE_STRATEGY random_strategy = 1 shuffle_strategy = 2 sequential_strategy = 3
@enum ISING_LATTICE_DYNAMICS metropolis_dynamics = 1 glauber_dynamics = 2

mutable struct IsingLattice
    #Temperature 
    temp::Float64

    #Size of grid 
    ngrid::Int

    #Size of grid's side
    ncells::Int64

    #2D array containg the spin states: N²
    grid::Matrix{Int64}

    #Flip order 
    flip_order::Vector{Int64}

    #Fliping strategies 
    flip_strategy::ISING_LATTICE_STRATEGY

    #Transition dynamics 
    trans_dynamics::ISING_LATTICE_DYNAMICS

    #Current generation (will never reset)
    cur_gen::Int

    #Global statistics
    global_energy::Float64
    global_mean::Float64
    global_variance::Float64
    global_magnetization::Float64

    #model constructor with two params 
    function IsingLattice(temp::Float64, ngrid::Int64;
        flip_strategy::ISING_LATTICE_STRATEGY=random_strategy, trans_dynamics::ISING_LATTICE_DYNAMICS=metropolis_dynamics)
        ncells = ngrid * ngrid
        flip_order = Vector{Int64}(undef, ncells)
        grid = Matrix{Int64}(undef, ngrid, ngrid)
        cur_gen = 0

        global_energy = 0.0
        global_magnetization = 0.0
        global_mean = 0.0
        global_variance = 0.0

        return new(temp, ngrid, ncells, grid, flip_order, flip_strategy, trans_dynamics,
            cur_gen, global_energy, global_magnetization, global_mean, global_variance)
    end
end
