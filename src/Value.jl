using MacroTools

# updated form of
# https://discourse.julialang.org/t/get-a-symbol-vector-of-all-variable-names-in-an-expr/39391/3
function symbols(ex)
    list = Symbol[]
    function walk!(ex)
        if ex isa Symbol
            push!(list, ex)
        elseif ex isa Expr
            if ex.head == :call
                for arg in ex.args[2:end]
                    walk!(arg)
                end
            elseif ex.head isa Symbol && isempty(ex.args)
                push!(list, ex.head)
            end
        end
    end
    walk!(ex)
    return Set{Symbol}(list)
end

function Base.:+(a::Symbol, b::Symbol)::Expr
    return :($a + $b)
end

# Instead of 
export Value
mutable struct Value
    val::Union{Number,Expr,Symbol}
    free::Set{Base.Symbol}
    bound::Set{Base.Symbol}
end

function Value(a::T) where {T<:Number}
    return Value(a, Set{Symbol}([]), Set{Symbol}([]))
end

function Value(a::Expr)
    return Value(a, symbols(a), Set{Symbol}([]))
end

function Value(a::Symbol)
    return Value(a, Set{Symbol}([a]), Set{Symbol}([]))
end

Base.convert(::Type{Value}, x::Number) = Value(x)
Base.convert(::Type{Value}, x::Expr) = Value(x)
Base.convert(::Type{Value}, x::Symbol) = Value(x)
Base.promote_rule(::Type{Value}, ::Type{<:Number}) = Value
Base.promote_rule(::Type{Value}, ::Type{<:Expr}) = Value
Base.promote_rule(::Type{Value}, ::Type{<:Symbol}) = Value

function Base.convert(::Type{Number}, x::Value)
    if isa(x.val, Number)
        return x.val
    else
        throw(error("Value is not a number"))
    end
end

Base.zero(::Type{Value}) = zero(Number)
Base.one(::Type{Value}) = one(Number)

function Base.length(x::Value)
    return 1
end

function Base.iterate(x::Value, nothing)
    return nothing
end

function Base.iterate(x::Value)
    return (x, nothing)
end

function Base.isinteger(x::Union{Symbol,Expr})
    return false
end
function Base.isinteger(x::Value)
    return isinteger(x.val)
end

function Base.Integer(x::Value)
    return Integer(x.val)
end

function Base.transpose(x::Union{Value,Symbol,Expr})
    return x
end

function Base.:(==)(b::Value, a::Value)
    return a.val == b.val
end
function Base.:(==)(a::Value, b::Any)
    return a.val == b
end
function Base.:(==)(b::Any, a::Value)
    return a.val == b
end
function Base.isless(a::Value, b::Value)
    return isless(a.val, b.val)
end
function Base.isless(a::Value, b::Any)
    return isless(a.val, b)
end
function Base.isless(a::Any, b::Value)
    return isless(a, b.val)
end

function Base.:-(s::Value)::Value
    return Value(-s.val, s.free, s.bound)
end

function Base.:+(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val + b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:-(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val - b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:*(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val * b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:/(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val / b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.://(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val // b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end

function Base.:+(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b + a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:-(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b - a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:*(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b * a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:/(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b / a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.://(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b // a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end

# TODO: not sure about taking the union of bounds
function Base.:+(a::Value, b::Value)::Value
    return Value(a.val + b.val, union(a.free, Set{Symbol}(symbols(b))), union(a.bound, b.bound))
end
function Base.:-(a::Value, b::Value)::Value
    return Value(a.val - b.val, union(a.free, Set{Symbol}(symbols(b))), union(a.bound, b.bound))
end
function Base.:*(a::Value, b::Value)::Value
    return Value(a.val * b.val, union(a.free, Set{Symbol}(symbols(b))), union(a.bound, b.bound))
end
function Base.:/(a::Value, b::Value)::Value
    return Value(a.val / b.val, union(a.free, Set{Symbol}(symbols(b))), union(a.bound, b.bound))
end
function Base.://(a::Value, b::Value)::Value
    return Value(a.val // b.val, union(a.free, Set{Symbol}(symbols(b))), union(a.bound, b.bound))
end


function Base.:-(s::Union{Symbol,Expr})::Expr
    return :(-$s)
end

function Base.:+(ex::Expr, n::Number)::Expr
    return :($ex + $n)
end
function Base.:+(ex::Expr, s::Symbol)::Expr
    return :($ex + $s)
end
function Base.:+(s::Symbol, n::Number)::Expr
    return :($s + $n)
end



function Base.:+(n::Number, ex::Expr)::Expr
    return :($n + $ex)
end
function Base.:+(s::Symbol, ex::Expr)::Expr
    return :($s + $ex)
end
function Base.:+(n::Number, s::Symbol)::Expr
    return :($n + $s)
end

function Base.:-(ex::Expr, n::Number)::Expr
    return :($ex - $n)
end

function Base.:*(ex::Expr, n::Number)::Expr
    return :($ex * $n)
end
function Base.:*(n::Number, ex::Expr)::Expr
    return :($n * $ex)
end

function Base.:*(s::Symbol, n::Number)::Expr
    return :($s * $n)
end
function Base.:*(n::Number, s::Symbol)::Expr
    return :($s * $n)
end

function Base.:*(ex::Expr, s::Symbol)::Expr
    return :($ex * $s)
end
function Base.:*(s::Symbol, ex::Expr)::Expr
    return :($s * $ex)
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



 

function substitute(e::Value, pair)
    return substitute(e.val, pair)
end

function substitute(e::Symbol, pair)
    if e == pair[1]
        return pair[2]
    end
end

function substitute(e::Number, pair)
    return e
end

function substitute(e::Expr, pair)
    MacroTools.postwalk(e) do s
        if s == pair.first
            return pair.second
        elseif s isa Expr && s.head isa Symbol && isempty(s.args) && s.head == pair.first
            return pair.second
        else
            return s
        end
    end
end
