using LightXML
using JuliaPBF.StructPBF

function Parsing_xml_file(xmldir::String)
        
    # OPEN XML OBJECT
    xdoc = parse_file(xmldir) # xmldir = "./input.xml"
    xroot = root(xdoc)  
    if (name(xroot) != "AnalysisSetting")
        println("CHECK THE XML")
    end

    in_timeStep         = TimeStep()
    in_gravity          = Vec2()
    in_analysisBox      = Box2()
    in_nMaxParticles    = 0
    in_maxParticleSize  = 0.0
    in_a_initialBoxes   = []
    in_a_phases         = []

    # READ XML NODES
    for depth1 in child_nodes(xroot)
    # AnalysisData

        if name(depth1) == "TimeStep"
            in_type = parse(Int64, attribute(XMLElement(depth1),"type"))
            if in_type == 1 # Fixed Time Step
                in_dt    = parse(Float64, attribute(XMLElement(depth1),"dt"))
                in_cfl   = -1
                in_dtMin = -1
                in_dtMax = -1
            elseif type == 2 # Varies Time Step
                in_dt     = -1
                in_cfl    = parse(Float64, attribute(XMLElement(depth1),"cfl"))
                in_dtMin  = parse(Float64, attribute(XMLElement(depth1),"minDt"))
                in_dtMax  = parse(Float64, attribute(XMLElement(depth1),"maxDt"))
            else
                ErrorException("Check Tims Step")
            end
            in_timeStep = TimeStep(in_type,in_dt,in_cfl,in_dtMin,in_dtMax)
        end

        if name(depth1) == "Gravity"
            in_gx = parse(Float64, attribute(XMLElement(depth1),"x"))
            in_gy = parse(Float64, attribute(XMLElement(depth1),"y"))
            in_gravity = Vec2(in_gx,in_gy)
        end

        if name(depth1) == "Particles"
            in_nMaxParticles   = parse(Int64, attribute(XMLElement(depth1),"nMaxParticles"))
            in_maxParticleSize = parse(Float64, attribute(XMLElement(depth1),"maxParticleSize"))
        end

        if name(depth1) == "AnalysisBox"
            in_startPoint = Vec2(parse(Float64, attribute(XMLElement(depth1),"startX")), parse(Float64, attribute(XMLElement(depth1),"startY")))
            in_endPoint   = Vec2(parse(Float64, attribute(XMLElement(depth1),"endX")), parse(Float64, attribute(XMLElement(depth1),"endY")))
            in_analysisBox = Box2(in_startPoint, in_endPoint)
        end
        
        if name(depth1) == "InitialBox"
            for depth2 in child_nodes(depth1)
                if name(depth2) == "initBox"
                    in_phaseID     = parse(Int64, attribute(XMLElement(depth2),"phaseID"))
                    in_startPoint  = Vec2(parse(Float64, attribute(XMLElement(depth2),"startX")), parse(Float64, attribute(XMLElement(depth2),"startY")))
                    in_endPoint    = Vec2(parse(Float64, attribute(XMLElement(depth2),"endX")),   parse(Float64, attribute(XMLElement(depth2),"endY")))
                    in_initialBox  = Box2(in_startPoint, in_endPoint)
                    in_a_initialBoxes = push!(in_a_initialBoxes, InitialBox(in_phaseID,in_initialBox))
                end
            end
        end
        
        if name(depth1) == "PhaseProperties"
            for depth2 in child_nodes(depth1)
                if name(depth2) == "phase"
                    if attribute(XMLElement(depth2),"type") == "Fluid"
                        in_type = attribute(XMLElement(depth2),"type")
                        in_name = attribute(XMLElement(depth2),"name")
                        in_size = parse(Float64, attribute(XMLElement(depth2),"size"))
                        in_density = parse(Float64, attribute(XMLElement(depth2),"density"))
                        in_viscosity = parse(Float64, attribute(XMLElement(depth2),"viscosity"))
                        in_a_phases = push!(in_a_phases, PhaseData(in_type, FluidPropertyData(in_name,in_size,in_density,in_viscosity), SolidPropertyData()))
                    elseif attribute(XMLElement(depth2),"type") == "Solid"
                        in_type = attribute(XMLElement(depth2),"type")
                        in_name = attribute(XMLElement(depth2),"name")
                        in_size = parse(Float64, attribute(XMLElement(depth2),"size"))
                        in_density = parse(Float64, attribute(XMLElement(depth2),"density"))
                        in_a_phases = push!(in_a_phases, PhaseData(in_type, FluidPropertyData(), SolidPropertyData(in_name,in_size,in_density)))
                    end
                end
            end
        end

        # 작업 중
        if name(depth1) == "Boundaries"
            # for depth2 in child_nodes(depth1)
            #     if name(depth2) == "Line"
            #         in_startPoint = Vec2(parse(Float64, attribute(XMLElement(depth1),"startX")), parse(Float64, attribute(XMLElement(depth1),"startY")))
            #         in_endPoint   = Vec2(parse(Float64, attribute(XMLElement(depth1),"endX")), parse(Float64, attribute(XMLElement(depth1),"endY")))
            #         # in_BoundaryLines = Box2(in_startPoint, in_endPoint)
            #     end
            #     if name(depth2) == "Box"
            #         in_startPoint = Vec2(parse(Float64, attribute(XMLElement(depth1),"startX")), parse(Float64, attribute(XMLElement(depth1),"startY")))
            #         in_endPoint   = Vec2(parse(Float64, attribute(XMLElement(depth1),"endX")), parse(Float64, attribute(XMLElement(depth1),"endY")))
            #         # in_boundaryBox = Box2(in_startPoint, in_endPoint)
            #     end
            # end

        end

    end


    # OUTPUT
    return AnalysisDataStruct(
                        in_timeStep,               # Struct TimeStep(type, dt, cfl, dtMin, dtMax) 
                        in_gravity,                # Struct Gravity(x,y)
                        in_analysisBox,            # Struct Box2(staPoint, endPoint)
                        in_nMaxParticles,          # Int64
                        in_maxParticleSize,        # Float64
                        in_maxParticleSize*1.5,    # Float64 (Kernel Radius)
                        in_a_initialBoxes,         # Vector{Box2}       // Struct Box2(staPoint, endPoint)
                        in_a_phases                # Vector{PhaseData}} // Struct PhaseData(type, Fluid, Solid)
                        )

end # function parsing_xml_file