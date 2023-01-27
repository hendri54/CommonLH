## Test discretize given edges
function discretize_test()
	@testset "Discretize" begin
        n = 55;
        inV = collect(range(1, 10, length = n));
        edgeV = [0.0, 6.0, 11.0];
        outV = discretize(inV, edgeV);
		@test all(outV[inV .< edgeV[1]] .== 0)
		@test all(outV[inV .> edgeV[end]] .== 0)

		for ix = 1 : n
			iCl = outV[ix];
            iCl2 = discretize(inV[ix], edgeV);
            @test iCl == iCl2;
			if iCl > 0
				@test inV[ix] >= edgeV[iCl]  &&  inV[ix] <= edgeV[iCl+1]
			else
				@test inV[ix] <= edgeV[1]  ||  inV[ix] >= edgeV[end]
			end
		end
	end
end

function discretize_from_ub_test()
    @testset "Discretize from ub" begin
        n = 7;
        inV = collect(range(1, 10, length = n));
        ubV = LinRange(0.0, 11.0, 20);
        for x in inV
            iCl = discretize_from_ub(x, ubV);
            if iCl > 0
                @test x <= ubV[iCl];
            else
                @test x > last(ubV);
            end
        end
    end
end


## Test bin edges (unweighted)
function bin_edges_test()
    @testset "Bin edges" begin
        n = 450;
        inV = collect(range(-4.0, 3.0, length = n));
        pctV = [0.25, 0.4, 0.85];
        edgeV = bin_edges_from_percentiles(inV, pctV);
        @test length(edgeV) == (length(pctV) + 1)
        
        # test that fractions match target
        cntV = count_bins(inV, edgeV);
        @test sum(cntV) == round(n * pctV[end])
        fracV = cntV ./ n;
        tgFracV = diff(vcat(0.0, pctV));
        @test isapprox(fracV, tgFracV, atol = 2/n)
    end
end


## Test bin edges (weighted)
function bin_edges_weighted_test()
    @testset "Bin edges weighted" begin
        n = 450;
        inV = collect(range(-4.0, 3.0, length = n));
        # FrequencyWeights must be integers
        wtV = collect(range(0.2, 0.8, length = n));
        pctV = [0.25, 0.4, 0.85];
        edgeV = bin_edges_from_percentiles(inV, wtV, pctV);
        @test length(edgeV) == (length(pctV) + 1)

        # test that fractions below edges match target 
        massV = count_bins(inV, wtV, edgeV);
        @test sum(massV) ≈ sum(wtV[inV .<= edgeV[end]])
        fracV = massV ./ sum(wtV);
        tgFracV = diff(vcat(0.0, pctV));
        @test isapprox(fracV, tgFracV, atol = 2/n)
    end
end


## Discretize given percentiles
function discretize_given_percentiles_test()
	@testset "discretize_given_percentiles" begin
        n = 38;
        inV = collect(range(1.0, 5.0, length = n));
        pctV = [0.25, 0.4, 0.85, 1.0];
        classV = discretize_given_percentiles(inV, pctV);
		@test all(classV .>= 1);
		@test all(classV .<= length(pctV));
	end
end


## Discretize (weighted)
function discretize_given_pct_weighted_test()
    @testset "discretize pct weighted" begin
        n = 38;
        inV = collect(range(1.0, 5.0, length = n));
        wtV = collect(range(0.1, 0.5, length = n));
        pctV = [0.25, 0.4, 0.85, 1.0];
        classV = discretize_given_percentiles(inV, wtV, pctV);
	    @test all(classV .>= 1);
	    @test all(classV .<= length(pctV));
    end
end


@testset "Discretize" begin
   discretize_test();
   discretize_from_ub_test();
   discretize_given_pct_weighted_test();
   bin_edges_test();
   bin_edges_weighted_test();
   discretize_given_percentiles_test()
end


# ----------------