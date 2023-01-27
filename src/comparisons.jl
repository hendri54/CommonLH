## --------  Comparisons
# Easier to write versions that check whether all elements of a vector are inside bounds
# Must be efficient!

"""
	$(SIGNATURES)

Check that all elements are above a scalar lower bound.
"""
all_at_least(xV, lb :: Real) = all(x -> x >= lb, xV);

all_at_least(xV :: AbstractArray{T1,N}, lbV :: AbstractArray{T2,N}) where {T1,T2,N} =
    all(j -> xV[j] >= lbV[j], eachindex(xV));

"""
	$(SIGNATURES)

Check that all elements are below a scalar upper bounds.
"""
all_at_most(xV, ub :: Real) = all(x -> x <= ub, xV);

all_at_most(xV :: AbstractArray{T1,N}, lbV :: AbstractArray{T2,N}) where {T1,T2,N} =
    all(j -> xV[j] <= lbV[j], eachindex(xV));

"""
	$(SIGNATURES)

Strictly check that all elements are above a lower bound.

# Example
```
julia> all_greater([1.0, 2.0], 0.9999; atol = 0.01)
true
```
"""
all_greater(xV, lb :: F1; atol = zero(F1)) where F1 <: Real = 
    all(x -> x > lb - atol, xV);

all_greater(xV :: AbstractArray{<:Real}, yV :: AbstractArray{T}; atol = zero(T)) where T <: Real =
    all(map((x,y) -> x > y - atol,  xV, yV));

"""
	$(SIGNATURES)

Strictly check that all elements are below an upper bound.
"""
all_less(xV, ub :: F1; atol = zero(F1)) where F1 <: Real =  
    all(x -> x < ub + atol, xV);

all_less(xV :: AbstractArray{<:Real}, yV :: AbstractArray{T}; atol = zero(T)) where T <: Real =
    all(map((x,y) -> x < y + atol,  xV, yV));

"""
	$(SIGNATURES)

Check that at least some element is above a lower bound.
"""
any_at_least(xV, lb) = any(x -> x >= lb, xV);

"""
	$(SIGNATURES)

Check that at least some element is below an upper bound.
"""
any_at_most(xV, ub) = any(x -> x <= ub, xV);

"""
	$(SIGNATURES)

Strictly check that at least some element is above a lower bound.
"""
any_greater(xV, lb :: F1; atol = zero(F1)) where F1 = 
    any(x -> x > lb + atol, xV);

"""
	$(SIGNATURES)

Check that at least some element is below an upper bound.
"""
any_less(xV, ub :: F1; atol = zero(F1)) where F1 =  
    any(x -> x < ub - atol, xV);

"""
	$(SIGNATURES)

Check if any array element is NaN.
"""
any_nan(xV) = any(x -> isnan(x), xV);


# ----------------