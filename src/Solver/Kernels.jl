module Kernels 
using JuliaPBF.StructPBF
export 
    Wendland, WendlandGrad, WendlandGradAbs,
    Poly6, Poly6Grad, Poly6GradAbs

    const oneOverPi = 1 / π

    function Wendland(absDelPos::Float64, inAnsDataStruct::AnalysisDataStruct)
        oneOverH= 1/inAnsDataStruct.kernelRadius
        qq      = absDelPos * oneOverH
        alpha   = 1.75*oneOverH*oneOverH*oneOverPi # For 2-Dim
        return alpha * (1- qq*0.5)^4 * (1 + 2.0*qq)
    end

    function WendlandGrad(delPos::Vec2, inAnsDataStruct::AnalysisDataStruct)
        oneOverH= 1/inAnsDataStruct.kernelRadius
        absDelPos = sqrt(abs2(delPos))
        qq      = absDelPos * oneOverH
        alpha   = 1.75*oneOverH*oneOverH*oneOverPi # For 2-Dim
        if (absDelPos < 0.000000000000001)
            return 0.0
        end
        if (2.0 < qq)
            return 0.0
        end
        return (-5 * alpha * (1- qq*0.5)^3 * qq / absDelPos) * delPos
    end

    function WendlandGradAbs(delPos::Vec2, inAnsDataStruct::AnalysisDataStruct)
        oneOverH= 1/inAnsDataStruct.kernelRadius
        absDelPos = sqrt(abs2(delPos))
        qq      = absDelPos * oneOverH
        alpha   = 1.75*oneOverH*oneOverH*oneOverPi # For 2-Dim
        if (absDelPos < 0.000000000000001)
            return 0.0
        end
        if (2.0 < qq)
            return 0.0
        end
        return (-5 * alpha * (1- qq*0.5)^3 * qq)
    end

    function Poly6(absDelPos::Float64, inAnsDataStruct::AnalysisDataStruct)
        oneOverH  = 1/inAnsDataStruct.kernelRadius
        qq        = absDelPos * oneOverH
        alpha     = 4*(oneOverH^2)*oneOverPi # For 2-Dim
        return alpha * (1- qq*qq)^3
    end

    function Poly6Grad(delPos::Vec2, inAnsDataStruct::AnalysisDataStruct)
        oneOverH  = 1/inAnsDataStruct.kernelRadius
        absDelPos = sqrt(abs2(delPos))
        qq        = absDelPos * oneOverH
        alphaGrad = 4*(oneOverH^4)*oneOverPi # For 2-Dim
        if (absDelPos < 0.000000000000001)
            return 0.0
        end
        if (1.0 < qq)
            return 0.0
        end
        return - 6 * alphaGrad * (1- qq*qq)^2 * delPos
    end
end
