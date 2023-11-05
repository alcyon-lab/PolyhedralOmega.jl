NumberOrExpr = Union{Number,Expr}
Base.zero(::Type{NumberOrExpr}) = zero(Number)
Base.one(::Type{NumberOrExpr}) = one(Number)

function Base.:-(ex::Expr)::Expr
    return :(-$ex)
end

function Base.:+(ex::Expr, n::Number)::Expr
    return :($ex + $n)
end

function Base.:-(ex::Expr, n::Number)::Expr
    return :($ex - $n)
end

function Base.:*(ex::Expr, n::Number)::Expr
    return :($ex * $n)
end

function Base.:/(ex::Expr, n::Number)::Expr
    return :($ex / $n)
end

function Base.://(ex::Expr, n::Number)::Expr
    return :($ex // $n)
end

function Base.:+(ex1::Expr, ex2::Expr)::Expr
    return :($ex1 + $ex2)
end

function Base.:-(ex1::Expr, ex2::Expr)::Expr
    return :($ex1 - $ex2)
end

function Base.:*(ex1::Expr, ex2::Expr)::Expr
    return :($ex1 * $ex2)
end

function Base.:/(ex1::Expr, ex2::Expr)::Expr
    return :($ex1 / $ex2)
end

function Base.://(ex1::Expr, ex2::Expr)::Expr
    return :($ex1 // $ex2)
end
