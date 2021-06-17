using Random, Test, CommonLH

function compare_test()
    @testset "Comparisons" begin
        rng = MersenneTwister(12);
        x = rand(rng, 4,3);
        xMin, xMax = extrema(x);
        @test all_at_least(x, xMin)
        @test !all_at_least(x, xMin + 1e-6)
        @test all_at_most(x, xMax)
        @test !all_at_most(x, xMax - 1e-6)

        @test all_at_least(x, x .- 1e-5)
        @test all_at_most(x, x .+ 1e-5)
    end
end

function scale_array_test()
    @testset "Scale array" begin
        x = rand(4,3,2);
        for d = 1 : 3
            totalV = collect(range(1.0, 2.0, length = size(x, d)));
            scale_array!(x, d, totalV);
            for j = 1 : size(x, d)
                @test isapprox(sum(selectdim(x, d, j)),  totalV[j])
            end
        end
	end
end


function bracket_array_test()
    @testset "Bracket array" begin
        x = [1.0 1.1 1.2; 2.0 2.1 2.2];
        ub = x .+ 0.01;
        lb = x .- 0.01;
        z = copy(x);
        bracket_array!(z, lb, ub);
        @test isequal(z, x)

        ub[3] = x[3] - 0.001;
        lb[4] = x[4] + 0.001;
        z = copy(x);
        bracket_array!(z, lb, ub);
        @test !isequal(z, x)
        @test all(z .<= ub)
        @test all(z .>= lb)
	end
end

function bracket_array_scalar_test()
    @testset "Bracket array in scalars" begin
        x = [1.0 1.1 1.2; 2.0 2.1 2.2];
        ub = 2.099;
        lb = 1.099;
        bracket_array!(x, lb, ub);
        @test all(x .<= ub);
        @test all(x .>= lb);
    end
end


@testset "Arrays" begin
    compare_test();
    scale_array_test()
    bracket_array_test();
    bracket_array_scalar_test();
end

# -------------