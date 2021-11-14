module StructPBF
import Base.+, Base.*, Base.-, Base.isless, Base.abs2
## Stnadard
# 
        
## BASE DATA STRUCT
# Base data structs are used in both Analysi
# sDataStruct and SimulationDataStruct.
export Vec2, Vec2Array, iVec2, Box2
    struct Vec2
        x           ::Float64
        y           ::Float64
    end
    +(a::Vec2,b::Vec2) = Vec2(a.x+b.x,a.y+b.y)
    -(a::Vec2,b::Vec2) = Vec2(a.x-b.x,a.y-b.y)
    *(a::Vec2,b::Vec2) = Vec2(a.x*b.x,a.y*b.y)
    +(a::Vec2,b::Float64) = Vec2(a.x+b,a.y+b); +(a::Float64,b::Vec2) = Vec2(a+b.x,a+b.y)
    -(a::Vec2,b::Float64) = Vec2(a.x-b,a.y-b); -(a::Float64,b::Vec2) = Vec2(a-b.x,a-b.y)
    *(a::Vec2,b::Float64) = Vec2(a.x*b,a.y*b); *(a::Float64,b::Vec2) = Vec2(a*b.x,a*b.y)
    abs2(a::Vec2,b::Vec2) = (a.x-b.x)^2 + (a.y-b.y)^2
    abs2(a::Vec2) = a.x^2 + a.y^2


    struct Vec2Array
        x           ::Vector{Float64}
        y           ::Vector{Float64}
    end

    struct iVec2
        x           ::Int64
        y           ::Int64
    end

    struct Box2
        staPoint    ::Vec2
        endPoint    ::Vec2
    end

## ANALYSIS DATA STRUCT(INPUT PARSING)
# All values in AnalysisDataStruct shouldn't
# be changed after input parsing(inputParsin
# g.jl). All variables should be located in 
# SimulationDataStruct.
export TimeStep, AnalysisBox, InitialBox, FluidPropertyData, SolidPropertyData, PhaseData
export AnalysisDataStruct
    # ELEMENT STRUCT
    struct TimeStep
        type        ::Int64
        dt          ::Float64
        cfl         ::Float64
        dtMin       ::Float64
        dtMax       ::Float64
    end
    struct InitialBox
        phaseID     ::Int64
        box         ::Box2
    end
    struct FluidPropertyData
        name        ::String
        size        ::Float64
        density     ::Float64
        viscosity   ::Float64
    end
    struct SolidPropertyData
        name        ::String
        size        ::Float64
        density     ::Float64
    end
    struct PhaseData
        type        ::String   # FluidPropertyArray or SolidPropertyArray?
        Fluid       ::FluidPropertyData
        Solid       ::SolidPropertyData
    end
    # MAIN STRUCT
    struct AnalysisDataStruct
        timeStep        ::TimeStep
        gravity         ::Vec2
        analysisBox     ::Box2
        nMaxParticles   ::Int64
        maxParticleSize ::Float64
        kernelRadius    ::Float64
        a_initialBox    ::Vector{InitialBox}
        a_phases        ::Vector{PhaseData}
    end


## SIMULATION DATA STRUCT
# All variables are treated using the struct
# in SimulationDataStruct. the result of phy 
# sical calculation will be updated into the
# struct.
export ParticleData, BoundaryData, GridData
export SimulationDataStruct
    # ELEMENT STRUCT 
    struct ParticleData ## Array of Struct
            gridID      ::Int64
            vel         ::Vec2
            pos         ::Vec2
            temppos     ::Vec2
            lambda      ::Float64
            mass        ::Float64
            phase       ::Int64 # SimulationData와 맞춰진. 이걸타고 들어가서 Fluid/Solid 나뉠것임 
    end
    export gridIDChange, lambdaChange, velAdd, posAdd, tempposAdd, massAdd
    gridIDChange(a::ParticleData, b::Int64)   = ParticleData(b,        a.vel,   a.pos,   a.temppos,   a.lambda,   a.mass,   a.phase)
    lambdaChange(a::ParticleData, b::Float64) = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos,   b,          a.mass,   a.phase)
    velAdd(a::ParticleData, b::Vec2)          = ParticleData(a.gridID, a.vel+b, a.pos,   a.temppos,   a.lambda,   a.mass,   a.phase)
    posAdd(a::ParticleData, b::Vec2)          = ParticleData(a.gridID, a.vel,   a.pos+b, a.temppos,   a.lambda,   a.mass,   a.phase)
    tempposAdd(a::ParticleData, b::Vec2)      = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos+b, a.lambda,   a.mass,   a.phase)
    massAdd(a::ParticleData, b::Float64)      = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos,   a.lambda,   a.mass+b, a.phase)
    isless(a::ParticleData,b::ParticleData)   = isless(a.gridID::Int64,b.gridID::Int64) #for Sorting by gridID

    struct BoundaryData
        points      ::Vector{Vec2}
        lines       ::Vector{iVec2} # Point Index 짝궁
    end
    struct GridData
        nNearGrid     ::Vector{Int64} # Cumulate 형식
        nearGridIndex ::Vector{Int64} # Near Grid Index를 1줄행렬로 가지고 있음
        nGridParticles::Vector{Int64} # 그리드 내 속한 입자 수 
    end
    # MAIN STRUCT
    struct SimulationDataStruct
        # particles   ::ParticleData # For SoA
        particles       ::Vector{ParticleData} # For AoS
        grids           ::GridData
        phases          ::Vector{PhaseData}
        boundaries      ::Vector{BoundaryData}
        alivedParticles ::Vector{Int64} #mutable로 하려고 벡터로지정;;;
    end


## INITIALIZE 
    Vec2() = Vec2(0.0,0.0)
    Box2() = Box2(Vec2(),Vec2())
    TimeStep() = TimeStep(0, 0.0, 0.0, 0.0, 0.0)
    FluidPropertyData() = FluidPropertyData("",0,0,0)
    SolidPropertyData() = SolidPropertyData("",0,0)
    PhaseData() = PhaseData(0,FluidPropertyData(),SolidPropertyData())
end