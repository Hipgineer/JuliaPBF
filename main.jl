# set       
println("")
push!(LOAD_PATH,pwd())
using JuliaPBF
using BenchmarkTools


# Parsing Inputs & Define Analysis Data
INPUT_DIR      = "./JuliaPBF/input.xml"
analysisData   = JuliaPBF.UI_dev.parsing_xml_file(INPUT_DIR)

# Initialize Simulation Data
simulationData = JuliaPBF.Solver.PreProcessing(analysisData) # FillInitialBox, GenInitGrid 

# Do Physical Calculation
JuliaPBF.Solver.Update(simulationData, analysisData);