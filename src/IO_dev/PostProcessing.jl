using JuliaPBF.StructPBF
using Printf
function Writing_ascii_file(inSimDataStruct::SimulationDataStruct, fileName::String)
    interFloat64Array = reshape(reinterpret(Float64, inSimDataStruct.particles),10,:)
    # interInt64Array   = reshape(reinterpret(  Int64, inSimDataStruct.particles),9,:)
    io_buffer = IOBuffer()
    @printf(io_buffer, "vx,vy,px,py,lambda\n")
    for ii in 1:inSimDataStruct.alivedParticles[1]#length(inSimDataStruct.particles)
        @printf(io_buffer, "%10.3f,%10.3f,%10.3f,%10.3f,%10.3f\n",interFloat64Array[2,ii],interFloat64Array[3,ii],interFloat64Array[4,ii],interFloat64Array[5,ii],interFloat64Array[8,ii])
    end 
    write(fileName*".csv", take!(io_buffer))
end



# PRIVATE

function Extract_particle_info()

end
