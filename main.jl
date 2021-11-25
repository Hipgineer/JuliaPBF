##################
# Load Libraries #
##################
push!(LOAD_PATH,pwd())
using JuliaPBF
using BenchmarkTools
using Printf

##################
# Initialization #
##################
INPUT_DIR   = "./JuliaPBF/input.xml" # Directory xml Inputs
ANALYDATA   = JuliaPBF.IO_dev.Parsing_xml_file(INPUT_DIR) # Parsing Inputs
SIMULDATA   = JuliaPBF.Solver.PreProcessing(ANALYDATA) # FillInitialBox, GenInitGrid 


##############
# Run Solver #
##############
curr_time = 0.0 
ii        = 0 
while curr_time < ANALYDATA.endTime
    curr_time += ANALYDATA.timeStep.dt
    @printf("Time = %10.5f \n",curr_time)
    @printf("  Update for          :")
    @time JuliaPBF.Solver.Update(SIMULDATA, ANALYDATA)
    
    ii += 1
    @printf("  Writing Output for  :")
    @time JuliaPBF.IO_dev.Writing_ascii_file(SIMULDATA, "out__"*lpad(ii,5,"0"))
end 