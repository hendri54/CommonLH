using CommonLH
using Test

test_dir() = joinpath(@__DIR__, "test_files");


@testset "CommonLH" begin
	include("kwargs_test.jl")
	include("check_test.jl")
	include("display_test.jl");
	include("grid_test.jl")
	include("vector_test.jl")
	include("probabilities_test.jl")
	include("arrays_test.jl");
	# include("struct_test.jl");
	include("statistics/discretize_test.jl");
	# include("check_test.jl")
	# # include("files_test.jl")
	# include("matrix_test.jl")
	# include("statistics_test.jl")

	# --- Tests merged from StructLH ---
	include("structlh_test.jl");

	# --- Tests merged from ModelObjectsLH ---
	include("test_model.jl");
	include("single_id_test.jl");
	include("object_id_test.jl");
	include("m_objects_test.jl");
end

# -----------