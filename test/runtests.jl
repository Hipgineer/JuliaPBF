##################
# Load Libraries #
##################
push!(LOAD_PATH,pwd())
using Printf
using JuliaPBF

##################
# Initialization #
##################
INPUT_DIR   = "./runtests.xml" # Directory xml Inputs
ANALYDATA   = JuliaPBF.IO_dev.Parsing_xml_file(INPUT_DIR) # Parsing Inputs
SIMULDATA   = JuliaPBF.Solver.PreProcessing(ANALYDATA) # FillInitialBox, GenInitGrid 

#################
# Update Solver #
#################
JuliaPBF.Solver.Update(SIMULDATA, ANALYDATA)