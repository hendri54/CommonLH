using Test
using CommonLH

@testset "checkLH" begin
	@testset "validate" begin
		@test_throws ErrorException validate(1.2, Float64)

		validate([1.2, 2.3], Float64)
		validate([1.2, 2.3], Float64, sz = (2,), lb = 1.0)
		validate([1.2 2.1; 2.2 3.2], Float64, sz = (2,2))
		# checkLH.validate(1.2, Float64, sz = ())
		validate([1.2, 2.3], [], lb = 1.1)

		@test_throws DimensionMismatch validate([1.2, 2.3, 3.4], Float64, sz = (2,))
		@test_throws ErrorException  validate([2.1, 3.2], Float64, ub = 3.1)
	end


	@testset "validate_scalar" begin
		validate_scalar(1.1, Float64, lb = 0.9, ub = 1.2)
		validate_scalar(1, Integer, lb = 0.9, ub = 1.3)
		@test_throws ErrorException validate_scalar(1.1, [], lb = 1.2, ub = 1.3)
		@test_throws ErrorException validate_scalar(1.1, Integer, lb = 0.9, ub = 1.3)
		@test_throws ErrorException validate_scalar([1.1, 2.2], [], lb = 1.2, ub = 1.3)
		return true
	end
end

# -----------
