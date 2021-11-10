mutable struct Vec2
    x::Float64
    y::Float64
end
struct Vec2Array
    x::Vector{Float64}
    y::Vector{Float64}
end
mutable struct ParticleData
    velx::Float64
    vely::Float64
    posx::Float64
    posy::Float64
end
ParticleData() = ParticleData(0,0,0,0)

struct ParticleDataSoA
    velx::Vector{Float64}
    vely::Vector{Float64}
    posx::Vector{Float64}
    posy::Vector{Float64}
    vel::Vec2Array
    pos::Vec2Array
end

using BenchmarkTools
##
N = 100000
aosArray = Vector{ParticleData}(undef,N)
iniit = ParticleData(0,0,0,0)
for ii in 1:N
    aosArray[ii] = ParticleData(0,0,0,0)
end
soaArray = ParticleDataSoA(
                        Array{Float64}(undef,N), 
                        Array{Float64}(undef,N),
                        Array{Float64}(undef,N),
                        Array{Float64}(undef,N),
                        Vec2Array(
                            Array{Float64}(undef,N),
                            Array{Float64}(undef,N)),
                        Vec2Array(
                            Array{Float64}(undef,N),
                            Array{Float64}(undef,N))
                        )


##
function aosRead(ar::Vector{ParticleData},N::Int)
    for ii in 1:N
        ar[ii].velx += ii
        ar[ii].vely += ii+1
        ar[ii].posx = ar[ii].posy
        ar[ii].posy = ar[ii].posx
    end
end

function soaRead(ar::ParticleDataSoA,N::Int)
    for ii in 1:N
        ar.velx[ii] += ii
        ar.vely[ii] += ii+1
        ar.posx[ii] = ar.posy[ii]
        ar.posy[ii] = ar.posx[ii]
    end
end

function soaReadvec2array(ar::ParticleDataSoA,N::Int)
    for ii in 1:N
        ar.vel.x[ii] += i
        ar.vel.y[ii] += ii+1
        ar.pos.x[ii] += N*ar.pos.y[ii]
        ar.pos.y[ii] += N*ar.pos.x[ii]
    end
end

function soaReadC(ar::ParticleDataSoA,N::Int)
    for ii in 1:N
        ar.velx[ii] += ii
        ar.vely[ii] += ii+1
        ar.posx[ii] += ar.velx[ii]*0.1
        ar.posy[ii] += ar.vely[ii]*0.1
    end
end


## array of immutable struct or array of mutable struct
# 두가지 비교하기, 뮤터블로 하나한고치는 것과, 이뮤터블로 매서드(generalFunction)만들어서 사용하는거랑 누가 빠름?
# 이뮤터블 제네릭펑션이 호얼신 빠름 여기선 5배정도는 차이남. 이뮤터블이 답이다! 
import Base.+
mutable struct mVec2 
    x :: Float64
    y :: Float64
end
struct imVec2
    x :: Float64
    y :: Float64
end
# plusV2(a::imVec2,b::imVec2) = imVec2(a.x+b.x,a.y+b.y)
function +(a::imVec2,b::imVec2)
    return imVec2(a.x+b.x,a.y+b.y)
end
mulV2(a::imVec2,b::imVec2) = imVec2(a.x*b.x,a.y*b.y)
mulV2(a::imVec2,b::Float64) = imVec2(a.x*b,a.y*b)
# N = 1000
# mArray = Vector{mVec2}(undef,N)
# imArray = Vector{imVec2}(undef,N)
# for ii in 1:N
#     mArray[ii]=mVec2(1.0,1.0)
#     imArray[ii]=imVec2(1.0,1.0)
# end


function mArrayWrite(ar::Vector{mVec2})
    for ii in 1:length(ar)
        ar[ii].x += 3.0*0.1
        ar[ii].y += 4.0*0.1
    end
end
function imArrayWrite(ar::Vector{imVec2})
    for ii in 1:length(ar)
        ar[ii] = ar[ii]+mulV2(imVec2(3.0,4.0),0.1)
    end
end
##

N = 1000000
mArray = Vector{mVec2}(undef,N)
imArray = Vector{imVec2}(undef,N)
for ii in 1:N
    mArray[ii]=mVec2(1.0,1.0)
    imArray[ii]=imVec2(1.0,1.0)
end
@time mArrayWrite(mArray)
@time imArrayWrite(imArray)