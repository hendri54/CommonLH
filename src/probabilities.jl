"""
	$(SIGNATURES)

Validate a probability matrix. Elements are expected to sum to 1.
"""
function validate_prob_matrix(probM :: AbstractMatrix{T1}) where T1 <: AbstractFloat
    isValid = all_at_least(probM, 0.0)  &&  all_at_most(probM, 1.0);
    isValid = isValid  &&  isapprox(sum(probM), 1.0);
    return isValid
end


"""
	$(SIGNATURES)

Validate a probability vector. Elements are expected to sum to 1.
"""
validate_prob_vector(probV :: AbstractVector{T1}) where T1 <: AbstractFloat = 
    validate_prob_matrix(probV');


"""
	$(SIGNATURES)

Conditional probabilities of rows or columns given a probability matrix.
"""
prob_j(m :: AbstractMatrix{T1}) where T1 <: AbstractFloat = vec(sum(m, dims = 2));
prob_j(m :: AbstractMatrix{T1}, j :: Integer) where T1 <: AbstractFloat = 
    sum(m[j,:]);
prob_j(m :: AbstractMatrix{T1}, j) where T1 <: AbstractFloat = 
    sum(m[j, :], dims = 2);

"""
	$(SIGNATURES)

Conditional probabilities of rows or columns given a probability matrix.
"""
prob_k(m :: AbstractMatrix{T1}) where T1 <: AbstractFloat = vec(sum(m, dims = 1));
prob_k(m :: AbstractMatrix{T1}, k :: Integer) where T1 <: AbstractFloat = 
    sum(m[:, k]);
prob_k(m :: AbstractMatrix{T1}, k) where T1 <: AbstractFloat = 
    vec(sum(m[:, k], dims = 1));


"""
    $(SIGNATURES)

Conditional probability (j | k).
"""
prob_j_k(m :: AbstractMatrix, j, k :: Integer) = 
    m[j, k] ./ prob_k(m, k);

"""
    $(SIGNATURES)

Conditional probability (k | j).
"""
prob_k_j(m :: AbstractMatrix, k, j :: Integer) =
    m[j, k] ./ prob_j(m, j);

    
## -----------  Expected values

"""
	$(SIGNATURES)

Compute expected value of `x`, given row index `j`. Based on matrix of values `xM[j,k]` and matrix of probabilities (sum to 1) `prM[j, k]`.
"""
ev_given_j(x :: AbstractMatrix, prM :: AbstractMatrix, j :: Integer) = 
    sum([(prob_k_j(prM, k, j) * x[j, k])  for k = 1 : size(x, 2) ]);
ev_given_j(x :: AbstractMatrix, prM :: AbstractMatrix) = 
    [ev_given_j(x, prM, j)  for j = 1 : size(x, 1)];


"""
	$(SIGNATURES)

Compute expected value of `x`, given column index `k`. Based on matrix of values `xM[j,k]` and matrix of probabilities (sum to 1) `prM[j, k]`.
"""
ev_given_k(x :: AbstractMatrix, prM :: AbstractMatrix, k :: Integer) = 
    sum([(prob_j_k(prM, j, k) * x[j, k])  for j = 1 : size(x, 1) ]);
ev_given_k(x :: AbstractMatrix, prM :: AbstractMatrix) = 
    [ev_given_k(x, prM, k)  for k = 1 : size(x, 2)];


"""
    $(SIGNATURES)

Given an array of probabilities: ensure that all are in [0, 1]. 
Error if bounds violation larger than rounding errors.
Make sure that sum does not exceed an upper bound.
"""
function scale_prob_array!(m :: AbstractArray{F1}; 
    maxSum :: F1 = one(F1), fSmall = F1(.0000001)) where F1 <: Number

    @assert all_at_least(m, -fSmall)  "Negative probabilities"
    @assert all_at_most(m, one(F1) + fSmall)  "Probabilities above 1"

    clamp!(m, zero(F1), one(F1));

    pSum = sum(m);
    @assert (pSum < maxSum + fSmall)  "Sum too large: $pSum > $maxSum";
    if pSum > maxSum
        m .*= ((maxSum - fSmall) / pSum);
    end
    return nothing
end


# ---------