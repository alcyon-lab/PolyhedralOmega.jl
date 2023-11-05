using POGA

A = [1 1 1; 1 1 1; 1 1 1];
b = [10, 10, 10];
r = EliminateCoordinates(MacmahonLifting(A, b), 3);
println(r)
