""" PHYSICAL Solver: \n
# ==================================================== \n
Type : Module \n
Inner fucntions : \n
    {SimulationDataStruct} = Solver.PreProcessing({AnalysisDataStruct}) \n
    nothing = Solver.Update({SimulationDataStruct},{AnalysisDataStruct}) \n
# ==================================================== \n """
module Solver
export 
    PreProcessing,
    Update

include("InitializingFunctions.jl")
include("PhysicalFunctions.jl")

    """ PREPROCESSING in SOVER """
    function PreProcessing(inAnalysisDataStruct::AnalysisDataStruct)
        inSimulationDataStruct = SimulationDataStruct(GenParticles(inAnalysisDataStruct),
                                                    GenGrids(inAnalysisDataStruct),
                                                    GenPhases(inAnalysisDataStruct),
                                                    GenBoundaries(inAnalysisDataStruct),
                                                    [inAnalysisDataStruct.nMaxParticles]        # number of Alive Particles 
                                                    )
        return inSimulationDataStruct
    end #PreProcessing

    
    """ Physical Calculation for a Time Step """
    function Update(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
        Δt = inAnsDataStruct.timeStep.dt
        gravity = inAnsDataStruct.gravity
        
        CalculateGravityForce(inSimDataStruct,gravity,Δt)
        for iteration in 1:3
            CalculateGridId(inSimDataStruct, inAnsDataStruct)
            sort!(inSimDataStruct.particles)
            CalculateLambda(inSimDataStruct, inAnsDataStruct)
            CalculatePositionCorrection(inSimDataStruct, inAnsDataStruct)
        end
        CalculateUpdate(inSimDataStruct,Δt)
    end
end