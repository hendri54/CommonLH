# Probability computations

using CommonLH, Random, Test

function prob_matrix_test()
    @testset "Probability matrix" begin
        rng = MersenneTwister(304);
        n = 4; m = 3;
        probM = rand(rng, n, m);
        probM ./= sum(probM);
        @test validate_prob_matrix(probM)

        # Prob(j)
        prob_jV = [prob_j(probM, j) for j = 1 : n];
        prob2_jV = prob_j(probM);
        @test validate_prob_vector(prob_jV)
        @test prob_jV ≈ prob2_jV
        prob3_jV = prob_j(probM, 1 : n);
        @test prob3_jV ≈ prob_jV

        prob_kV = [prob_k(probM, k) for k = 1 : m];
        prob2_kV = prob_k(probM);
        @test validate_prob_vector(prob_kV)
        @test prob_kV ≈ prob2_kV
        prob3_kV = prob_k(probM, 1 : m);
        @test prob3_kV ≈ prob_kV

        for k = 1 : m
            prob_j_kV = prob_j_k(probM, 1:n, k);
            @test isapprox(sum(prob_j_kV), 1.0)
            # Prob(j,k) for given k
            prob_jkV = prob_j_kV .* prob_k(probM, k);
            @test isapprox(prob_jkV, probM[:,k])
        end 

        for j = 1 : n
            prob_k_jV = prob_k_j(probM, 1:m, j);
            @test isapprox(sum(prob_k_jV), 1.0)
            # Prob(j,k) for given j
            prob_jkV = prob_k_jV .* prob_j(probM, j);
            @test isapprox(prob_jkV, vec(probM[j,:]))
        end
    end
end


function ev_test()
	@testset "Expected values" begin
        rng = MersenneTwister(304);
        n = 4; m = 3;
        probM = rand(rng, n, m);
        probM ./= sum(probM);

        xM = rand(rng, n, m);

        evV = ev_given_j(xM, probM);
        @test size(evV) == (n,)
        for j = 1 : n
            ev = ev_given_j(xM, probM, j);
            prV = vec(probM[j,:]);
            xV = vec(xM[j,:]);
            ev2 = sum(xV .* prV) / sum(prV);
            @test isapprox(ev, ev2)
            @test isapprox(ev, evV[j])
        end

        evV = ev_given_k(xM, probM);
        @test size(evV) == (m,)
        for k = 1 : m
            ev = ev_given_k(xM, probM, k);
            prV = probM[:, k];
            xV = xM[:, k];
            ev2 = sum(xV .* prV) / sum(prV);
            @test isapprox(ev, ev2)
            @test isapprox(ev, evV[k])
        end
    end
end

function scale_test()
    @testset "Scale prob array" begin
        x = rand(4,3,2) ./ 5.0;
        x[2 : 2 : 8] .= -0.000000001;
        x ./= sum(x);
        x .+= 0.000000001;
        scale_prob_array!(x);
        @test sum(x) <= 1.0
        @test all(x .>= 0.0)
	end
end


@testset "Probabilities" begin
    ev_test()
    prob_matrix_test()
end

# -------------