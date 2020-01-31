using CommonLH
using Test

testDir = joinpath(@__DIR__, "test_files");

include("kwargs_test.jl")
include("display_test.jl")

@testset "CommonLH" begin
	kwargs_test()
	display_test()
	# include("check_test.jl")
	# # include("files_test.jl")
	# include("matrix_test.jl")
	# include("statistics_test.jl")
	# include("vector_test.jl")
end

# -----------