const ALL_AUTOMATED_SIMULS_DIRS = readdir(AUTOMATED_SIMULS_DIR)
#=
number of runs equals the number of files in ../magnetization/ and is the same for each simulations_T_x_y_z/magnetization dir
so the first simulation directory is choosen 
=#
const NUM_RUNS = length(readdir(ALL_GLOBAL_MAGN_DIRS[1]))
