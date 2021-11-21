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

    """ User Interface for Developer: \n
        # ==================================================== \n
        Type : Module \n
        Inner fucntions : \n
            {AnalysisDataStruct} = UI_dev.parsing_xml_file({xmlFileDir::string}) \n
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

            # println("Calculate Gravity Force: ")
            # @time 
            CalculateGravityForce(inSimDataStruct,gravity,Δt)
            # println("Calculate Something with Near Particles: ")
            # @time CalculateSomethingWithNearParticles(inSimDataStruct, inAnsDataStruct)
            for iteration in 1:3
                # println(iteration, "-Calculate Grid ID: ")
                # @time 
                CalculateGridId(inSimDataStruct, inAnsDataStruct)
                # println(iteration, "-Sorting by Grid ID: ")
                # @time 
                sort!(inSimDataStruct.particles)
                # println(iteration,"-Calculate Lambda: ")
                # @time 
                CalculateLambda(inSimDataStruct, inAnsDataStruct)
                # println(iteration,"-Calculate Position Correction: ")
                # @time 
                CalculatePositionCorrection(inSimDataStruct, inAnsDataStruct)
            end
            # println("CalculateUpdate: ")
            # @time 
            CalculateUpdate(inSimDataStruct,Δt)
        end
    end

end