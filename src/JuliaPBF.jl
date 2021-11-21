""" 
    Julia Position Based Fluid

          (C) Hipgineer
             Jaybin         
              2021
                        
"""
module JuliaPBF
export
    IO_dev,
    Solver,
    StructPBF
include("Struct/StructPBF.jl") # Types are defined in the StructPBF Module
using .StructPBF        # Load StructPBF Module


    """ IN&OUT INTERFACE FOR SOLVER DEVELOPING: \n
        # ==================================================== \n
        Type : Module \n
        Inner fucntions : \n
            {AnalysisDataStruct} = UI_dev.parsing_xml_file(xmlFileDir::string) \n
                 nothing         = UI_dev.Writing_ascii_file(inSimDataStruct::SimulationDataStruct,  fileName::string) \n
        # ==================================================== \n """
    module IO_dev
        export 
            # PreProcessing
            Parsing_xml_file, 
            # PostProcessing
            Writing_ascii_file

        include("IO_dev/PreProcessing.jl")
        include("IO_dev/PostProcessing.jl")
    end

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
        include("Solver/PreProcessingFunctions.jl")
        include("Solver/PhysicalFunctions.jl")

        """ PREPROCESSING in SOVER : \n
            In this section, allocate the initial analysis variables
            by creating the particles and the boundary lines. \n """
        function PreProcessing(inAnalysisDataStruct::AnalysisDataStruct)
            inSimulationDataStruct = SimulationDataStruct(GenParticles(inAnalysisDataStruct),
                                                        GenGrids(inAnalysisDataStruct),
                                                        GenPhases(inAnalysisDataStruct),
                                                        GenBoundaries(inAnalysisDataStruct),
                                                        [inAnalysisDataStruct.nMaxParticles]        # number of Alive Particles 
                                                        )
            return inSimulationDataStruct
        end #PreProcessing

        
        """ PHYSICAL CALCULATION : \n
            All physics for a dt are calcuated. The time marching
            is conducted in main.jl. So, only physics exist. \n """
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

end