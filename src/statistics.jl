module StatsLH

# using Base.Test
using StatsBase

export std_w, std_std, density_weighted, discretize

include("stats/std_w.jl")
include("stats/std_std.jl")
include("stats/density_weighted.jl")
include("stats/discretize.jl")


end # module
