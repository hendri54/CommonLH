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


function monotone_test(N :: Integer)
    rng = MersenneTwister(434);
    @testset "Monotone" begin
        sizeV = 6 : -1 : (7 - N);
        m1 = randn(rng, sizeV[1 : N]...);
        for strict in (true, false)
            for increasing in (true, false)
                for d = 1 : N
                    @test !is_monotone(m1, d; strict, increasing);

                    # Make array that is monotone in dimension d
                    m2 = copy(m1);
                    increasing  ?  (dx = 0.001)  :  (dx = -0.001);
                    for j = 2 : sizeV[d]
                        selectdim(m2, d, j) .= selectdim(m2, d, j-1) .+ dx;
                    end
                    @test is_monotone(m2, d; strict, increasing);
                end
            end
        end


    end
end


@testset "Checks" begin
    check_float_test()
    check_array_test()
    for N = 1 : 3
        monotone_test(N);
    end
end

# ------------