module PolyhedralOmega

using Polynomials
using Cones
using Values

include("EliminateCoordinates.jl")
include("MacmahonLifting.jl")

export run_polyhedral_omega

function run_polyhedral_omega(A::Matrix{T}, b::Vector{T}; rf_as_string::Bool=false) where {T<:Value}
    macmahon_cone = macmahon_lifting(A, b)
    list_of_cones = eliminate_coordinates(macmahon_cone, size(b, 1))
    fpps = Dict()
    r_str = ""
    r = CombinationOfRationalFunctions{Integer}()
    for (cone, count) in list_of_cones.cones
        cone = Cone{Number}(cone.rays, cone.apex, cone.openness, cone.sign)
        fpp = enumerate_fundamental_parallelepiped(cone)
        fpps[cone] = fpp
        if rf_as_string
            cone_rf_str = compute_rational_function_str(cone, fpp)
            if count != 1
                cone_rf_str = "($(count)*($(cone_rf_str)))"
            end
            if (length(r_str) > 0)
                r_str = r_str * " + " * cone_rf_str
            else
                r_str = cone_rf_str
            end
        else
            cone_rf_s = compute_rational_function(cone, fpp) * count
            r = cone_rf_s + r
        end
    end
    if rf_as_string
        return list_of_cones, fpps, r_str
    else
        return list_of_cones, fpps, r
    end

end

function run_polyhedral_omega(A::Matrix{T}, b::Vector{T}, f::Vector{T}, values::Vector{<:Number}; rf_as_string::Bool=false) where {T<:Value}
    α = Symbol("α")
    macmahon_cone = macmahon_lifting(A, b, f, symbol=α)
    list_of_cones = eliminate_coordinates(macmahon_cone, size(b, 1))
    num_of_variables = length(macmahon_cone.apex)
    x = [Symbol("x_$(i)") for i in 1:num_of_variables]
    ret = []
    fpps = []
    for val in values
        r = 0
        r_str = ""
        inner_fpps = Dict()
        for (cone, count) in list_of_cones.cones
            s_cone = substitute_cone(cone, Dict(α => val))
            fpp = enumerate_fundamental_parallelepiped(s_cone)
            inner_fpps[s_cone] = fpp
            if rf_as_string
                cone_rf_str = compute_rational_function_str(s_cone, fpp)
                if count != 1
                    cone_rf_str = "($(count)*($(cone_rf_str)))"
                end
                if (length(r_str) > 0)
                    r_str = r_str * " + " * cone_rf_str
                else
                    r_str = cone_rf_str
                end
            else
                cone_rf_s = compute_rational_function(s_cone, fpp) * count
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

end
