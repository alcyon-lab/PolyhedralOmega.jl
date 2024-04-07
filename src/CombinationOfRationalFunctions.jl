struct CombinationOfRationalFunctions{T}
    ratfuns::Vector{Pair{AbstractAlgebra.Generic.MPoly{Rational{T}},AbstractAlgebra.Generic.MPoly{Rational{T}}}}

    function CombinationOfRationalFunctions(ratfuns::Vector{Pair{AbstractAlgebra.Generic.MPoly{Rational{T}},AbstractAlgebra.Generic.MPoly{Rational{T}}}}) where {T}
        new{T}(ratfuns)
    end
    function CombinationOfRationalFunctions(ratfun::Pair{AbstractAlgebra.Generic.MPoly{Rational{T}},AbstractAlgebra.Generic.MPoly{Rational{T}}}) where {T}
        new{T}([ratfun])
    end

    function CombinationOfRationalFunctions{T}() where {T}
        new(Vector{Pair{AbstractAlgebra.Generic.MPoly{Rational{T}},AbstractAlgebra.Generic.MPoly{Rational{T}}}}([]))
    end
end

function Base.:(+)(combination::CombinationOfRationalFunctions{T}, ratfun::Pair{AbstractAlgebra.Generic.MPoly{Rational{T}},AbstractAlgebra.Generic.MPoly{Rational{T}}}) where {T}
    # DO in place instead
    #newratfuns::Vector{Pair{Cone{T},Int}} = []
    found = false
    for (numerator, denominator) in combination.ratfuns
        # This is potentially very expensive computationally
        if denominator == ratfun[2] # check if this expands. if so, consider alternstive representation.
            ratfun[1] += numerator
            found = true
        end
    end
    if !found
        # push!(newratfuns, ratfun)
        push!(combination.ratfuns, ratfun)
    end
    return combination
end


function Base.:(+)(combination1::CombinationOfRationalFunctions{<:T}, combination2::CombinationOfRationalFunctions{<:T}) where {T}
    combination = CombinationOfRationalFunctions(combination1.ratfuns)
    for pair in combination2.ratfuns
        combination += pair
    end
    return combination
end

function Base.:(+)(combination::CombinationOfRationalFunctions{T}, ratfuns::Vector{Cone{T}}) where {T}
    for ratfun in ratfuns
        combination += ratfun
    end
    return combination
end

function Base.:(*)(combination::CombinationOfRationalFunctions{T}, c::Integer) where {T}
    newpairs = Vector{Pair{AbstractAlgebra.Generic.MPoly{Rational{T}},AbstractAlgebra.Generic.MPoly{Rational{T}}}}([])
    for ratfun in combination.ratfuns
        push!(newpairs, Pair(ratfun[1] * c, ratfun[2]))
    end
    return CombinationOfRationalFunctions(newpairs)
end

function get_ratfun(c::CombinationOfRationalFunctions)
    println(parent(c.ratfuns[1]))
    FF = fraction_field(parent(c.ratfuns[1]))
    sum([n / d for (n, d) in c.ratfuns])
end

function simplify(c::CombinationOfRationalFunctions)
    sum([n / d for (n, d) in c.ratfuns])
end

function subs(c::CombinationOfRationalFunctions, v::Vector)
    R = [n / d for (n, d) in c.ratfuns]
    return sum([r(v) for r in R])
end

function Base.show(io::IO, c::CombinationOfRationalFunctions{T}) where {T}
    println(io, "CombinationOfRationalFunctions{::$(T)}: ")
    for ratfun in c.ratfuns
        println(io, "\t$(summary(ratfun))")
    end
end
