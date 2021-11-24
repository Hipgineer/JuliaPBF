""" 
< DEFINITION of DATA TYPES for JuliaPBF >
"""
module StructPBF
import Base.+, Base.*, Base.-, Base.isless, Base.abs2 # To add generic functions
export 
    AnalysisDataStruct,
    SimulationDataStruct

    include("BasicStruct.jl")
    include("AnalysisDataStruct.jl")
    include("SimulationDataStruct.jl")

    struct AnalysisDataStruct
        timeStep            ::TimeStep
        endTime             ::Float64
        gravity             ::Vec2
        analysisBox         ::Box2
        nMaxParticles       ::Int64
        maxParticleSize     ::Float64
        kernelRadius        ::Float64
        tensileInstability  ::TensileInstability
        a_initialBox        ::Vector{InitialBox}
        a_phases            ::Vector{PhaseData}
    end

    struct SimulationDataStruct
        particles           ::Vector{ParticleData} # For AoS
        grids               ::GridData
        phases              ::Vector{PhaseData}
        boundaries          ::Vector{BoundaryData}
        alivedParticles     ::Vector{Int64} # Fluids / Solids
    end

end