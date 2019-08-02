using Test
using StatsBase, Statistics, Random

using CommonLH.StatsLH

## Weighted density
## should be tested more substantively
function density_weighted_test()
	n = 1000;
	xV = collect(range(5.0, 2.0, length = n));
	wtV = collect(range(0.5, 0.8, length = n));
	densityV, midV = StatsLH.density_weighted(xV, wtV, true);
	@testset "Density weighted" begin
		@test length(xV) == length(densityV) + 1;
	end
end

## Weighted std deviation
function std_w_test()
	n = Int64(1e4);
	rng = MersenneTwister(1234);
	z = randn(rng, Float64, 1, n);
	wtV = ones(1, n);
	zStd, zMean = std_w(z, wtV)
	println("zMean = $zMean,  zStd = $zStd")
	@testset "std_w" begin
		@test zMean ≈ 0.0 atol=0.01
		@test zStd ≈ 1.0 atol = 1e-3

		zStd2 = std(z)
		@test zStd2 ≈ zStd atol = 1e-4
	end
end


## Test discretize given edges
function discretize_test()
	n = 55;
	inV = collect(range(1, 10, length = n));
	edgeV = [1.1, 6.0, 10.0];
	dbg = true;
	outV = StatsLH.discretize(inV, edgeV, dbg);

	@testset "Discretize" begin
		@test all(outV[inV .< edgeV[1]] .== 0)
		@test all(outV[inV .> edgeV[end]] .== 0)

		for ix = 1 : n
			iCl = outV[ix];
			if iCl > 0
				@test inV[ix] >= edgeV[iCl]  &&  inV[ix] <= edgeV[iCl+1]
			else
				@test inV[ix] <= edgeV[1]  ||  inV[ix] >= edgeV[end]
			end
		end
	end
end


## Test bin edges (unweighted)
function bin_edges_test()
	n = 45;
	inV = collect(range(-4.0, 3.0, length = n));
	pctV = [0.25, 0.4, 0.85];
	dbg = true;
	edgeV = StatsLH.bin_edges_from_percentiles(inV, pctV, dbg);
	@test length(edgeV) == (length(pctV) + 1)
	# test that fractions below edges match target +++++
end


## Test bin edges (weighted)
function bin_edges_weighted_test()
	n = 45;
	inV = collect(range(-4.0, 3.0, length = n));
	# FrequencyWeights must be integers
	wtV = ProbabilityWeights(collect(range(0.2, 0.8, length = n)))
	pctV = [0.25, 0.4, 0.85];
	dbg = true;
	edgeV = StatsLH.bin_edges_from_percentiles(inV, wtV, pctV, dbg);
	@test length(edgeV) == (length(pctV) + 1)

	# test that fractions below edges match target +++++
end


## Discretize given percentiles
function discretize_given_percentiles_test()
	n = 38;
	inV = collect(range(1.0, 5.0, length = n));
	pctV = [0.25, 0.4, 0.85, 1.0];
	dbg = true;
	classV = StatsLH.discretize_given_percentiles(inV, pctV, dbg);

	@testset "discretize_given_percentiles" begin
		@test all(classV .>= 1);
		@test all(classV .<= length(pctV));
	end
end


## Discretize (weighted)
function discretize_given_pct_weighted_test()
   println("Test discretize_given_percentiles weighted")
   n = 38;
   inV = collect(range(1.0, 5.0, length = n));
   wtV = ProbabilityWeights(collect(range(0.1, 0.5, length = n)));
   pctV = [0.25, 0.4, 0.85, 1.0];
   dbg = true;
   classV = StatsLH.discretize_given_percentiles(inV, wtV, pctV, dbg);
	@testset "discretize pct weighted" begin
	   @test all(classV .>= 1);
	   @test all(classV .<= length(pctV));
   end
end


@testset "Statistics" begin
	include("statistics/std_std_test.jl")
	density_weighted_test();
	std_w_test();
	discretize_test();
	bin_edges_test();
	bin_edges_weighted_test();
	discretize_given_percentiles_test();
	discretize_given_pct_weighted_test();
end

#@testset "StatsLH" begin
#    std_w_test()
#    std_std_test()
#    discretize_test()
#    discretize_given_pct_weighted_test();
#    bin_edges_test();
#    bin_edges_weighted_test();
#    discretize_given_percentiles_test()
#    density_weighted_test()
#    # return true
#end


# ------------