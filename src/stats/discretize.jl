"""
    $(SIGNATURES)

Discretize given percentiles (unweighted). The smallest `pctV[1]` of values in `inV` end up in bin 1, etc.
"""
function discretize_given_percentiles(inV :: Vector{F1}, 
    pctV :: Vector{F2}) where {F1, F2}

    edgeV = bin_edges_from_percentiles(inV, pctV);
    return discretize(inV, edgeV)
end


"""
    $(SIGNATURES)

Discretize given percentiles (weighted). The smallest `pctV[1]` of values in `inV` end up in bin 1, etc.
"""
function discretize_given_percentiles(inV :: Vector{F1}, 
    wtV :: AbstractVector{F2}, 
    pctV :: AbstractVector{F3}) where {F1, F2, F3}

   edgeV = bin_edges_from_percentiles(inV, wtV, pctV);
   return discretize(inV, edgeV)
end


## Discretize given bounds
# Equivalent to Discretizers LinearDiscretizer
function discretize(inV :: Vector{F1}, 
    edgeV :: AbstractVector{F2}) where {F1, F2}

    n = length(edgeV);
    outV = zeros(Int64, size(inV));
    for i1 = n : -1 : 2
        outV[inV .<= edgeV[i1]] .= i1 - 1;
    end
    outV[inV .<= edgeV[1]] .= 0;
    return outV
end



"""
Bin edges from percentiles (unweighted)
Lowest bin includes minimum of inV
"""
function bin_edges_from_percentiles(inV :: AbstractVector{F1}, 
    pctV :: AbstractVector{F2}) where {F1, F2}

    edgeV = quantile(inV, [zero(F2); pctV]);
    # Ensure that lowest point is inside edges
    edgeV[1] -= F1(1e-8);
    return edgeV
end


## Bin edges from percentiles (weighted)
function bin_edges_from_percentiles(inV :: AbstractVector{F1},  
    wtV :: AbstractVector{F2}, pctV :: AbstractVector{F3}) where {F1, F2, F3}

    @assert check_weights(wtV)  "Invalid weights"
    # Quantile is also a built in function
    edgeV = [minimum(inV) - F1(1e-8); quantile(inV, Weights(wtV), pctV)];
    edgeV[end] += F1(1e-8);
    return edgeV
end


"""
	$(SIGNATURES)

Count how many cases occur in each bin. Unweighted.
"""
function count_bins(inV :: AbstractVector{F1}, 
    edgeV :: AbstractVector{F2}) where {F1, F2}

    nBins = length(edgeV) - 1;
    cntV = Vector{Int}(undef, nBins);
    for iBin = 1 : nBins
        cntV[iBin] = sum(x -> inbin(x, edgeV, iBin), inV);
    end
    return cntV
end


"""
	$(SIGNATURES)

Count how many cases occur in each bin. Weighted.
"""
function count_bins(inV :: AbstractVector{F1}, 
    wtV :: AbstractVector{F2},
    edgeV :: AbstractVector{F3}) where {F1, F2, F3}

    @assert check_weights(wtV)  "Invalid weights"
    nBins = length(edgeV) - 1;
    massV = Vector{Float64}(undef, nBins);
    for iBin = 1 : nBins
        massV[iBin] = mapreduce(
            (x, wt) -> (inbin(x, edgeV, iBin) ? wt : zero(F2)), 
            +, inV, wtV);
    end
    return massV
end

inbin(x, edgeV, iBin) = (x > edgeV[iBin])  &&  (x <= edgeV[iBin+1]);

function check_weights(wtV :: AbstractVector{F1}) where F1
    isValid = true;
    if any_less(wtV, zero(F1))
        @warn "Negative weights"
        isValid = false;
    end
    return isValid
end


# ------------