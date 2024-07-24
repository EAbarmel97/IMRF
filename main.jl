include("src/RFIM.jl")
using .RFIM: do_simulations

function main(ARGS)
    # ploting mean magnetization vs temperature
    args = parse.(Int64, ARGS[1:3])
    RFIM.do_simulations(RFIM.DEFAULT_TEMPERATURE_ARRAY, args...;)
end

main(ARGS)