using CommonLH, Random, Test

function check_float_test()
    @testset "Check float" begin
        @test check_float(1.2)
        @test check_float(-1.23; ub = -1.23)
        @test !check_float(1.2; lb = 1.2001)
        @test !check_float(NaN64)
        @test !check_float(-Inf)
    end
end


function check_array_test()
    @testset "Check float array" begin
        rng = MersenneTwister(32);
        dimV = (3,4,5);
        T1 = Float32;
        lb = -1.0;
        ub = Inf;
        m = lb .+ rand(rng, T1, dimV...);
        @test check_float_array(m, lb, ub)
        m[10] = lb - 1e-5;
        @test !check_float_array(m, lb, ub)
	end
end


@testset "Checks" begin
    check_float_test()
    check_array_test()
end

# ------------