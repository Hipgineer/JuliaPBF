using JuliaPBF.StructPBF

function GenParticles(inAnsDataStruct::AnalysisDataStruct)
    npart = inAnsDataStruct.nMaxParticles
    ar_ParticleData = Vector{ParticleData}(undef,npart)
    for ii in 1:npart
        ar_ParticleData[ii] = ParticleData(
                                inAnsDataStruct.nMaxParticles+1,  # gridID :: Int64
                                Vec2(),                           # vel    :: Vec2
                                Vec2(),                           # pos    :: Vec2
                                Vec2(),                           # temppos:: Vec2
                                0.0,                              # Lambda :: Float64
                                0.0,                              # mass   :: Float64
                                0.0)                              # phase  :: Int64
    end
    FillInitialBox(inAnsDataStruct, ar_ParticleData)
    return ar_ParticleData
end

function GenGrids(inAnsDataStruct::AnalysisDataStruct)
    start_point = inAnsDataStruct.analysisBox.staPoint
    end_point = inAnsDataStruct.analysisBox.endPoint
    grid_size = 2.0 * inAnsDataStruct.kernelRadius
    n_Grid_x = Int(ceil((end_point.x - start_point.x)/grid_size))
    n_Grid_y = Int(ceil((end_point.y - start_point.y)/grid_size))
    
    ini_nNearGrid      = Vector{Int64}(undef,n_Grid_x*n_Grid_y)
    ini_nGridParticles = Vector{Int64}(undef,n_Grid_x*n_Grid_y)
    ini_NearGridIndex  = Vector{Int64}(undef,9*(n_Grid_x-2)*(n_Grid_y-2) + 6*(2*(n_Grid_x-2)+2*(n_Grid_y-2)) + 4*4)
    nong = 0
    for iy in 1:n_Grid_y
        for ix in 1:n_Grid_x
            # 아랫줄
            if iy > 1
                if ix > 1
                    nong+=1
                    ini_NearGridIndex[nong] = ix-1 + (iy-2)*n_Grid_x
                end
                nong+=1
                ini_NearGridIndex[nong] = ix + (iy-2)*n_Grid_x
                if ix < n_Grid_x
                    nong+=1
                    ini_NearGridIndex[nong] = ix+1 + (iy-2)*n_Grid_x
                end
            end
            # 자기줄
            if ix > 1
                nong+=1
                ini_NearGridIndex[nong] = ix-1 + (iy-1)*n_Grid_x
            end
            nong+=1
            ini_NearGridIndex[nong] = ix + (iy-1)*n_Grid_x
            if ix < n_Grid_x
                nong+=1
                ini_NearGridIndex[nong] = ix+1 + (iy-1)*n_Grid_x
            end
            # 윗줄
            if iy < n_Grid_y
                if ix > 1
                    nong+=1
                    ini_NearGridIndex[nong] = ix-1 + iy*n_Grid_x
                end
                nong+=1
                ini_NearGridIndex[nong] = ix + iy*n_Grid_x
                if ix < n_Grid_x
                    nong+=1
                    ini_NearGridIndex[nong] = ix+1 + iy*n_Grid_x
                end
            end
            ii = ix + (iy-1)*n_Grid_x
            ini_nNearGrid[ii] = nong
            ini_nGridParticles[ii] = 0
        end
    end

    return GridData(ini_nNearGrid,ini_NearGridIndex,ini_nGridParticles)
end

function GenPhases(inAnsDataStruct::AnalysisDataStruct)
    ## CREATE BOUNDARY LINES ##
    # Boundary line is a object which shape never
    # change, but only 회전/병진. at this time, it
    # won't be added since defining the method how 
    # treat the boundary condition. 
    # line collision? dummy particles? 
    return []
end

function GenBoundaries(inAnsDataStruct::AnalysisDataStruct)
    ## CREATE BOUNDARY LINES ##
    # Boundary line is a object which shape never
    # change, but only 회전/병진. at this time, it
    # won't be added since defining the method how 
    # treat the boundary condition. 
    # line collision? dummy particles? 
    return []
end

# private

function FillInitialBox(inAnsDataStruct::AnalysisDataStruct, arParticleData::Vector{ParticleData})
    ID = 1
    for initBox_i in 1:length(inAnsDataStruct.a_initialBox)
        initBox_phaseID = inAnsDataStruct.a_initialBox[initBox_i].phaseID
        initBox_box     = inAnsDataStruct.a_initialBox[initBox_i].box
        initBox_vel     = inAnsDataStruct.a_initialBox[initBox_i].vel
        initBox_type    = inAnsDataStruct.a_phases[initBox_phaseID].type
        if initBox_type == "Fluid"
            initBox_name      = inAnsDataStruct.a_phases[initBox_phaseID].Fluid.name
            initBox_size      = inAnsDataStruct.a_phases[initBox_phaseID].Fluid.size
            initBox_density   = inAnsDataStruct.a_phases[initBox_phaseID].Fluid.density
            initBox_viscosity = inAnsDataStruct.a_phases[initBox_phaseID].Fluid.viscosity
            # initBox_mass      = initBox_density * (π*(initBox_size*0.5)^2.0) # Circle
            # initBox_mass      = initBox_density * (initBox_size^2.0) # Box 
            initBox_mass      = initBox_density * ((initBox_size^2.0)*0.85 + (π*(initBox_size*0.5)^2.0)*0.15)
        end
        boxDX = initBox_box.endPoint.x - initBox_box.staPoint.x
        boxDY = initBox_box.endPoint.y - initBox_box.staPoint.y
        for ix in 1:div(boxDX+initBox_size*0.5,initBox_size)
            for iy in 1:div(boxDY+initBox_size*0.5,initBox_size)
                xx = initBox_box.staPoint.x + (ix-0.5)*initBox_size
                yy = initBox_box.staPoint.y + (iy-0.5)*initBox_size
                arParticleData[ID] = ParticleData(
                                        0,              # gridID :: Int64
                                        initBox_vel,    # vel    :: Vec2
                                        Vec2(xx,yy),    # pos    :: Vec2
                                        Vec2(xx,yy),    # temppos:: Vec2
                                        0.0,             # lambda :: Float64
                                        initBox_mass,   # mass   :: Float64
                                        initBox_phaseID)# phase  :: Int64
                ID += 1
            end
        end
    end
end