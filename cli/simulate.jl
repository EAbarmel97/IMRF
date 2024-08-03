include("../src/RFIM.jl")
using .RFIM: do_simulations

function main(ARGS)
    #ARG[1]: N_GRID
    #ARG[2]: NUM_RUNS
    #ARG3[3]: NUM_GENERATIONS
    args = parse.(Int64, ARGS[1:3])
    RFIM.do_simulations(
        RFIM.DEFAULT_TEMPERATURE_ARRAY, 
        args...; 
        generate_rffts = true, #writes a csv per temperature at each fixed temp
        write_csv_ensamblated_magnetization = true 
        )
end

main(ARGS)