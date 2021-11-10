# set       
println("")
push!(LOAD_PATH,pwd())
using UIPBF
using SolverPBF
using StructPBF
using BenchmarkTools

# Parsing Inputs & Define Analysis Data
INPUT_DIR      = "./input.xml"
analysisData   = UIPBF.parsing_xml_file(INPUT_DIR)

# Initialize Simulation Data
simulationData = SolverPBF.SolverPreProcessing(analysisData) # FillInitialBox, GenInitGrid 

# Do Physical Calculation
SolverPBF.Update(simulationData, analysisData);