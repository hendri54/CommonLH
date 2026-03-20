"""
	$(SIGNATURES)

Object that holds result from traversing an object and applying a function to each property.

Contains the name of the object (typically the field name in the parent object), its `DataType`, the returned function value. Also contains a `Vector{ApplyFctResult}` that holds the same information for each child object.
"""
mutable struct ApplyFctResult
    name :: Symbol
    type :: DataType
    fVal
    children :: Union{Nothing, Vector{ApplyFctResult}}
end

"""
	$(SIGNATURES)

Name of object.
"""
obj_name(x :: ApplyFctResult) = x.name;

"""
	$(SIGNATURES)

Type of object.
"""
obj_type(x :: ApplyFctResult) = x.type;

"""
	$(SIGNATURES)

Function value or `nothing`.
"""
fct_value(x :: ApplyFctResult) = x.fVal;

"""
	$(SIGNATURES)

Child objects, excluding those that contain no function values (themselves, or their children).
"""
children(x :: ApplyFctResult) = x.children;

function child_names(x :: ApplyFctResult)
    if isnothing(children(x))
        return nothing;
    else
        return [obj_name(child)  for child in children(x)]
    end
end


Base.show(io :: IO, a :: ApplyFctResult) =
    print(io, "ApplyFctResult $(obj_name(a)) with children $(child_names(a))");


"""
	$(SIGNATURES)

Function returns false when parsing object tree should stop at this object. Predefined as `false` for common "built-in" types, such as `Number`, `Symbol`, `Array`.
"""
continue_parsing(x) = true;
continue_parsing(::Number) = false;
continue_parsing(::Symbol) = false;
continue_parsing(::AbstractDict) = false;
continue_parsing(::AbstractString) = false;
continue_parsing(::AbstractArray) = false;
continue_parsing(::DataType) = false;

"""
	$(SIGNATURES)

Apply function `f` to all properties of an object and its children.
Stop parsing child objects if `continue_parsing(x) == false`.
Returns an `ApplyFctResult` object.

Beware: Some functions, such as `sum`, have fallback methods that apply to `Any`. That leads to crashes.

Argument `maxLevels` limits the number of recursions and avoids stack overflow if something goes wrong.
"""
function apply_fct_to_object(x, xName :: Symbol, f :: Function;
    maxLevels = 5)
    if continue_parsing(x)
        childV = apply_fct_to_children(x, f; maxLevels = (maxLevels - 1));
    else
        childV = nothing;
    end
    if hasmethod(f, (typeof(x), ))
        fValue = f(x);
    else
        fValue = nothing;
    end
    return ApplyFctResult(xName, typeof(x), fValue, childV)    
end


# Returns a vector of entries, skipping those with `f(x) == nothing` and no children with entries.
# Returns `nothing` for an object without useful info.
function apply_fct_to_children(x, f; maxLevels = 5)
    if maxLevels < 1
        return nothing
    end
    nameV = propertynames(x);
    if isempty(nameV)
        return nothing
    end
    resultV = Vector{ApplyFctResult}();
    for cName in nameV
        child = getproperty(x, cName);
        if continue_parsing(child)
            grandChildV = apply_fct_to_children(child, f; 
                maxLevels = (maxLevels - 1));
        else
            grandChildV = nothing;
        end
        if hasmethod(f, (typeof(child), ))
            fValue = f(child);
        else
            fValue = nothing;
        end
        if !isnothing(fValue) || !isnothing(grandChildV)
            push!(resultV, ApplyFctResult(cName, typeof(child), fValue, grandChildV));
        end
    end
    if isempty(resultV)
        return nothing
    else
        return resultV
    end
end


## ------------  Display structure of an object

"""
	$(SIGNATURES)

Returns a description for an object. `Nothing` is the default.

Define this for user defined types to return a `Vector{String}` or `Matrix{String}` that can be formatted as a table. [`desribe_object`](@ref) also shows descriptions of child objects.
"""
describe(x) = nothing;


"""
	$(SIGNATURES)

Write object description, including child objects, to IO.
"""
function show_description(io :: IO, x)
    [println(io, line)  for line in describe_object(x)];
    return nothing
end

show_description(x) = show_description(stdout, x);


"""
	$(SIGNATURES)

Describe an object and its children. Recursively calls `describe` and returns a vector of strings.

The default return value for `describe` is nothing. Then the object is not displayed.
Otherwise, the return is passed through `format_describe` for formatting. The result is an indented list which visualizes the structure of parent-child relationships as well.
"""
function describe_object(x)
    xResult = apply_fct_to_object(x, :Top, describe);
    return describe_result(xResult);
end

function describe_result(x :: ApplyFctResult; level = 0)
    outV = Vector{String}();
    indentStr = repeat("  ", level);
    push!(outV, "$indentStr$(obj_name(x))");

    # Own description or function values
    fVals = fct_value(x);
    if !isnothing(fVals)
        fmtStr = format_describe(fVals, level + 1);
        if isa(fmtStr, AbstractVector)
            for fVal in fmtStr
                push!(outV, fVal);
            end
        else
            push!(outV, fmtStr);
        end
    end
    if !isnothing(children(x))
        for child in children(x)
            append!(outV, describe_result(child; level = level + 1));
        end
    end
    return outV
end

indent_string(level) = repeat("  ", level);

format_describe(x, level :: Integer) = indent_string(level) * "$x";
format_describe(x :: AbstractString, level :: Integer) = indent_string(level) * x;
format_describe(x :: AbstractVector{S1}, level :: Integer) where S1 <: AbstractString =
    [format_describe(s, level)  for s in x];

format_describe(x :: AbstractMatrix{S1}, level :: Integer) where S1 <: AbstractString = 
    [format_describe(x[ir,1] * ":  " * x[ir, 2], level) for ir = 1 : size(x, 1)];

# -------------