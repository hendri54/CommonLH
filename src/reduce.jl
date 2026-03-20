"""
	$(SIGNATURES)

Given a vector of mutable structs, compute a function of all numeric fields.
Immutable structs are skipped.

Example use case: Compute the mean and standard deviation of simulated model statistics.

`reduceFct` takes a vector of numeric inputs and returns a single numeric output that is of compatible size and type so it can be written back into an instance of the objects contained in `oVecV`.

To handle `Nan` or `missing`, make sure that `reduceFct` appropriately handles or skips them.

Optional input `fieldTypes` indicates which non-numeric field types to use as well.

This relies on `propertynames` to identify the fields to operate on. It uses `getproperty` and `setproperty!` to set those fields. These need to be appropriately overloaded for user defined types that do not store the properties "directly" (as accessed by `getfield`).

Limitation: Because the output object is of the same type as the input objects in `oVecV`, it is not possible to apply `reduceFct` that returns a different type from its inputs. For example, `mean` of integers does not work.

Change: exclude immutable fields, but keep scalars (which are immutable but can be changed!) +++
"""
function reduce_object_vector(oVecV :: Vector{T1},  reduceFct :: Function;
    fieldTypes :: Vector = []) where T1

    # Allocate output object
    oOut = deepcopy(oVecV[1]);
    # Loop over numeric fields
    pnV = propertynames(oOut);
    for pn in pnV
        #if !isimmutable(getproperty(oOut, pn))
            xM = reduce_one_field(oVecV, pn, reduceFct; fieldTypes = fieldTypes);
            if !isnothing(xM)
                setproperty!(oOut, pn, xM);
            end
        #end
    end
    return oOut
end


# Apply `reduceFct` to one field in a vector of objects.
# Returns `nothing` if reduction not possible.
function reduce_one_field(oVecV :: Vector{T1},  pn,  reduceFct :: Function;
    fieldTypes :: Vector = []) where T1

    n = length(oVecV);
    # Use getproperty instead of getfield (b/c getproperty can be overloaded)
    # @assert hasproperty(oVecV[1], pn)  "$(oVecV[1]) does not have property $pn"
    fieldM = getproperty(oVecV[1], pn);
    fType = typeof(fieldM);
    xM = nothing;

    fieldV = [getproperty(oVecV[iObj], pn)  for iObj = 1 : n];
    if isa(fieldV[1], AbstractArray)
        xM = reduce_array_vector(fieldV, reduceFct);
    else
        xM = reduce_scalar_vector(fieldV, reduceFct);
    end
    return xM


    # if (fType <: AbstractFloat)  ||  (fType ∈ fieldTypes)
    #     # Scalar field
    #     if hasmethod(reduceFct, (Vector{fType},))
    #         xM = reduceFct([getproperty(oVecV[iObj], pn) for iObj = 1 : n]);
    #     end

    # elseif isa(fieldM, AbstractArray)  &&  (eltype(fieldM) <: AbstractFloat)
    #     # Array field
    #     if hasmethod(reduceFct, (Vector{eltype(fieldM)},))
    #         xM = similar(fieldM);
    #         # Loop over elements in the field
    #         for j = 1 : length(xM)
    #             xM[j] = reduceFct([getproperty(oVecV[iObj], pn)[j] for iObj = 1 : n]);
    #         end
    #         @assert size(xM) == size(fieldM)  "Size mismatch: $(size(xM)) vs $(size(fieldM))"
    #     end
    # end

    # if !isnothing(xM)
    #     # Result can only be used if the resulting object matches `fieldM`
    #     @argcheck (typeof(xM) == fType)
    #     if hasmethod(size, (fType,))
    #         @argcheck (size(xM) == size(fieldM))
    #     end
    # end
    # return xM
end


"""
	$(SIGNATURES)

Reduce a `Vector{Array}` element by element. `reduceFct` is applied to the vector of `x[j]` for each index `j` where all the `x` from `fieldV` are stacked into a vector.

If `reduceFct` returns a different type, nothing is assigned. For example, the mean of `Int` values is not assigned.
"""
function reduce_array_vector(fieldV :: AbstractVector{Array{F1, N}}, 
    reduceFct) where {F1, N}

    n = length(fieldV);
    fType = typeof(fieldV[1]);

    # Array field
    if hasmethod(reduceFct, (Vector{eltype(fType)},))
        for iObj = 1 : n
            @argcheck size(fieldV[iObj]) == size(fieldV[1])
        end

        # Loop over elements in the field
        xM = similar(fieldV[1]);
        for j = eachindex(xM)
            # Reduce element by element
            valueV = [fieldV[iObj][j] for iObj = 1 : n];
            xr = reduceFct(valueV);
            if xr isa eltype(xM)
                xM[j] = xr;
            else
                xM = nothing;
                break;
            end
        end
    else
        xM = nothing;
    end
    if !isnothing(xM)
        @argcheck size(xM) == size(fieldV[1])  
        @argcheck (typeof(xM) == fType)
    end
    return xM
end


"""
	$(SIGNATURES)

Reduce a vector of "scalars" so that `reduceFct(fieldV)` is called directly.

If `reduceFct` returns a different type, nothing is assigned.
"""
function reduce_scalar_vector(fieldV :: AbstractVector{F1}, reduceFct) where F1
    fType = typeof(fieldV[1]);
    if hasmethod(reduceFct, (Vector{fType},))
        xr = reduceFct(fieldV);
        if xr isa fType
            xM = xr;
        else
            xM = nothing;
        end
    else
        xM = nothing;
    end
    return xM
end


# ----------------