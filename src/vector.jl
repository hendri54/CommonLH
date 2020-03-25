"""
	$(SIGNATURES)

For each value in `valueV` (a weakly increasing `Vector`), find the corresponding indices in `gridV` (also an increasing `Vector{Integer}`).
If no match is found, set indices to 0.
Returns a `Vector` even if only one value is given.

## Example
```
julia> find_indices([2, 4], -2 : 2 : 10) == [3, 4]
true
```
"""
function find_indices(valueV, gridV;  notFoundError :: Bool = false)
    @argcheck eltype(valueV) <: Integer
    nGrid = length(gridV);
    idxV = zeros(Int, size(valueV));
    # Last value of `gridV` that was matched
    lastIdx = 1;
    for (j, value) in enumerate(valueV)
        # lastIdx = find_index(value, gridV; startIdx = lastIdx);
        # if !isnothing(lastIdx)
        #     idxV[j] = lastIdx;
        # else
            # # No grid point matches current value. Done.
            # break
        # end
        lastIdx = findnext(x -> x >= value, gridV, lastIdx);
        if isnothing(lastIdx) 
            # No grid point matches current value. Done.
            break
        end
        if value == gridV[lastIdx]
            idxV[j] = lastIdx;
        end
    end

    if notFoundError  &&  any(idxV .== 0)
        error("Some values not matched.")
    end
    return idxV
end


function find_index(value :: T1, gridV;  startIdx = 1)  where T1 <: Number
    # First grid point (weakly) above current value
    idx = findnext(x -> x >= value, gridV, startIdx);
    if isnothing(idx) 
        return nothing
    elseif isequal(value, gridV[idx])
        return idx
    else
        return nothing
    end
end


# module VectorLH

# using StatsBase

# export countbool, count_elem, count_indices, counts_from_fractions, counts_to_indices
# export scale_vector!, validate_vector

# # Count number of true elements in a vector
# function countbool(xV :: Array{Bool, 1})
#   count(z -> (z == true), xV)
# end


# """
# count_elem()

# Count the number of times each element occurs in a vector
# NaN is kept as a separate value unless `omitNan` is set

# OUT
#     outM
#         matrix with values and counts as columns
# """
# function count_elem(xV :: Array{T,1}, omitNan = false) where T <: Any
#     if omitNan
#         dictV = countmap(filter(y -> ~isnan(y), xV));
#     else
#         dictV = countmap(xV);
#     end

#     # Make dict into vector of counts
#     countM = hcat([[key, val] for (key, val) in dictV]...)';
#     # countV = zeros(T, size(xV));
#     # for (key, val) in dictV
#     #     countV[key] = val;
#     # end
#     return sortslices(countM, dims=1)
# end


# """
# count_indices()

# Count the number of times each element occurs in a vector
# Return vector of counts
# Assumes that values are integer indices
# """
# function count_indices(xV :: Array{T,1}) where T <: Integer
#     countM = count_elem(xV, false);
#     countV = zeros(Int64, maximum(countM[:,1]));
#     countV[countM[:,1]] = countM[:, 2];
#     return countV;
# end


# """
# Counts from fractions

# Given a total count and the fraction of time each value should occur
# compute the number of times each value occurs

# Fractions must sum to 1
# """
# function counts_from_fractions(fracV :: Vector{T1}, n :: Integer;
#     dbg :: Bool = false) where
#     T1 <: AbstractFloat

#     cumNV = round.(Int, cumsum(fracV) .* n);
#     countV = diff(vcat(0, cumNV));

#     if dbg
#         @assert sum(countV) == n
#         @assert length(countV) == length(fracV)
#         @assert all(fracV .>= 0.0)
#         @assert sum(fracV) ≈ 1.0
#     end
#     return countV :: Vector{Int}
# end


# """
# Counts to indices

# Given a vector of counts, return indices in a "stacked" vector
# First entry is (1, countV[1])

# OUT
#     Vector with start / end indices for each entry
#     Note: Cannot use Tuples b/c no empty Tuple{Int,Int} exists.
#     Empty when countV = 0
# """
# function counts_to_indices(countV :: Vector{T1}; dbg :: Bool = false) where
#     T1 <: Integer

#     n = length(countV);
#     if dbg
#         @assert n > 0
#         @assert all(countV .>= 0)
#     end

#     outV = Vector{Vector{Int}}(undef, n);
#     idxLast = 0;
#     for i1 = 1 : n
#         if countV[i1] == 0
#             outV[i1] = Int[];
#         else
#             outV[i1] = [idxLast + 1,  idxLast + countV[i1]];
#             idxLast += countV[i1];
#         end
#     end

#     if dbg
#         @assert idxLast == sum(countV)
#         @assert length(outV) == n
#     end
#     return outV
# end # function


# """
# ## Scale a vector

# Impose minimum, maximum values. Ensure that it sums to a fixed value

# If the sum is fixed, this currently does not guarantee that the min / max
# are satisfied. One would have to call the function iteratively to ensure this.
# """
# function scale_vector!(v :: Vector{T1};  xMin = [],  xMax = [],  vSum = [],
#     dbg :: Bool = false)  where T1 <: AbstractFloat

#     if dbg
#         # Check that scaling is feasible
#         n = length(v);
#         if !isempty(xMax)  &&  !isempty(xMin)
#             @assert xMax > xMin
#         end
#         if !isempty(xMin)  &&  !isempty(vSum)
#             @assert n * xMin < vSum
#         end
#         if !isempty(xMax)  &&  !isempty(vSum)
#             @assert n * xMax > vSum
#         end
#     end

#     if !isempty(xMin)
#         idxMinV = findall(v .< xMin);
#         v[idxMinV] .= xMin;
#     else
#         idxMinV = [];
#     end
#     if !isempty(xMax)
#         idxMaxV = findall(v .> xMax);
#         v[idxMaxV] .= xMax;
#     else
#         idxMaxV = [];
#     end
#     if !isempty(vSum)
#         scaledSum = sum(v);
#         canChangeV = trues(size(v));
#         if scaledSum > vSum
#             # Cannot change the values that hit the min
#             canChangeV[idxMinV] .= false;
#         else
#             canChangeV[idxMaxV] .= false;
#         end
#         scaledSum = sum(v[canChangeV]);
#         v[canChangeV] .*= (vSum - sum(v[.!canChangeV])) / sum(v[canChangeV]);

#         if dbg
#             @assert sum(v) ≈ vSum
#         end
#     end
#     return nothing
# end


# function validate_vector(v :: Vector{T1};  xMin = [],  xMax = [],
#     vSum = [])  where T1 <: AbstractFloat

#     isValid = true;
#     if !isempty(xMin)  &&  any(v .< xMin)
#         isValid = false;
#         vMin = minimum(v);
#         @warn "Values below minimum:  $vMin < $xMin"
#     end
#     if !isempty(xMax)  &&  any(v .> xMax)
#         isValid = false;
#         @warn "Values above maximum"
#     end
#     if !isempty(vSum)  &&  !(sum(v) ≈ vSum)
#         isValid = false;
#         @warn "Sum is wrong"
#     end
#     return isValid
# end

# end # module
