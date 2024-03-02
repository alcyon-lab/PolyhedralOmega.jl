module POGA

include("Value.jl")
include("Cone.jl")
include("ComputeRationalFunction.jl")
include("CombinationOfCones.jl")
include("EliminateCoordinates.jl")
include("EnumerateFundamentalParallelepiped.jl")
include("MacmahonLifting.jl")
include("SubstituteUtils.jl")

function PolyhedralOmega(A::Matrix{T}, b::Vector{T}; rf_as_string::Bool=false) where {T<:Value}
    macmahon_cone = MacmahonLifting(A, b)
    # println("Macmahon Cone")
    # println(summary(macmahon_cone))
    list_of_cones = EliminateCoordinates(macmahon_cone, size(b, 1))

    # println("Cones")
    # println(list_of_cones)

    fpps = Dict()
    r_str = ""
    r = 0


    for (cone, count) in list_of_cones.cones
        cone = Cone{Number}(cone.rays, cone.apex, cone.openness, cone.sign)
        fpp = EnumerateFundamentalParallelepiped(cone)
        fpps[cone] = fpp
        # println("Enumerated Parallelepiped")
        # println(fpp)
        # println("Rational Function")
        if rf_as_string
            cone_rf_str = ComputeRationalFunctionStr(cone, fpp)
            # println(cone_rf_str)
            if count != 1
                cone_rf_str = "($(count)*($(cone_rf_str)))"
            end
            if (length(r_str) > 0)
                r_str = r_str * " + " * cone_rf_str
            else
                r_str = cone_rf_str
            end
        else
            cone_rf_s = ComputeRationalFunction(cone, fpp) * count
            # println(cone_rf_s)
            r += cone_rf_s
        end
    end
    if rf_as_string
        return list_of_cones, fpps, r_str
    else
        return list_of_cones, fpps, r
    end

end

function PolyhedralOmega(A::Matrix{T}, b::Vector{T}, f::Vector{T}, values::Vector{<:Number}; rf_as_string::Bool=false) where {T<:Value}
    α = Symbol("α")
    macmahon_cone = MacmahonLifting(A, b, f, symbol=α)
    # println("Macmahon Cone")
    # println(summary(macmahon_cone))
    list_of_cones = EliminateCoordinates(macmahon_cone, size(b, 1))

    # println("Cones")
    # println(list_of_cones)

    num_of_variables = length(macmahon_cone.apex)

    x = [Symbol("x_$(i)") for i in 1:num_of_variables]

    ret = []
    fpps = []

    for val in values
        # println("Substitute $(val) for α")
        r = 0
        r_str = ""
        inner_fpps = Dict()
        for (cone, count) in list_of_cones.cones
            s_cone = substitute_cone(cone, Dict(α => val))
            # println("Substituted cone")
            # println(summary(s_cone))
            fpp = EnumerateFundamentalParallelepiped(s_cone)
            inner_fpps[s_cone] = fpp
            # println("Enumerated Parallelepiped")
            # println(fpp)

            # println("Rational Function")
            if rf_as_string
                cone_rf_str = ComputeRationalFunctionStr(s_cone, fpp)
                # println(cone_rf_str)
                if count != 1
                    cone_rf_str = "($(count)*($(cone_rf_str)))"
                end
                if (length(r_str) > 0)
                    r_str = r_str * " + " * cone_rf_str
                else
                    r_str = cone_rf_str
                end
            else
                cone_rf_s = ComputeRationalFunction(s_cone, fpp) * count
                # println(cone_rf_s)
                r += cone_rf_s
            end
        end
        push!(fpps, inner_fpps)
        if rf_as_string
            push!(ret, r_str)
        else
            push!(ret, r)
        end
    end
    return list_of_cones, fpps, ret
end

export
    # Types
    Value,
    Ray,
    Cone,
    CombinationOfCones,
    # Functions
    ComputeRationalFunction,
    ComputeRationalFunctionStr,
    MacmahonLifting,
    EliminateLastCoordinate,
    EliminateCoordinates,
    EnumerateFundamentalParallelepiped,
    PolyhedralOmega

end
