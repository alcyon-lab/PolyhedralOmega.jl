using POGA
using Test

@testset "POGA.jl" begin
    @testset "CombinationOfCones" begin
        conepos = Cone([[1, 2], [1, 3]], [4, 3], [false, false], true)
        coneneg = Cone([[1, 2], [1, 3]], [4, 3], [false, false], false)
        coneother = Cone([[5, 2], [1, 3]], [4, 3], [true, false], true)
        combination = CombinationOfCones{Int}()
        @test size(combination.cones, 1) == 0
        combination += conepos
        @test size(combination.cones, 1) == 1
        @test combination.cones[1][2] == 1
        combination += conepos
        @test size(combination.cones, 1) == 1
        @test combination.cones[1][2] == 2
        combination += coneneg
        @test size(combination.cones, 1) == 1
        @test combination.cones[1][2] == 1
        combination += coneneg
        @test size(combination.cones, 1) == 0
        combination += coneneg
        @test size(combination.cones, 1) == 1
        @test combination.cones[1][2] == 1
        combination += coneneg
        @test size(combination.cones, 1) == 1
        @test combination.cones[1][2] == 2
        combination += coneother
        @test size(combination.cones, 1) == 2
        @test combination.cones[1][2] == 2
    end
end
