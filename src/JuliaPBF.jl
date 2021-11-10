"""
                # Julia Position Based Fluid #

                       (C) Hipgineer
                            
"""
module JuliaPBF
export
    UI_dev,
    Solver,
    StructPBF
include("Struct/StructPBF.jl") # Types are defined in the StructPBF Module
using .StructPBF        # Load StructPBF Module

    """
    User Interface for Developer: \n
        # ====================================================
        Type : Module
        Inner fucntions :
            {AnalysisDataStruct} = UI_dev.parsing_xml_file({xmlFileDir::string})
        # ====================================================
    """
    module UI_dev
        export 
            Parsing_xml_file, 
            Writing_csv_file  
        include("UI_dev/ParsingInput.jl")
        include("UI_dev/WritingOutput.jl")
    end

    """
    PHYSICAL Solver: \n
        # ====================================================
        Type : Module
        Inner fucntions :
            {SimulationDataStruct} = Solver.PreProcessing({AnalysisDataStruct})
            nothing = Solver.Update({SimulationDataStruct},{AnalysisDataStruct}) 
        # ====================================================
    """
    module Solver
        export 
            PreProcessing,
            Update
        include("Solver/PreProcessingFunctions.jl")
        include("Solver/PhysicalFunctions.jl")

        """ 
        PREPROCESSING in SOVER : 
            In this section, allocate the initial analysis variables 
            by creating the particles and the boundary lines.
        """
        function PreProcessing(inAnalysisDataStruct::AnalysisDataStruct)
            inSimulationDataStruct = SimulationDataStruct(GenParticles(inAnalysisDataStruct),
                                                        GenGrids(inAnalysisDataStruct),
                                                        GenPhases(inAnalysisDataStruct),
                                                        GenBoundaries(inAnalysisDataStruct),
                                                        [inAnalysisDataStruct.nMaxParticles]        # number of Alive Particles 
                                                        )
            return inSimulationDataStruct
        end #PreProcessing

        
        """ 
        PHYSICAL CALCULATION : 
            All physics for a dt are calcuated. The time marching
            is conducted in main.jl. So, only physics exist.
        """
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
    end

end