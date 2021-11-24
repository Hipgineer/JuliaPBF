"""
Definition of base data types for juliaPBF
    They are used in both AnalysisDataStruct 
    and SimulationDataStruct.
"""

export Vec2, Box2

"""2D Vector Data Type (Float64)"""
struct Vec2
    x           ::Float64
    y           ::Float64
end

"""2D Vector Data Type (Int64)"""
struct iVec2
    x           ::Int64
    y           ::Int64
end

"""2D Box Data Type"""
struct Box2
    staPoint    ::Vec2
    endPoint    ::Vec2
end

# generic functions 
+(a::Vec2,b::Vec2) = Vec2(a.x+b.x,a.y+b.y)
-(a::Vec2,b::Vec2) = Vec2(a.x-b.x,a.y-b.y)
*(a::Vec2,b::Vec2) = Vec2(a.x*b.x,a.y*b.y)
+(a::Vec2,b::Float64) = Vec2(a.x+b,a.y+b); +(a::Float64,b::Vec2) = Vec2(a+b.x,a+b.y)
-(a::Vec2,b::Float64) = Vec2(a.x-b,a.y-b); -(a::Float64,b::Vec2) = Vec2(a-b.x,a-b.y)
*(a::Vec2,b::Float64) = Vec2(a.x*b,a.y*b); *(a::Float64,b::Vec2) = Vec2(a*b.x,a*b.y)
abs2(a::Vec2,b::Vec2) = (a.x-b.x)^2 + (a.y-b.y)^2
abs2(a::Vec2) = a.x^2 + a.y^2

# initialize
Vec2() = Vec2(0.0,0.0)
iVec2() = iVec2(0,0)
Box2() = Box2(Vec2(),Vec2())