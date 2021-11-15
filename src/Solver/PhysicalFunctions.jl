using JuliaPBF.StructPBF

function CalculateGravityForce(inSimDataStruct::SimulationDataStruct,gravity::Vec2, Δt::Float64)
    for ii in 1:length(inSimDataStruct.particles)
        inSimDataStruct.particles[ii] = velAdd(inSimDataStruct.particles[ii], gravity*Δt)
        inSimDataStruct.particles[ii] = tempposAdd(inSimDataStruct.particles[ii], inSimDataStruct.particles[ii].vel*Δt)
    end
end

function CalculateGridId(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
    start_point = inAnsDataStruct.analysisBox.staPoint
    end_point = inAnsDataStruct.analysisBox.endPoint
    grid_size = 2.0 * inAnsDataStruct.kernelRadius
    n_Grid_x = Int(ceil((end_point.x - start_point.x)/grid_size))
    n_Grid_y = Int(ceil((end_point.y - start_point.y)/grid_size))
    totalGridNum = n_Grid_x * n_Grid_y

    for gn in 1:totalGridNum 
        inSimDataStruct.grids.nGridParticles[gn] = 0 
    end
    alivedParticles = 0

    for ii in 1:length(inSimDataStruct.particles)
        a = Int64(ceil((inSimDataStruct.particles[ii].pos.x-start_point.x)/grid_size)) + (Int64(ceil((inSimDataStruct.particles[ii].pos.y-start_point.y)/grid_size)) - 1)*n_Grid_x
        if (totalGridNum < a)||(a < 0)
            inSimDataStruct.particles[ii] = gridIDChange(inSimDataStruct.particles[ii],totalGridNum+1)
            continue
        end
        inSimDataStruct.particles[ii] = gridIDChange(inSimDataStruct.particles[ii],a)
        alivedParticles += 1
        inSimDataStruct.grids.nGridParticles[a] +=1
    end
    accumulate!(+, inSimDataStruct.grids.nGridParticles, inSimDataStruct.grids.nGridParticles)
    inSimDataStruct.alivedParticles[1] = alivedParticles
    # 얘를 딕셔너리에 행렬로 저장해놓음 어때? 그리드ID를 계속 부여하는게 아니라, 그리드id는 그대로 있고 거기에 입자 id 백터를 연결해 주는거지!
end

function CalculateLambda(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
    #이거를 어떤 폼으로 만들어 버리는건 어때? 가능한가?
    for ii in 1: inSimDataStruct.alivedParticles[1] # length(inSimDataStruct.particles) #
        I_PARTICLE = inSimDataStruct.particles[ii]
        density0   = inAnsDataStruct.a_phases[I_PARTICLE.phase].Fluid.density
        I_density  = 0.0 

        epsilon = 0.000000000001
        kernel = 0.0
        I_kConstr  = 0.0
        I_LambdaDen= 0.0

        iGridID = I_PARTICLE.gridID
        gsta = iGridID == 1 ? 1 : (inSimDataStruct.grids.nNearGrid[iGridID-1]+1)
        gend = inSimDataStruct.grids.nNearGrid[iGridID]     
        for gg in gsta:gend
            gridIndex = inSimDataStruct.grids.nearGridIndex[gg]
            pjsta = gridIndex == 1 ? 1 : (inSimDataStruct.grids.nGridParticles[gridIndex-1]+1)
            pjend = inSimDataStruct.grids.nGridParticles[gridIndex]
            for jj in pjsta:pjend
                J_PARTICLE = inSimDataStruct.particles[jj]
                delPos  = I_PARTICLE.pos - J_PARTICLE.pos
                absDelPos2 = abs2(delPos)
                absDelPos  = sqrt(absDelPos2)
                if absDelPos < 2*inAnsDataStruct.kernelRadius

                    kernel = CalculateKernel(absDelPos, inAnsDataStruct)
                    I_density   += I_PARTICLE.mass * kernel
                    
                    if ii == jj
                        continue
                    end

                    if absDelPos > epsilon
                        kernelv= CalculateKernel(delPos,inAnsDataStruct)
                        I_kConstr   += kernelv*(J_PARTICLE.mass/density0)
                        I_LambdaDen += abs2(kernelv*(J_PARTICLE.mass/density0))
                    end

                end
            end
        end
        println(ii,", ", I_density)
        I_constraint = I_density / density0  - 1.0
        I_LambdaDen  += abs2(I_kConstr)
        inSimDataStruct.particles[ii] = lambdaChange(I_PARTICLE, -I_constraint / (I_LambdaDen+epsilon))
    end
end

function CalculatePositionCorrection(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
    #이거를 어떤 폼으로 만들어 버리는건 어때? 가능한가?
    for ii in 1: inSimDataStruct.alivedParticles[1] # length(inSimDataStruct.particles) #
        I_PARTICLE = inSimDataStruct.particles[ii]
        density0   = inAnsDataStruct.a_phases[I_PARTICLE.phase].Fluid.density
        I_density  = 0.0 

        epsilon = 0.000000000001
        positionCorrection = 0.0
        
        iGridID = I_PARTICLE.gridID
        gsta = iGridID == 1 ? 1 : (inSimDataStruct.grids.nNearGrid[iGridID-1]+1)
        gend = inSimDataStruct.grids.nNearGrid[iGridID]     
        for gg in gsta:gend
            gridIndex = inSimDataStruct.grids.nearGridIndex[gg]
            pjsta = gridIndex == 1 ? 1 : (inSimDataStruct.grids.nGridParticles[gridIndex-1]+1)
            pjend = inSimDataStruct.grids.nGridParticles[gridIndex]
            for jj in pjsta:pjend
                J_PARTICLE = inSimDataStruct.particles[jj]
                delPos  = I_PARTICLE.pos - J_PARTICLE.pos
                absDelPos2 = abs2(delPos)
                absDelPos  = sqrt(absDelPos2)
                if absDelPos < 2*inAnsDataStruct.kernelRadius
                    if absDelPos > epsilon
                        kernelv= CalculateKernel(delPos,inAnsDataStruct)
                        #Tensile Instability
                        dq = 0.2
                        k  = 0.1
                        n  = 4.0
                        kernela= CalculateKernel(absDelPos,inAnsDataStruct)
                        kernelb= CalculateKernel(dq*inAnsDataStruct.kernelRadius,inAnsDataStruct)
                        scorr = -k*(kernela/kernelb)^n
                        #
                        positionCorrection += (I_PARTICLE.lambda + J_PARTICLE.lambda + scorr)*kernelv*(1/density0)
                    end
                end
            end
        end
        inSimDataStruct.particles[ii] = tempposAdd(inSimDataStruct.particles[ii], positionCorrection)
    end
end

function CalculateSomethingWithNearParticles(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
    #이거를 어떤 폼으로 만들어 버리는건 어때? 가능한가?
    for ii in 1: inSimDataStruct.alivedParticles[1] # length(inSimDataStruct.particles) #
        I_PARTICLE = inSimDataStruct.particles[ii]

        iGridID = I_PARTICLE.gridID
        gsta = iGridID == 1 ? 1 : (inSimDataStruct.grids.nNearGrid[iGridID-1]+1)
        gend = inSimDataStruct.grids.nNearGrid[iGridID]

        for gg in gsta:gend
            gridIndex = inSimDataStruct.grids.nearGridIndex[gg]
            pjsta = gridIndex == 1 ? 1 : (inSimDataStruct.grids.nGridParticles[gridIndex-1]+1)
            pjend = inSimDataStruct.grids.nGridParticles[gridIndex]
            for jj in pjsta:pjend
                J_PARTICLE = inSimDataStruct.particles[jj]
                delPos  = I_PARTICLE.pos - J_PARTICLE.pos
                absDelPos2 = abs2(delPos)
                absDelPos  = sqrt(absDelPos2)
                if absDelPos < 2*inAnsDataStruct.kernelRadius
                    #물리계산이 이뤄지는 곳
                end
            end
        end

    end
end

# private

function CalculateKernel(absDelPos::Float64, inAnsDataStruct::AnalysisDataStruct)
    H     = inAnsDataStruct.kernelRadius
    qq    = absDelPos / H
    alpha = 7 / (4*π*H*H) # For 2-Dim
    return alpha * (1- qq*0.5)^4 * (1 + 2.0*qq)
end

function CalculateKernel(delPos::Vec2, inAnsDataStruct::AnalysisDataStruct)
    H         = inAnsDataStruct.kernelRadius
    absDelPos = sqrt(abs2(delPos))
    qq        =  absDelPos / H
    alpha = 7 / (4*π*H*H) # For 2-Dim
    if (absDelPos < 0.000000000000001)
        return 0.0
    end
    return (-5 * alpha * (1- qq*0.5)^3 * qq / absDelPos) * delPos
end
# function UpdateGravityParallel(inSimulationDataStruct::SimulationDataStruct,gravity::Vec2, Δt::Real)
#     Threads.@threads for ii in 1:length(inSimulationDataStruct.particles.pos.x)
#         inSimulationDataStruct.particles.vel.x[ii] += gravity.x * Δt
#         inSimulationDataStruct.particles.vel.y[ii] += gravity.y * Δt 

#         inSimulationDataStruct.particles.pos.x[ii] += Δt * inSimulationDataStruct.particles.vel.x[ii]
#         inSimulationDataStruct.particles.pos.y[ii] += Δt * inSimulationDataStruct.particles.vel.y[ii]
#     end
# end