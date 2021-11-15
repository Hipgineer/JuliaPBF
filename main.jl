# set
push!(LOAD_PATH,pwd())
using JuliaPBF
using BenchmarkTools


# Parsing Inputs & Define Analysis Data
INPUT_DIR      = "./JuliaPBF/input.xml"
analysisData   = JuliaPBF.IO_dev.Parsing_xml_file(INPUT_DIR)

# Initialize Simulation Data
simulationData = JuliaPBF.Solver.PreProcessing(analysisData) # FillInitialBox, GenInitGrid 

## Do Physical Calculation
JuliaPBF.Solver.Update(simulationData, analysisData);

@time JuliaPBF.IO_dev.Writing_ascii_file(simulationData, analysisData)