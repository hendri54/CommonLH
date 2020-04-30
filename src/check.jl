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
function check_float_array(m :: Array{T1}, lb :: T2, ub :: T2) where {T1 <: AbstractFloat, T2 <: AbstractFloat}

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

# ------------------