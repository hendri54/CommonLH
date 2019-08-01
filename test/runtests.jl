using CommonLH
using Test

@testset "CommonLH" begin
	include("check_test.jl")
	include("display_test.jl")
	include("matrix_test.jl")
	include("statistics_test.jl")
	include("struct_test.jl")
	include("vector_test.jl")
end

# -----------