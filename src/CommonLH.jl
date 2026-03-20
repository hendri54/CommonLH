module CommonLH

using ArgCheck, DocStringExtensions, Format, Printf, StatsBase

# Check
export check_float, check_float_array, is_monotone
# Display
export show_text_file, show_string_vector
export MultiIO, print_flush, println_flush
# Keyword arguments
export KwArgs, default_value, has_default, kw_arg
# User input
export ask_for_choice, ask_yes_no
# Vector
export bisecting_indices, findfirst_equal, find_indices, find_index,
    all_at_least, all_at_most, all_greater, all_less,
    any_at_least, any_at_most, any_greater, any_less,
    any_nan
# Grids
export AbstractGrid, LinearGrid, LinSpacedGrid, PowerSpacedGrid, grid, intervals
# Probability matrices
export validate_prob_matrix, validate_prob_vector, prob_j, prob_k, prob_j_k, prob_k_j, ev_given_j, ev_given_k, scale_prob_array!
# Arrays
export bracket_array!, scale_array!
# Discretize
export discretize, bin_edges_from_percentiles, discretize_given_percentiles;
export discretize_from_ub, count_bins;

include("kwargs.jl")
include("check.jl")
include("comparisons.jl");
include("display.jl");
include("logging.jl");
include("user_input.jl")
include("vector.jl")
include("grids.jl")
include("probabilities.jl")
include("arrays.jl");
include("stats/discretize.jl");


# --- Merged from StructLH ---
export @common_fields
export retrieve_property, has_property, retrieve_child_property
export merge_object_arrays!, reduce_object_vector
export ApplyFctResult, apply_fct_to_object, obj_name, obj_type, fct_value, children
export describe, describe_object, show_description
export NodeInfo, struct2dict, dict2struct!
# Reductions
export reduce_scalar_vector, reduce_array_vector

# --- Merged from StructLH ---
include("structlh_helpers.jl");
include("retrieve.jl")
include("reduce.jl");
include("struct2dict.jl")
include("traverse_object.jl")

"""
    merge_object_arrays!

Merge all arrays (and vectors) from object `oSource` into the corresponding arrays
in another object `oTg` (at given index values `idxV`).
If target does not have corresponding field: behavior is governed by `skipMissingFields`.

# Arguments
- idxV
    `Vector{Integer}` or other iterable with integer results. Indexes the first dimension of each object to be copied.
    The assignment is: `oSource.x[i1,:] => oTg.x[idxV[i1],:]`.
"""
function merge_object_arrays!(oSource, oTg, idxV,
    skipMissingFields :: Bool; dbg :: Bool = false)

    for propName in propertynames(oSource)
        xSrc = getproperty(oSource, propName);
        if isa(xSrc,  Array)
            # Does target have this field?
            if hasproperty(oTg, propName)
                xTg = getproperty(oTg, propName);
                if dbg
                    @assert size(xSrc, 1) == length(idxV)
                    @assert size(xSrc)[2:end] == size(xTg)[2:end] "Size mismatch: $(size(xSrc)) vs $(size(xTg))"
                end
                # The n-dim array code also works for Vectors, but is less efficient.
                if isa(xSrc, Vector)
                    xTg[idxV] .= xSrc;
                elseif isa(xSrc, Matrix)
                    xTg[idxV, :] .= xSrc;
                else
                    # For multidimensional arrays (we don't know the dimensions!)
                    # we need to loop over "rows". This is expensive.
                    for (i1, idx) in enumerate(idxV)
                        # This selects target "row" `idx`
                        tgView = selectdim(xTg, 1, idx);
                        # Copy source "row" `i1` into target row (in place, hence [:])
                        tgView[:] = selectdim(xSrc, 1, i1);
                    end
                end
            elseif !skipMissingFields
                error("Missing field $propName in target object")
            end
        end
    end
    return nothing
end


# --- Merged from ModelObjectsLH ---
export SingleId, has_index, make_string, make_single_id
export ObjectId, make_object_id, make_child_id, own_name, n_parents, description
export ModelSwitches
export ModelObject, is_model_object, get_object_id,
    collect_model_objects, collect_model_objects_for_any, collect_object_ids, get_child_objects, find_object, find_only_object, get_value
export object_structure, show_object_structure

const ObjIdSeparator = " > ";

"""
    ModelObject

Abstract model object
Must have field `objId :: ObjectId` that uniquely identifies it
May contain a ParamVector, but need not.

Child objects may be vectors. Then the vector must have a fixed element type that is
a subtype of `ModelObject`
"""
abstract type ModelObject end

"""
	$(SIGNATURES)

Switches from which `ModelObject` is constructed.
"""
abstract type ModelSwitches end

# --- Merged from ModelObjectsLH ---
include("single_id.jl");
include("object_id.jl");
# include("model_switches.jl");
include("m_objects.jl");


end # module
