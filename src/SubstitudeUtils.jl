function rep!(e, old, new)
    for (i, a) in enumerate(e.args)
        if a == old
            e.args[i] = new
        elseif a isa Expr
            e.args[i] = rep!(a, old, new)
        end
        ## otherwise do nothing
    end
    if length(e.args) < 2 && e.head == old
        return new
    end
    return e
end

function substitude(val::T, subs::Dict)::Number where {T<:NumberOrExpr}
    for (old, new) in subs
        val = rep!(val, old, new)
    end
    return eval(val)
end

function substitude_vector(vector::Vector{T}, subs::Dict) where {T<:NumberOrExpr}
    return Vector{Number}([isa(x, Union{Expr,Symbol}) ? substitude(x, subs) : x for x in vector])
end

function substitude_ray(ray::Ray{T}, subs::Dict) where {T<:NumberOrExpr}
    return Ray{Number}(
        substitude_vector(ray.direction, subs),
        substitude_vector(ray.apex, subs),
    )
end

function substitude_cone(cone::Cone{T}, subs::Dict) where {T<:NumberOrExpr}
    return Cone{Number}(
        [substitude_ray(r, subs) for r in cone.rays],
        substitude_vector(cone.apex, subs),
        cone.openness,
        cone.sign,
    )
end
