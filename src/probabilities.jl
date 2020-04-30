# Probability computations


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
prob_j(m :: AbstractMatrix) = vec(sum(m, dims = 2));
prob_k(m :: AbstractMatrix) = vec(sum(m, dims = 1));
prob_j(m :: AbstractMatrix, j :: Integer) = sum(m[j,:]);
prob_k(m :: AbstractMatrix, k :: Integer) = sum(m[:, k]);
prob_j(m :: AbstractMatrix, j) = sum(m[j, :], dims = 2);
prob_k(m :: AbstractMatrix, k) = vec(sum(m[:, k], dims = 1));


"""
    $(SIGNATURES)

Conditional probability (j | k) or (k | j).
"""
prob_j_k(m :: AbstractMatrix, j, k :: Integer) = 
    m[j, k] ./ prob_k(m, k);
prob_k_j(m :: AbstractMatrix, k, j :: Integer) =
    m[j, k] ./ prob_j(m, j);

    
## -----------  Expected values

"""
	$(SIGNATURES)

Compute expected value of `x`, given row index `j`. Based on matrix of values `xM[j,k]` and matrix of probabilities (sum to 1) `prM[j, k]`.
"""
ev_given_j(x :: AbstractMatrix, prM :: AbstractMatrix, j :: Integer) = 
    sum([(prob_k_j(prM, k, j) * x[j, k])  for k = 1 : size(x, 2) ]);
ev_given_k(x :: AbstractMatrix, prM :: AbstractMatrix, k :: Integer) = 
    sum([(prob_j_k(prM, j, k) * x[j, k])  for j = 1 : size(x, 1) ]);
ev_given_j(x :: AbstractMatrix, prM :: AbstractMatrix) = 
    [ev_given_j(x, prM, j)  for j = 1 : size(x, 1)];
ev_given_k(x :: AbstractMatrix, prM :: AbstractMatrix) = 
    [ev_given_k(x, prM, k)  for k = 1 : size(x, 2)];


# ---------