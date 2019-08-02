using CommonLH
using Test

testDir = joinpath(@__DIR__, "test_files");

@testset "CommonLH" begin
	include("check_test.jl")
	include("display_test.jl")
	# include("files_test.jl")
	include("matrix_test.jl")
	include("statistics_test.jl")
	include("struct_test.jl")
	include("vector_test.jl")
	include("project_test.jl")
end

# -----------