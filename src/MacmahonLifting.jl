using LinearAlgebra # for I

function MacmahonLifting(A::Matrix{T}, b::Vector{T})::Cone{T} where {T<:NumberOrExpr}
    size_a = size(A)
    Id = Matrix{T}(Matrix(1I, size_a[2], size_a[2]))
    new_matrix = vcat(Id, A)
    apex = append!(zeros(T, size_a[2]), -b)
    openness = zeros(Bool, size_a[2])
    rays = convert(Vector{Vector{T}}, collect(eachcol(new_matrix)))
    return Cone(rays, apex, openness)
end

function MacmahonLifting(A::Matrix{T}, b::Vector{T}, f::Vector{T}; symbol::Symbol=Symbol('a'))::Cone{T} where {T<:NumberOrExpr}
    size_a = size(A)
    Id = Matrix{T}(Matrix(1I, size_a[2], size_a[2]))
    new_matrix = vcat(Id, transpose(f), A)
    apex = append!(zeros(T, size_a[2]), [Expr(symbol)], -b)
    openness = zeros(Bool, size_a[2])
    rays = convert(Vector{Vector{T}}, collect(eachcol(new_matrix)))
    return Cone(rays, apex, openness)
end
