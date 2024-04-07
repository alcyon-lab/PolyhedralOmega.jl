using AbstractAlgebra

function ComputeRationalFunction(cone::Cone{T}, parallelepipeds::Vector{Vector{Int}}) where {T<:Number}
    VV = [string("x", i) for i in 1:length(cone.apex)]
    S, X = polynomial_ring(QQ, VV)
    function RationalFunctionOf(z::Vector{<:Number})
        tmp = 1
        for i in eachindex(z)
            tmp = tmp * (X[i]^Int(z[i]))
        end
        return tmp
    end

    num = 0
    for p in parallelepipeds
        num += RationalFunctionOf(p)
    end

    den = 1
    for ray in cone.rays
        den *= (1 - RationalFunctionOf(ray.direction))
    end

    return CombinationOfRationalFunctions(Pair(num * (-1)^(!cone.sign), den))
end


function ComputeRationalFunctionStr(cone::Cone{T}, parallelepipeds::Vector{Vector{Int}}) where {T<:Number}
    function RationalFunctionOf(z::Vector{<:Number})
        tmp = ""
        for i in eachindex(z)
            if length(tmp) > 0
                tmp = tmp * " * " * "x$(i)^($(z[i]))"
            else
                tmp = "x$(i)^($(z[i]))"
            end
        end
        return "(" * tmp * ")"
    end
    num = ""
    for p in parallelepipeds
        if (length(num) > 0)
            num = num * " + " * RationalFunctionOf(p)
        else
            num = RationalFunctionOf(p)
        end
    end
    den = ""
    for ray in cone.rays
        if (length(den) > 0)
            den = den * " * " * "(1 - $(RationalFunctionOf(ray.direction)))"
        else
            den = "(1 - $(RationalFunctionOf(ray.direction)))"
        end
    end
    res = "(" * num * ")/(" * den * ")"
    if (!cone.sign)
        res = "-(" * res * ")"
    end
    return res
end
