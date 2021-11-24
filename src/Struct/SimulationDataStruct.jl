"""
Definition of simulation data types for juliaPBF
    All variables are treated using the struct
    in SimulationDataStruct. the result of phy 
    sical calculation will be updated into the
    struct.
"""
## EXPORT TYPES
export 
    ParticleData, 
    BoundaryData, 
    GridData
## EXPORT TYPE FUNCTIONs
export 
    # Change
    changeGridID, 
    changeLambda, 
    changeVel,
    changePos,
    changeTemppos,
    changeMass,
    # Add
    addVel, 
    addPos, 
    addTemppos, 
    addmMass,
    # ETC
    updatePos


""" a Particle Data Type """
struct ParticleData ## Array of Struct
        gridID      ::Int64
        vel         ::Vec2
        pos         ::Vec2
        temppos     ::Vec2
        lambda      ::Float64
        mass        ::Float64
        phase       ::Int64 # SimulationData와 맞춰진. 이걸타고 들어가서 Fluid/Solid 나뉠것임 
end
# CHANGE VALUEs
changeGridID(a::ParticleData, b::Int64)   = ParticleData(b,        a.vel,   a.pos,   a.temppos,   a.lambda,   a.mass,   a.phase)
changeLambda(a::ParticleData, b::Float64) = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos,   b,          a.mass,   a.phase)
changeVel(a::ParticleData, b::Vec2)       = ParticleData(a.gridID, b,       a.pos,   a.temppos,   a.lambda,   a.mass,   a.phase)
changePos(a::ParticleData, b::Vec2)       = ParticleData(a.gridID, a.vel,   b,       a.temppos,   a.lambda,   a.mass,   a.phase)
changeTemppos(a::ParticleData, b::Vec2)   = ParticleData(a.gridID, a.vel,   a.pos,   b,           a.lambda,   a.mass,   a.phase)
changeMass(a::ParticleData, b::Float64)   = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos,   a.lambda,   b,        a.phase)
# ADD VALUEs
addVel(a::ParticleData, b::Vec2)          = ParticleData(a.gridID, a.vel+b, a.pos,   a.temppos,   a.lambda,   a.mass,   a.phase)
addPos(a::ParticleData, b::Vec2)          = ParticleData(a.gridID, a.vel,   a.pos+b, a.temppos,   a.lambda,   a.mass,   a.phase)
addTemppos(a::ParticleData, b::Vec2)      = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos+b, a.lambda,   a.mass,   a.phase)
addMass(a::ParticleData, b::Float64)      = ParticleData(a.gridID, a.vel,   a.pos,   a.temppos,   a.lambda,   a.mass+b, a.phase)
# ETC
updatePos(a::ParticleData)                = ParticleData(a.gridID, a.vel,   a.temppos,a.temppos,  a.lambda,   a.mass,   a.phase)
isless(a::ParticleData,b::ParticleData)   = isless(a.gridID::Int64,b.gridID::Int64) #for Sorting by gridID

""" Boundary Data Type """
struct BoundaryData
    points          ::Vector{Vec2}
    lines           ::Vector{iVec2} # Point Index 짝궁
end
""" Grid Data Type """
struct GridData
    nNearGrid       ::Vector{Int64} # Cumulate 형식
    nearGridIndex   ::Vector{Int64} # Near Grid Index를 1줄행렬로 가지고 있음
    nGridParticles  ::Vector{Int64} # 그리드 내 속한 입자 수 
end
