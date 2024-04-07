
using POGA
  
n=3


# A = Matrix{Value}(reduce(vcat,transpose.([vcat([ 0 for j in 1:i-2],[-i-1,i],[ 0 for j in i+1:n]) for i in 2:n])));
# b = Vector{Value}([ 0 for j in 1:size(A)[1]]);
# println(A)

#cones, fpps, r = PolyhedralOmega(A, b, rf_as_string=true);
# cones, fpps, r = PolyhedralOmega(A, b);
# cones
r
# rr = r.get_ratfun()
# println(rr)
# rr =sum(r)
# function Cone(rays::Vector{Vector{T}}, apex::Vector{T}, openness::Vector{Bool}, sign::Bool=true) where {T}

c = Cone([[1,0,0],[1,2,0],[1,2,3]], [0,0,0], [true,true,false])
c = Cone([[1,0,0],[0,1,0],[0,2,3]], [0,0,0], [false,true,false])
c = Cone([[1,0,0],[1,2,0],[0,0,1]], [0,0,0], [true,false,false])
println(c)
EnumerateFundamentalParallelepiped(c)
# ff = rr[1]/rr[2]