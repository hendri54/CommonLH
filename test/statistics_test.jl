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