# PolyhedralOmega.jl

`PolyhedralOmega.jl` is a comprehensive Julia package developed to address linear Diophantine systems and associated optimization challenges using the Polyhedral Omega algorithm. By integrating partition analysis with polyhedral geometry, this package offers efficient and robust solutions, particularly useful in fields requiring integer linear programming (ILP) solutions.

## Installation

To install `PolyhedralOmega.jl`, you can use the Julia package manager. From the Julia REPL, type the following command:

```julia
julia> using Pkg
julia> pkg"registry add https://github.com/alcyon-lab/AlcyonRegistry.git"
julia> pkg"add PolyhedralOmega"
```

## Usage
`PolyhedralOmega.jl` provides versatile functions for solving linear Diophantine systems (LDS) and for optimizing integer linear programming (ILP) problems. Below are detailed explanations and examples for using these functions effectively.

### Solving Linear Diophantine Systems
The `solve` function is used to compute solutions for linear Diophantine systems. It supports options for output customization and optimization for counting solutions.


#### Definition

```julia
solve(A::Matrix{T}, b::Vector{T}; write_rf_to_out::Bool=false, out::IO=stdout, counting::Bool=false) where {T<:Union{Number,Value,Rational}}
```

- **A**: Coefficient matrix of the system.
- **b**: Right-hand side vector defining the constraints (Ax ≤ b).
- **write_rf_to_out** (Optional): If true, writes the rational function to the specified output stream instead of returning it.
- **out** (Optional): The output stream where the rational function is written if `write_rf_to_out` is true.
- **counting**: If true, computes a univariate rational function by substituting all variables in the multivariate function with one variable.

#### Return Value
`solve` function returns a 3-element tuple, where:
- **First Element**: A combination of cones, which are geometric representations of the solutions.
- **Second Element**: A dictionary where each key is a cone and the value is the generators for each point of the fundamental parallelepipeds associated with that cone.
- **Third Element**: The multivariate (or univariate if counting is true) rational function.

#### Example
   ```julia
   using PolyhedralOmega

   A = [2 -1 0; 0 3 -2];
   b = [0, 0];
   # basic usage
   result = solve(A, b);

   # counting
   result = solve(A, b, counting=true);

   # output to file
   file = open("output.txt", "w")
   result = solve([2 -1 0; 0 3 -2], [0, 0], write_rf_to_out=true, out=file)
   close(file)
   ```


### Optimizing ILP Problems
The optimize function is designed to find optimal solutions to ILP problems under specified constraints.


#### Definition

```julia
optimize(A::Matrix{T}, b::Vector{T}, f::Vector{T}, max_value::Number) where {T<:Union{Number,Value,Rational}}
```

- **A** (Matrix{T}): Coefficient matrix of the system.
- **b** (Vector{T}): Right-hand side vector defining the constraints (Ax ≤ b).
- **f** (Vector{T}): Coefficient vector of the linear objective function to be maximized or minimized.
- **max_value** (Number): A numeric upper bound to restrict the search space for optimization.

#### Return Value
`optimize` returns the optimized rational function.

#### Example
```julia
A = [1 2; -3 -4];  # Coefficient matrix
b = [8, 2];      # Right-hand side vector
f = [1, 1];      # Objective function
max_value = 10   # Upper bound
optimize(A, b, f, max_value)
```

## Benchmarks

|       Example       | avg runtime (ms) | avg runtime (write_rf_to_out) (ms) | total mememory consumtion (Mib) | total mememory consumtion (write_rf_to_out) (Mib) |
|--------------------|------------------|------------------------------------|---------------------------------|---------------------------------------------------|
| lecture hall (3x4) | 2.2              | 0.4                                | 1.7                             | 0.6                                               |
| lecture hall (4x5) | 7.8              | 1.9                                | 6.9                             | 2.6                                               |
| lecture hall (5x6) | 46.1             | 25.8                               | 55.4                            | 34.3                                              |
| lecture hall (6x7) | 416.6            | 1357                               | 589.2                           | 1.58 Gib                                          |
