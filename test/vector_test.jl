using CommonLH, Test

function findfirst_equal_test()
	@testset "Find first equal" begin
		@test findfirst_equal(22, [1,22,3]) == 2;
		@test isnothing(findfirst_equal(22, [1,2,3]));
		@test findfirst_equal(2, 2) == 1;
		@test isnothing(findfirst_equal(2, 3));
	end
end

function compare_test()
	@testset "Comparisons" begin
		x = [1.0 1.1 1.2; 2.0 2.1 2.2];
		@test any_greater(x, 2.1999)
		@test !any_greater(x, 2.2)
		@test !any_greater(x, 2.1999; atol = 0.001)

		@test any_less(x, 1.001)
		@test !any_less(x, 1.0)
		@test !any_less(x, 1.0001; atol = 0.001)

		@test all_greater(x, 0.9999)
		@test !all_greater(x, 1.0)
		@test all_greater(x, 1.0; atol = 0.0001)

		@test all_less(x, 2.2001)
		@test !all_less(x, 2.2)
		@test all_less(x, 2.2; atol = 0.0001)

		@test all_greater(x, x .- 0.001)
		@test !all_greater(x, x)
		@test all_greater(x, x .- 0.001; atol = 0.003)

		@test all_less(x, x .+ 0.001)
		@test !all_less(x, x)
		@test all_less(x, x .+ 0.001; atol = 0.003)
	end
end

function bisecting_test()
	@testset "Bisecting indices" begin
		println("Bisecting indices")
		@test bisecting_indices(1, 1) == [1]
		@test bisecting_indices(2, 3) == [2, 3]
		@test bisecting_indices(12, 14) == [12, 14, 13]
		@test bisecting_indices(12, 16) == [12, 16, 14, 13, 15]

		@test sort(bisecting_indices(12, 35)) == collect(12 : 35)
	end
end

function find_indices_test()
	@testset "find_indices" begin
		gridV = collect(2 : 2 : 10);

		# All on the grid
		valueV = [2, 10];
		idxV = @inferred find_indices(valueV, gridV);
		@test idxV == [1, length(gridV)]

		# Top above the grid
		idxV = find_indices([2, 6, 11], gridV);
		@test idxV == [1, 3, 0]

		# All below the grid
		idxV = find_indices([-3, 0], gridV);
		@test idxV == [0, 0]

		# Above and below the grid
		idxV = find_indices([0, 4, 11], gridV);
		@test idxV == [0, 2, 0]

		# Scalar input
		idxV = find_indices(4, gridV);
		@test length(idxV) == 1
		@test gridV[idxV[1]] == 4

		idx = find_index(4, gridV);
		@test isa(idx, Integer)
		@test gridV[idx] == 4
	end
end

# @testset "VectorLH" begin
# 	@testset "count_bool" begin
# 		xV = [true, false, true, false];
# 		@test countbool(xV) == 2
# 	end

# 	@testset "count_elem" begin
# 		omitNan = true;
# 		xV = [7,1,3,1,1,3,4,NaN];
# 		countM = count_elem(xV, omitNan);
# 		@test countM == [1 3;  3 2; 4 1; 7 1]

# 		xV = [7,1,3,1,1,3,4];
# 		countV = count_indices(xV);
# 		@test countV == [3, 0, 2, 1, 0, 0, 1]
# 	end

# 	@testset "counts_from_fractions" begin
# 		fracV = [0.21, 0.0, 0.79];
# 		n = 17;
# 		countV = counts_from_fractions(fracV, n, dbg = true);
# 		@test countV == [4, 0, 13]
# 	end

# 	@testset "counts_to_indices" begin
# 		countV = [1, 0, 2, 0];
# 		outV = counts_to_indices(countV, dbg = true);
# 		@test outV[1] == [1, 1]
# 		@test isempty(outV[2])
# 		@test outV[3] == [2, 3]
# 		@test isempty(outV[4])

# 		out2V = counts_to_indices([0, 0], dbg = true);
# 		@test (isempty(out2V[1]) && isempty(out2V[2]))
# 	end


# 	@testset "scale_vector" begin
# 		v = collect(1 : 0.1 : 2);
# 		v2 = copy(v);
# 		scale_vector!(v2, dbg = true);
# 		@test v2 ≈ v

# 		v2 = copy(v);
# 		scale_vector!(v2, xMin = 1.05, xMax = 1.8, dbg = true);
# 		@test validate_vector(v2, xMin = 1.05, xMax = 1.8);

# 		v2 = copy(v);
# 		scale_vector!(v2, xMin = 1.05, xMax = 1.8, vSum = 15.0, dbg = true);
# 		# Cannot guarantee bounds when a sum is given
# 		@test validate_vector(v2, vSum = 15.0);
# 	end
# end

@testset "vectorLH" begin
	findfirst_equal_test();
	find_indices_test();
	bisecting_test();
	compare_test();
end

# ----------
