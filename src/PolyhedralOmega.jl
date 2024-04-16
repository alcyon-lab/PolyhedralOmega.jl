module PolyhedralOmega

using Polynomials
using Cones
using Values

include("EliminateCoordinates.jl")
include("MacmahonLifting.jl")

export solve, optimize

function solve(A::Matrix{T}, b::Vector{T}; rf_as_string::Bool=false) where {T<:Union{Value,Number}}
    macmahon_cone = macmahon_lifting(A, b)
    list_of_cones = eliminate_coordinates(macmahon_cone, size(b, 1))
    fpps = Dict()
    r_str = ""
    r = CombinationOfRationalFunctions()
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

function optimize(A::Matrix{T}, b::Vector{T}, f::Vector{T}, max_value::Number) where {T<:Number}
    return optimize(Matrix{Value}(A), Vector{Value}(b), Vector{Value}(f), max_value)
end

function optimize(A::Matrix{T}, b::Vector{T}, f::Vector{T}, max_value::Number) where {T<:Value}
    α = Symbol("α")
    macmahon_cone = macmahon_lifting(A, b, f, symbol=α)
    list_of_cones = eliminate_coordinates(macmahon_cone, size(b, 1))
    value = max_value // 2
    min_value = 0
    optimal_rf = (-1 => Value)
    while true
        rf = CombinationOfRationalFunctions()
        for (cone, count) in list_of_cones.cones
            s_cone = substitute_cone(cone, Dict(α => value))
            s_cone_eliminated = eliminate_last_coordinate(s_cone)
            for (s, s_count) in s_cone_eliminated.cones
                fpp = enumerate_fundamental_parallelepiped(substitute_cone(s, Dict()))
                rf += (compute_rational_function(s, fpp) * count * s_count)
            end
        end
        eval_res = evaluate_all_with(rf, length(b), 1)
        res = floor(eval_res)
        if isequal(res, 1)
            return simplify(rf)
        elseif isequal(res, 0)
            tmp_value = value
            value = floor(min_value + (value - min_value) / 2)
            max_value = tmp_value
            if isequal(value, min_value)
                if optimal_rf[1] != -1
                    return simplify(optimal_rf[2])
                end
                return simplify(rf)
            end
        else
            tmp_value = value
            value = floor(value + (max_value - value) / 2)
            min_value = tmp_value
            if optimal_rf[1] == -1 || optimal_rf[1] > res
                optimal_rf = res => rf
            end
            if isequal(value, min_value)
                return simplify(rf)
            end
        end
    end
    assert("Logic error")
end

end
