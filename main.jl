# set       
println("")
push!(LOAD_PATH,pwd())
using PbdUserInterface
using PbdSolver2D
using pbdStruct2D
using BenchmarkTools

# Parsing Inputs & Define Analysis Data
INPUT_DIR      = "./input.xml"
analysisData   = PbdUserInterface.parsing_xml_file(INPUT_DIR)

# Initialize Simulation Data
simulationData = PbdSolver2D.SolverPreProcessing(analysisData) # FillInitialBox, GenInitGrid 

# Do Physical Calculation
PbdSolver2D.Update(simulationData, analysisData);