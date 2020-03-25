module CommonLH

using ArgCheck, DocStringExtensions, Formatting, Printf

# Display
export show_text_file, show_string_vector
# Keyword arguments
export KwArgs, default_value, has_default, kw_arg
# User input
export ask_for_choice, ask_yes_no
# Vector
export find_indices, find_index

include("kwargs.jl")
include("display.jl")
include("user_input.jl")
include("vector.jl")

# export validate, validate_scalar
# include("check.jl")


# include("matrix.jl")

# include("statistics.jl")

# export test_header, test_divider, test_dir
# include("testing.jl")


end # module
