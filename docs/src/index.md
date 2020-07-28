# CommonLH

This package collects general purpose code that does not "fit" into other packages with more well defined topics.

## Array operations

```@docs
scale_array!
```

## Vector operations

```@docs
bisecting_indices
find_indices
```

## Probabilities

The following operate on matrices that represent probabilities which sum to 1.

```@docs
validate_prob_matrix
validate_prob_vector
prob_j
prob_k
prob_j_k
prob_k_j
ev_given_j
ev_given_k
scale_prob_array!
```

## Displaying objects

```@docs
MultiIO
show_text_file
show_string_vector
```

--------------
