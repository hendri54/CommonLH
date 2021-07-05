"""
    $(SIGNATURES)

Check a scalar: should be real, finite, not nan, in optional bounds.
Real is implied by being `AbstractFloat`.
"""
function check_float(x :: T1; lb = nothing, ub = nothing) where T1 <: AbstractFloat
    isValid = true;
    if !isfinite(x)
        isValid = false; 
        @warn "Not finite"
    end
    if !isnothing(lb)  &&  (x < lb - 1e-8)
        isValid = false;
        @warn "Below $lb"
    end
    if !isnothing(ub)  &&  (x > ub + 1e-8)
        isValid = false;
        @warn "Above $ub"
    end
    if !isValid
        println("Input value: $x");
    end
    return isValid
end

# Catches cases where the input is not `AbstractFloat`
function check_float(x; kwargs...)
    @warn "Not an AbstractFloat: $x"
    return false
end


"""
	$(SIGNATURES)

Check that a numeric array is finite, not NaN, and inside bounds.
"""
function check_float_array(m :: AbstractArray{T1}, 
    lb :: T2, ub :: T2) where {T1 <: AbstractFloat, T2 <: AbstractFloat}

    isValid = true;

    anyInf = any(x -> !isfinite(x), m);
    if anyInf
        isValid = false;
        nInf = sum(x -> !isfinite(x), m);
        @warn "$nInf elements not finite"
    end

    validLb = !isfinite(lb)  ||  all(x -> x >= lb, m);
    if !validLb
        isValid = false;
        mMin, idxMin = findmin(m);
        @warn """
            Array lower bound violated: $mMin < $lb
            at  $idxMin
            """
    end

    validUb = !isfinite(ub)  ||  all(x -> x <= ub, m);
    if !validUb
        isValid = false;
        mMax, idxMax = findmax(m);
        @warn """
            Array upper bound violated: $mMax < $ub
            at  $idxMax
            """
    end

    return isValid
end


"""
	$(SIGNATURES)

Check that an array is monotone along one dimension (weak or strict).

Based on `diff` in `Base`.
"""
function is_monotone(a :: AbstractArray{T,N}, d :: Integer; 
    increasing, strict, atol = zero(T)) where {T,N}

    1 <= d <= N || throw(ArgumentError("dimension $d out of range (1:$N)"));

    r = axes(a);
    r0 = ntuple(i -> i == d ? UnitRange(1, last(r[i]) - 1) : UnitRange(r[i]), N);
    r1 = ntuple(i -> i == d ? UnitRange(2, last(r[i])) : UnitRange(r[i]), N);

    v0 = view(a, r0...);
    v1 = view(a, r1...);

    if increasing
        strict  ?  (op = >)  :  (op = >=);
    else
        strict  ?  (op = <)  :  (op = <=);
    end

    success = true;
    for idx in eachindex(v1)
        # E.g.: v1-v0 > -1e-8
        op(v1[idx] - v0[idx], -atol)  ||  (success = false; break);
    end
    return success
end

# ------------------