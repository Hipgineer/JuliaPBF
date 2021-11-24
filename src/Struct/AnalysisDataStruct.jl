"""
Definition of analysis data types for juliaPBF
    All values in AnalysisDataStruct shouldn't
    be changed after input parsing(inputParsin
    g.jl). All variables should be located in 
    SimulationDataStruct.
"""

export 
    TimeStep, 
    AnalysisBox, 
    InitialBox, 
    FluidPropertyData, 
    SolidPropertyData, 
    PhaseData, 
    TensileInstability

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
    vel         ::Vec2
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

mutable struct TensileInstability
    k           ::Float64
    dq          ::Float64
    n           ::Float64
end

TimeStep() = TimeStep(0, 0.0, 0.0, 0.0, 0.0)
FluidPropertyData() = FluidPropertyData("",0,0,0)
SolidPropertyData() = SolidPropertyData("",0,0)
PhaseData() = PhaseData(0,FluidPropertyData(),SolidPropertyData())