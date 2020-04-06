# Grids

"""
	$(SIGNATURES)

Abstract grid type.
"""
abstract type AbstractGrid end

"""
	$(SIGNATURES)

Linear, equally spaced grid.
"""
struct LinearGrid{T <: AbstractFloat, I <: Integer} <: AbstractGrid
    xMin :: T
    xMax :: T
    nPoints :: I
end

"""
	$(SIGNATURES)

Grid with increasing or decreasing intervals. Interval(j) / interval(j-1) is a constant.
Constructed from:
- xMin, xMax: range
- nPoints: no of grid points
- ratio of interval(j) / interval(j-1)
"""
struct PowerSpacedGrid{T <: AbstractFloat, I <: Integer} <: AbstractGrid
    xMin :: T
    xMax :: T
    nPoints :: I
    intervalRatio :: T
end


"""
	$(SIGNATURES)

Grid with intervals that increase or decrease by constants.
"""
struct LinSpacedGrid{T <: AbstractFloat, I <: Integer} <: AbstractGrid
    xMin :: T
    xMax :: T
    nPoints :: I
    intervalDiff :: T
end


## -------------  Common functions

Base.eltype(g :: AbstractGrid) = Base.eltype(minimum(g));
Base.length(g :: AbstractGrid) = g.nPoints;
Base.minimum(g :: AbstractGrid) = g.xMin;
Base.maximum(g :: AbstractGrid) = g.xMax;
n_intervals(g :: AbstractGrid) = length(g) - 1;
intervals(g :: AbstractGrid) = diff(grid(g));
Base.firstindex(g :: AbstractGrid) = 1;
Base.lastindex(g :: AbstractGrid) = length(g);
Base.getindex(g :: AbstractGrid, idx) = grid(g)[idx];

function grid(g :: AbstractGrid)
    return minimum(g) .+ vcat(zero(eltype(g)), cumsum(intervals(g)))
end

function Base.iterate(g :: AbstractGrid, idx)
    if idx > length(g)
        return nothing
    else
        return g[idx], idx+1
    end
end

Base.iterate(g :: AbstractGrid) = Base.iterate(g, 1);

## --------------  Linear Grid

grid(g :: LinearGrid) = range(minimum(g), maximum(g), length = length(g));

function Base.getindex(g :: LinearGrid, idx)
    dx = (maximum(g) - minimum(g)) / n_intervals(g);
    return minimum(g) .+ dx .* (collect(idx) .- 1)
end


## --------------  Power Spaced Grid

function first_interval(g :: PowerSpacedGrid{T,I}) where {T, I} 
    factor1 = (g.intervalRatio ^ (length(g) - 1) - one(T)) / (g.intervalRatio - 1);
    return (maximum(g) - minimum(g)) / factor1
end

function intervals(g :: PowerSpacedGrid{T,I}) where {T, I}
    intV = Vector{T}(undef, length(g) - 1);
    intV[1] = first_interval(g);
    for j = 2 : (length(g) - 1)
        intV[j] = intV[j-1] * g.intervalRatio;
    end
    return intV
end

# function grid(g :: PowerSpacedGrid{T,I}) where {T,I} 
#     return minimum(g) .+ vcat(zero(eltype(g)), cumsum(intervals(g)))
# end


## ----------------  Linearly changing intervals

function first_interval(g :: LinSpacedGrid{T,I}) where {T, I}
    n = length(g);
    dX = maximum(g) - minimum(g);

    return dX / (n-1) - g.intervalDiff * (n-2) / 2.0;
end

interval(g :: LinSpacedGrid{T,I}, idx) where {T, I} = 
    first_interval(g) .+ (idx .- 1) .* g.intervalDiff;

intervals(g :: LinSpacedGrid{T,I}) where {T, I} =
    interval(g, 1 : n_intervals(g))

# -------------