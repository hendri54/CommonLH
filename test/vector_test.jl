using Test
using CommonLH.VectorLH

@testset "VectorLH" begin
	@testset "count_bool" begin
		xV = [true, false, true, false];
		@test countbool(xV) == 2
	end

	@testset "count_elem" begin
		omitNan = true;
		xV = [7,1,3,1,1,3,4,NaN];
		countM = count_elem(xV, omitNan);
		@test countM == [1 3;  3 2; 4 1; 7 1]

		xV = [7,1,3,1,1,3,4];
		countV = count_indices(xV);
		@test countV == [3, 0, 2, 1, 0, 0, 1]
	end

	@testset "counts_from_fractions" begin
		fracV = [0.21, 0.0, 0.79];
		n = 17;
		countV = counts_from_fractions(fracV, n, dbg = true);
		@test countV == [4, 0, 13]
	end

	@testset "counts_to_indices" begin
		countV = [1, 0, 2, 0];
		outV = counts_to_indices(countV, dbg = true);
		@test outV[1] == [1, 1]
		@test isempty(outV[2])
		@test outV[3] == [2, 3]
		@test isempty(outV[4])

		out2V = counts_to_indices([0, 0], dbg = true);
		@test (isempty(out2V[1]) && isempty(out2V[2]))
	end


	@testset "scale_vector" begin
		v = collect(1 : 0.1 : 2);
		v2 = copy(v);
		scale_vector!(v2, dbg = true);
		@test v2 ≈ v

		v2 = copy(v);
		scale_vector!(v2, xMin = 1.05, xMax = 1.8, dbg = true);
		@test validate_vector(v2, xMin = 1.05, xMax = 1.8);

		v2 = copy(v);
		scale_vector!(v2, xMin = 1.05, xMax = 1.8, vSum = 15.0, dbg = true);
		# Cannot guarantee bounds when a sum is given
		@test validate_vector(v2, vSum = 15.0);
	end
end

#@testset "vectorLH" begin
#    println("Test set vectorLH")
#    countbool" begin
#    count_elem" begin
#    counts_from_fractions" begin
#    counts_to_indices" begin
#    scale_vector" begin
#end

# ----------
