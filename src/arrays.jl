"""
$(SIGNATURES)

Scale each "row" (along dimension `d`) of array `x` to match the totals given in `totalV`. The result satisfies

`sum(selectdim(x, d, j)) == totalV[j]`
"""
function scale_array!(x :: AbstractArray{F1}, d :: Integer, totalV :: AbstractVector{F1}) where F1 <: AbstractFloat

    J = length(totalV);
    @assert J == size(x, d)  "Size mismatch"
    for j = 1 : J
        xd = selectdim(x, d, j);
        xd .*= (totalV[j] / sum(xd));
    end
    return nothing
end


"""
$(SIGNATURES)

Bracket an array between lower and upper bounds. In place.
"""
function bracket_array!(x :: F1, lb :: F1, ub :: F1) where F1 <: AbstractArray
    @assert size(x) == size(lb) == size(ub)
    for (k, v) in enumerate(x)
        if v > ub[k]
            x[k] = ub[k];
        elseif v < lb[k]
            x[k] = lb[k];
        end
    end
    return nothing
end

function bracket_array!(xM :: AbstractArray{F1}, lb :: F1, ub :: F1) where F1
    for (k, x) in enumerate(xM)
        if x > ub
            xM[k] = ub;
        end
        if x < lb
            xM[k] = lb;
        end
    end
end



# ------------