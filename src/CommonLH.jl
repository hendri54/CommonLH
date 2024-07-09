module CommonLH

using ArgCheck, DocStringExtensions, Format, Printf, StatsBase

# Check
export check_float, check_float_array, is_monotone
# Display
export show_text_file, show_string_vector
export MultiIO, print_flush, println_flush
# Keyword arguments
export KwArgs, default_value, has_default, kw_arg
# User input
export ask_for_choice, ask_yes_no
# Vector
export bisecting_indices, findfirst_equal, find_indices, find_index,
    all_at_least, all_at_most, all_greater, all_less,
    any_at_least, any_at_most, any_greater, any_less,
    any_nan
# Grids
export AbstractGrid, LinearGrid, LinSpacedGrid, PowerSpacedGrid, grid, intervals
# Probability matrices
export validate_prob_matrix, validate_prob_vector, prob_j, prob_k, prob_j_k, prob_k_j, ev_given_j, ev_given_k, scale_prob_array!
# Arrays
export bracket_array!, scale_array!
# Discretize
export discretize, bin_edges_from_percentiles, discretize_given_percentiles;
export discretize_from_ub, count_bins;

include("kwargs.jl")
include("check.jl")
include("comparisons.jl");
include("display.jl");
include("logging.jl");
include("user_input.jl")
include("vector.jl")
include("grids.jl")
include("probabilities.jl")
include("arrays.jl");
include("stats/discretize.jl");


# export validate, validate_scalar
# include("check.jl")


# include("matrix.jl")

# include("statistics.jl")

# export test_header, test_divider, test_dir
# include("testing.jl")


end # module
