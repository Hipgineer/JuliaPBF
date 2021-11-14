using JuliaPBF.StructPBF
using Printf
function Writing_ascii_file(inSimDataStruct::SimulationDataStruct, inAnsDataStruct::AnalysisDataStruct)
    interFloat64Array = reshape(reinterpret(Float64, inSimDataStruct.particles),10,:)
    # interInt64Array   = reshape(reinterpret(  Int64, inSimDataStruct.particles),9,:)
    io_buffer = IOBuffer()
    @printf(io_buffer, "vx\tvy\tpx\tpy\tλ\n")
    for ii in 1:inSimDataStruct.alivedParticles[1]#length(inSimDataStruct.particles)
        @printf(io_buffer, "%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\n",interFloat64Array[2,ii],interFloat64Array[3,ii],interFloat64Array[6,ii],interFloat64Array[7,ii],interFloat64Array[8,ii])
    end 
    write("out.txt", take!(io_buffer))
end



# PRIVATE

function Extract_particle_info()

end
