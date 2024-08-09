"""
Unicode representation of the spin grid.

Example: for a 3x3 array the function could print on terminal something like this:

++-
-++
---

"""
function display(ising_lattice::IsingLattice)
    for i in 1:ising_lattice.ngrid
        for j in 1:ising_lattice.ngrid
            if ising_lattice.grid[i,j] === 1
                print("+")
            else
                print("-")
            end     
        end
        println()
    end 
    
    return 
end

"""
    display(ising_lattice::IsingLattice, generation::Int)::String

Returns a stringified version of the spin grid

Example: for a 3x3 array the function could print on terminal something like this:

'++-\n
-++\n
---\n'
"""
function display(ising_lattice::IsingLattice, generation::Int)::String
    str = "gen $generation:\n"
    for i in 1:ising_lattice.ngrid
        for j in 1:ising_lattice.ngrid
            if ising_lattice.grid[i,j] === 1
                str = str*"+"
            else
                str = str*"-"
            end     
        end
        str = str*"\n" #line break
    end

    return str   
end

"""
    reset_stats(ising_lattice::IsingLattice)

resets the fields global_energy, global_mean, global_variance, global_magnetization to be all 0's
"""
function reset_stats(ising_lattice::IsingLattice)
    fields_names_to_reset = ["global_energy","global_mean","global_variance",
    "global_magnetization"]

    for (i,field_name_string) in enumerate(fields_names_to_reset)
        field_name = Symbol(field_name_string) #converts string to Symbol 
        setfield!(ising_lattice,field_name,0.0)
    end
    
    return
end


"""
    compute_energy_cell(i::Int, j::Int, ising_lattice::IsingLattice)::Float64

Returns the energy of a cell. The grid wraps around at the edges (toroidal symmetry)
"""
function compute_energy_cell(i::Int, j::Int, ising_lattice::IsingLattice)::Float64 
    energy = 0
    
    if i === 1 
        im = ising_lattice.ngrid
        ip = 2
    elseif i === ising_lattice.ngrid
        im = ising_lattice.ngrid - 1 
        ip = 1
    elseif 1 < i < ising_lattice.ngrid #if i- coordinate not in boundry 
        ip = i+1
        im = i-1
    end

    if j === 1 
        jm = ising_lattice.ngrid
        jp = 2
    elseif j === ising_lattice.ngrid
        jm = ising_lattice.ngrid - 1
        jp = 1
    elseif 1 < j < ising_lattice.ngrid #if j-coordinate not in boundry 
        jp = j+1
        jm = j-1  
    end
    
    #Energy of cell i,j is determined by the energy of its neighbours 
    energy += ising_lattice.grid[ip,j] + ising_lattice.grid[im,j] + ising_lattice.grid[i,jp] + ising_lattice.grid[i,jm]
    energy = -ising_lattice.grid[i,j]*energy
    return energy #energy per cell 
end

"""
    update_energy(ising_lattice::IsingLattice)

Updates the mean energy of the whole grid of spins
"""
function update_energy(ising_lattice::IsingLattice)
    g_energy = 0
    for i in 1:ising_lattice.ngrid
        for j in 1:ising_lattice.ngrid
            ising_lattice.global_energy += compute_energy_cell(i,j,ising_lattice)
            g_energy = ising_lattice.global_energy            
        end
    end
    g_energy /= ising_lattice.ncells 
    setfield!(ising_lattice,:global_energy,g_energy)

    return
end


"""
    update_magnetization(ising_lattice::IsingLattice)
    
Updates the mean magnetization of the whole spin grid
"""
function update_magnetization(ising_lattice::IsingLattice)
    g_magnetization = 0
    for i in 1:ising_lattice.ngrid
        for j in 1:ising_lattice.ngrid
            ising_lattice.global_magnetization += ising_lattice.grid[i,j]
            g_magnetization = ising_lattice.global_magnetization
        end
    end
    g_magnetization /= ising_lattice.ncells
    setfield!(ising_lattice,:global_magnetization,g_magnetization)

    return
end

#=Generates random changes in the spin grid but conserving a given magnetization=#
function set_magnetization(magn::Float64, ising_lattice::IsingLattice)
    spin_grid = ising_lattice.grid
    p = (1+magn)/2.0
    
    for i in 1:ising_lattice.ngrid
        for j in 1:ising_lattice.ngrid
            if rand() <= p 
                spin_grid[i,j] = +1
            else
                spin_grid[i,j] = -1   
            end
        end
    end
    setfield!(ising_lattice,:grid,spin_grid)
end

#=Randomly populates the spin grid=#
function randomize(ising_lattice::IsingLattice)
    spin_grid = ising_lattice.grid
    rn = 0 
    for i in 1:ising_lattice.ngrid
        for j in 1:ising_lattice.ngrid
          rn = rand(Int)
          if rn % 2 === 0 
            spin_grid[i,j] =-1;
          else 
            spin_grid[i,j] = 1;
          end
        end
    end
    setfield!(ising_lattice,:grid,spin_grid)
end

#=Method for trying a flip spin=#
function try_cell_flip(i::Int, j::Int, ising_lattice::IsingLattice)
    g_energy = 0
    prob = 0
    old_E = compute_energy_cell(i,j,ising_lattice)
    new_E = -old_E #Always true since E_i = s_i*(sum_neighs s_n)
    ΔE = new_E - old_E 
    if ising_lattice.trans_dynamics === metropolis_dynamics
        #Metropolis dynamics
        if ΔE <= 0
            prob = 1 #energy is lower, spin is flipped 
        else
            prob = exp(-ΔE/ising_lattice.temp) #termal flip 
        end
    elseif ising_lattice.trans_dynamics === glauber_dynamics
        #glauber dynamics
        prob = 1/(1 + exp(ΔE/ising_lattice.temp))   
    end  
    
    if rand() <= prob
        do_flip = true 
    else
        do_flip = false    
    end
        
    if do_flip
        #determine changes in global magnetization
        if ising_lattice.grid[i,j] === 1
            ising_lattice.global_magnetization -= 2/ising_lattice.ncells
        else
            ising_lattice.global_magnetization += 2/ising_lattice.ncells    
        end

        ising_lattice.grid[i,j] *=-1 #cell gets flipped
        spin_grid = ising_lattice.grid
        setfield!(ising_lattice,:grid,spin_grid) 

        ising_lattice.global_energy += ΔE/ising_lattice.ncells #individual energy changed
        g_energy = ising_lattice.global_energy
        setfield!(ising_lattice,:global_energy,g_energy)
    end     
end

#=
NOTES: 
1) Because Julia is 1-indexed in the folowing the base function mod1(x,y) will be used. This function returns an integer r  
in the set (0,y] i.e is the same as the % operator but with an offset of 1

2) the ceiled divison function cld(x,y) will be used. 
=#

#= Given the id that uniquely determines a cell in the spin grid, the function outputs the (i,j) 
coordinates inside the grid location =#
function get_cell_coords(id::Int, ising_lattice::IsingLattice)::Vector{Int64}
    i = mod1(id ,ising_lattice.ngrid)
    j = cld(id,ising_lattice.ngrid)
    return [i,j] 
end

#=Provided the (x,y) coordinates of a cell gives the id representation of a spin at location (x,y)=#
function get_cell_id(i::Int, j::Int, ising_lattice::IsingLattice)::Int64
    return i + (j-1)*ising_lattice.ngrid   
end

#=Applies a flip cell spins to each spin in teh spin grid=#
function do_generation(ising_lattice::IsingLattice)
    # with strategy it may happen that not all cells get flipped 
    if ising_lattice.flip_strategy === random_strategy
        for _ in 1:ising_lattice.ncells #this loops from 1 to N² (the number of cells )
            i = mod1(rand(Int),ising_lattice.ngrid)
            j = mod1(rand(Int),ising_lattice.ngrid)
            try_cell_flip(i,j,ising_lattice) 
        end
    #all cells are granted to be flipped at least once (Fisher-Yates algorithm)
    #= TO DO: debug method =#
    elseif ising_lattice.flip_strategy === shuffle_strategy
        ising_lattice.flip_order = 1:(ising_lattice.ngrid*ising_lattice.ngrid)
        fliping_order = ising_lattice.flip_order
        for temp in 1:ising_lattice.ncells
            i = mod1(rand(Int), ising_lattice.ncells - temp + 1 ) + temp - 1 
            swap!(temp,i,fliping_order)
        end
        
        setfield!(ising_lattice,:flip_order, fliping_order)

        #all cells are flipped 
        for i in 1:ising_lattice.ncells
            array_coords = get_cell_coords(ising_lattice.flip_order[i],ising_lattice)
            try_cell_flip(array_coords[1], array_coords[2], ising_lattice)
        end
    
    elseif ising_lattice.flip_strategy === sequential_strategy
        for i in 1:ising_lattice.ngrid
            for j in 1:ising_lattice.ngrid
                try_cell_flip(i,j,ising_lattice) #sequential flip
            end        
        end
    end
end

