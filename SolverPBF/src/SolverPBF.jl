module SolverPBF

using StructPBF
export SolverPreProcessing
########################################################
##                PREPROCESSING in SOVER              ##
########################################################
# In this section, allocate the initial analysis vari- #
# ables by creating the particles and the boundary li- #
# nes.                                                 #
########################################################
include("./PreProcessingFunctions.jl")
function SolverPreProcessing(inAnalysisDataStruct::AnalysisDataStruct)
    inSimulationDataStruct = SimulationDataStruct(GenParticles(inAnalysisDataStruct),
                                                  GenGrids(inAnalysisDataStruct),
                                                  GenPhases(inAnalysisDataStruct),
                                                  GenBoundaries(inAnalysisDataStruct),
                                                  [inAnalysisDataStruct.nMaxParticles]        # number of Alive Particles 
                                                  )
    return inSimulationDataStruct
end

########################################################
##                PHYSICAL CALCULATION                ##
########################################################
# All physics for a dt are calcuated. The time marchi- #
# ng is conducted in main.jl. So, only physics exist.  #
########################################################
include("./PhysicalFunctions.jl")
function Update(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
    Δt = inAnsDataStruct.timeStep.dt
    gravity = inAnsDataStruct.gravity
    
    println("Calculate Grid ID: ")
    @time CalculateGridId(inSimDataStruct, inAnsDataStruct)
    println("Sorting by Grid ID: ")
    @time sort!(inSimDataStruct.particles)
    println("Calculate Gravity Force: ")
    @time CalculateGravityForce(inSimDataStruct,gravity,Δt)
    println("Calculate Something with Near Particles: ")
    @time CalculateSomethingWithNearParticles(inSimDataStruct, inAnsDataStruct)

    println("Calculate Lambda: ")
    @time CalculateLambda(inSimDataStruct, inAnsDataStruct)
end

end # MODULE "PbdSolver2D" END