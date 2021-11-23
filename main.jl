# set
push!(LOAD_PATH,pwd())
using JuliaPBF
using BenchmarkTools
using Printf

# Parsing Inputs & Define Analysis Data
INPUT_DIR   = "./JuliaPBF/input.xml"

# Initialize Simulation Data
ANALYDATA   = JuliaPBF.IO_dev.Parsing_xml_file(INPUT_DIR)
SIMULDATA   = JuliaPBF.Solver.PreProcessing(ANALYDATA) # FillInitialBox, GenInitGrid 

# Do Physical Calculation
curr_time = 0.0 
ii        = 0 
while curr_time < ANALYDATA.endTime
# for ii in 1:100 #Int(floot(ANALYDATA.EndTimeStep))
    curr_time += ANALYDATA.timeStep.dt
    @printf("Time = %10.5f  spends ",curr_time)
    @time JuliaPBF.Solver.Update(SIMULDATA, ANALYDATA);
    
    ii += 1
    JuliaPBF.IO_dev.Writing_ascii_file(SIMULDATA, "out__"*lpad(ii,5,"0"))
end 