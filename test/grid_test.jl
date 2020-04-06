# Grid test
using CommonLH, Test

function linear_test_grid(n :: Integer)
    return LinearGrid(-3.0, 4.0, n);
end

function power_spaced_test_grid(n :: Integer)
    return PowerSpacedGrid(-3.0, 4.0, n, 0.5)
end

function lin_spaced_test_grid(n :: Integer)
    return LinSpacedGrid(-3.0, 4.0, n, -0.2)
end


function general_test(g :: AbstractGrid)
    @testset "General" begin
        @test length(g) > 1
        @test minimum(g) < maximum(g)
        gridV = grid(g);
        @test length(gridV) == length(g)
        @test all(diff(gridV) .> 0)
        @test gridV[end] ≈ maximum(g)
        @test gridV[1] ≈ minimum(g)
        @test g[1] ≈ gridV[1]
        @test g[end] ≈ gridV[end]
        @test all(intervals(g) .≈ diff(gridV))
        @test sum(intervals(g)) ≈ maximum(g) - minimum(g)
        for (ig, gPoint) in enumerate(g)
            @test gPoint ≈ gridV[ig]
        end

        for ig = 1 : length(g)
            @test g[ig] ≈ gridV[ig]
        end

    end
end

function linear_test(g :: LinearGrid)
    @testset "Linear" begin
        stepV = intervals(g);
        @test all(stepV .≈ stepV[1])
    end
end

@testset "Grids" begin
    n = 5;
    for g in [linear_test_grid(n), power_spaced_test_grid(n), 
        lin_spaced_test_grid(n)]
        
        general_test(g)
    end

    linear_test(linear_test_grid(n));
end


# ---------------