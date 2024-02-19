
using POGA

A = Matrix{NumberOrExpr}([1 1 1; 1 2 2; 1 1 2]);
b = Vector{NumberOrExpr}([10, 10, 10]);


cones, fpps, r = PolyhedralOmega(A, b);
cones, fpps, r = PolyhedralOmega(A, b, rf_as_string=true);

f = Vector{NumberOrExpr}([10, 10, 10]);
cones, fpps, r = PolyhedralOmega(A, b, f, Vector{NumberOrExpr}([1]), rf_as_string=true);
cones, fpps, r = PolyhedralOmega(A, b, f, Vector{NumberOrExpr}([1]));


using BenchmarkTools

@benchmark (global macmahon_cone = MacmahonLifting(A, b))

@benchmark (global list_of_cones = EliminateCoordinates(macmahon_cone, size(b, 1)))

function EnumerateFundamentalParallelepipedOfAll(cc::CombinationOfCones)
    fpps = Dict{Cone,Vector{Vector{Int}}}()
    for (cone, count) in cc.cones
        s_cone = Cone{Number}(cone.rays, cone.apex, cone.openness, cone.sign)
        fpp = EnumerateFundamentalParallelepiped(s_cone)
        fpps[cone] = fpp
    end
    return fpps
end
@benchmark (global fpps_of_cones = EnumerateFundamentalParallelepipedOfAll(list_of_cones))

function ComputeRationalFunctionOfAll(cc::CombinationOfCones, fpps::Dict{Cone,Vector{Vector{Int}}})
    r_str = ""
    for (cone, count) in cc.cones
        s_cone = Cone{Number}(cone.rays, cone.apex, cone.openness, cone.sign)
        cone_rf_str = ComputeRationalFunctionStr(s_cone, fpps[cone])
        if count != 1
            cone_rf_str = "($(count)*($(cone_rf_str)))"
        end
        if (length(r_str) > 0)
            r_str = r_str * " + " * cone_rf_str
        else
            r_str = cone_rf_str
        end
    end
    return r_str
end
@benchmark (global r = ComputeRationalFunctionOfAll(list_of_cones, fpps_of_cones))


@benchmark PolyhedralOmega(A, b)
@benchmark PolyhedralOmega(A, b, f, Vector{Number}([1, 2, 3, 4]))
