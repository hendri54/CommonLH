using Random, Test, CommonLH

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


@testset "Arrays" begin
    scale_array_test()
    bracket_array_test()
end

# -------------