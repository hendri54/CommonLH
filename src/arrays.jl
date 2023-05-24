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
function bracket_array!(x :: F1, lb :: Union{Nothing,F1}, 
        ub :: Union{Nothing,F1}) where F1 <: AbstractArray
    isnothing(lb)  ||  (@assert size(x) == size(lb));
    isnothing(ub)  ||  (@assert size(x) == size(ub));
    T = eltype(x);
    lbnd = typemin(T);
    ubnd = typemax(T);
    @inbounds for j in eachindex(x)
        isnothing(lb)  ||  (lbnd = lb[j]);
        isnothing(ub)  ||  (ubnd = ub[j]);
        x[j] = clamp(x[j], lbnd, ubnd);
    end
    # @assert size(x) == size(lb) == size(ub)
    # for (k, v) in enumerate(x)
    #     if v > ub[k]
    #         x[k] = ub[k];
    #     elseif v < lb[k]
    #         x[k] = lb[k];
    #     end
    # end
    return nothing
end

function bracket_array!(xM :: AbstractArray{F1}, 
        lb :: Union{Nothing,F1}, ub :: Union{Nothing,F1}) where F1
    isnothing(ub)  ||  bound_from_above!(xM, ub);
    isnothing(lb)  ||  bound_from_below!(xM, lb);
end

function bound_from_above!(xM :: AbstractArray, ub)
    for (k, x) in enumerate(xM)
        if x > ub
            xM[k] = ub;
        end
    end
    return nothing
end

function bound_from_below!(xM :: AbstractArray, lb)
    for (k, x) in enumerate(xM)
        if x < lb
            xM[k] = lb;
        end
    end
    return nothing
end

# ------------