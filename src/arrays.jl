
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

# ------------