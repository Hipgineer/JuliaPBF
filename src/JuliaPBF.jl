""" 
    Julia Position Based Fluid

          (C) Hipgineer
             Jaybin         
              2021
                        
"""
module JuliaPBF

export StructPBF,
       IO_dev,
       Solver

##############
# DATA TYPES #
##############
include("Struct/StructPBF.jl")  # Types are defined in the StructPBF Module
using .StructPBF                # Load StructPBF Module

##############
# In&Outputs #
##############
include("IO_dev/IO.jl")
using .IO_dev

##############
# MainSolver #
##############
include("Solver/Solver.jl")
using .Solver

end