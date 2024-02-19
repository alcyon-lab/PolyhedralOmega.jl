using SmithNormalForm
using IterTools


function EnumerateFundamentalParallelepiped(cone::Cone{T}) where {T<:Number}
    vrep = Matrix{Int}(vrep_matrix(cone))
    # println("VREP:", vrep)
    SMFRes = SmithNormalForm.smith(vrep)
    S = SmithNormalForm.diagm(SMFRes)
    Uinv = SMFRes.Sinv
    Winv = SMFRes.Tinv
    # println("S: ", S)
    # println("Uinv: ", Uinv)
    # println("Winv: ", Winv)
    dimension = size(vrep, 2) # num of rows
    ambientDimension = size(vrep, 1) # num of cols

    diagonals = Int64[]
    for i in 1:dimension
        if (i <= size(S, 1) && i <= size(S, 2))
            push!(diagonals, S[i, i])
        end
    end
    # println("diagonals: ", diagonals)

    lastDiagonal = diagonals[end]

    # sprime = [Integer(sk / si) for si in s]
    sprimeDiagonals = Int64[]
    for d in diagonals
        push!(sprimeDiagonals, Int64(lastDiagonal // d))
    end
    # println("Prime diagonals: ", sprimeDiagonals)
    sprime = diagm(sprimeDiagonals)

    # qhat = Uinv * q
    apex = cone.apex
    # println("q: ", apex, "\nV: ", vrep)

    # println("uinv: ", Uinv)

    qhat = Uinv * apex
    # println("qhat: ", qhat)

    # Wprime
    Wprime = Winv * sprime
    # println("wprime: ", Wprime)

    # qtrans
    qtrans = [sum([-Wprime[j, i] * qhat[i] for i = 1:dimension]) for j = 1:dimension]
    # println("qtrans: ", qtrans)

    #qfrac
    qfrac = [qtrans[i] - floor(Int, qtrans[i]) for i = 1:dimension]
    # println("qfrac: ", qfrac)

    #qint
    qint = [floor(Int, qi) for qi in qtrans]
    # println("qint: ", qint)



    #qsummand
    qsummand = [Int64(qi) for qi in (lastDiagonal * apex + vrep * qfrac)]
    #println("qsummand", qsummand)

    #openness
    openness = [(qfrac[j] == 0 ? cone.openness[j] : 0) for j in 1:dimension]
    #println("openness: ", openness)

    #bigP
    #res1 = [[1:1:diagonals[i];] for i= 1:dimension]
    #println("res1: ", res1)

    # CartesianProduct( *[xrange(s[i]) for i in 1:k] )
    L = Vector{Int}[]

    for v in IterTools.product([(0:diagonals[i]-1) for i in 1:dimension]...)
        innerRes = []
        j = 1
        for qj in qint
            inner = 0
            i = 1
            for vi in v
                inner += Wprime[j, i] * vi
                i += 1
            end
            inner += qj
            inner = inner % lastDiagonal

            if inner == 0 && openness[j]
                inner = lastDiagonal
            end
            append!(innerRes, inner)
            j += 1
        end
        # println("innerRes: : ", innerRes)

        outerRes = []
        for l in 1:ambientDimension
            outer = 0
            j = 1
            for innerResi in innerRes
                outer += vrep[l, j] * innerResi
                j += 1
            end
            append!(outerRes, outer) # outerRes is an integral vector
        end
        # println("outerRes: ", outerRes)
        # println("qsummand: ", qsummand)
        # println("zip: ", collect(zip(outerRes, qsummand)))
        # push!(L, tuple(collect( ((ai + bi) / lastDiagonal) for (ai,bi) in collect(zip(outerRes, qsummand)) )))
        push!(L, collect(Int64((ai + bi) // lastDiagonal) for (ai, bi) in collect(zip(outerRes, qsummand))))
    end
    return L
end
