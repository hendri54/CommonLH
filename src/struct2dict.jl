## -----------  struct2dict

"""
	$(SIGNATURES)

Struct that contains information about one node in the `Dict` created by `struct2dict`.
"""
struct NodeInfo{T}
    # type :: DataType
    size
    value :: T
end

NodeInfo(s :: Number) = NodeInfo{typeof(s)}(nothing, s);
NodeInfo(s :: AbstractString) = NodeInfo{String}(nothing, String(s));
NodeInfo(s :: Symbol) = NodeInfo{Symbol}(nothing, s);
# NodeInfo(s :: AbstractArray{F1}) where F1 <: AbstractFloat =
#     NodeInfo{typeof(s)}(size(s), s);

node_value(n :: NodeInfo{T}) where T = n.value;
node_type(n :: NodeInfo{T}) where T = T;
node_size(n :: NodeInfo{T}) where T = n.size;

Base.isequal(n1 :: NodeInfo{T}, n2 :: NodeInfo{T}) where T = 
    isequal(node_size(n1), node_size(n2))  &&  
    isequal(node_value(n1), node_value(n2));
Base.isequal(n1 :: NodeInfo{T1}, n2 :: NodeInfo{T2}) where {T1, T2} = false;


"""
	$(SIGNATURES)

Convert a `struct` to a nested `Dict`. Known leaf types, such as strings, arrays become `NodeInfo` entries in the `Dict`. `struct`s become their own `Dict`s.

The purpose is to convert a `struct` into a `Dict` of simple "built-in" types that can be serialized. Each leaf entry contains information about the `DataType` of the leaf, so that the object can be reconstructed. In case the data are saved to a format that does not preserve size information, the size of the object is also saved.
"""
function struct2dict(s)
    d = Dict{Symbol, Any}();
    # d[:ownType] = typeof(s);
    for pName in propertynames(s)
        d[pName] = struct2dict(getproperty(s, pName));
    end
    return d
end

# For each known type, `struct2dict` produces a `NodeInfo` object.
# The user can extend with new methods.
scalar2dict(s) = NodeInfo{typeof(s)}(nothing, s);
struct2dict(s :: Number) = scalar2dict(s);
struct2dict(s :: AbstractString) = scalar2dict(s);
struct2dict(s :: Symbol) = scalar2dict(s);
struct2dict(s :: Dict) = scalar2dict(s);

array2dict(s :: AbstractArray{T}) where T = NodeInfo{typeof(s)}(size(s), s);
struct2dict(s :: AbstractArray{F1}) where F1 <: Number = array2dict(s);
struct2dict(s :: AbstractArray{F1}) where F1 <: AbstractString = array2dict(s);
struct2dict(s :: AbstractArray{F1}) where F1 <: Symbol = array2dict(s);


"""
	$(SIGNATURES)

The inverse of `struct2dict`. Takes a fully initialized MUTABLE `struct` as input. Copies the values from the `Dict` into the `struct`.
Mismatches between `Dict` keys and `propertynames(s)` are ignored. That means: fields that are missing from the `Dict` are not initialized. Extra fields in the `Dict` are ignored.
"""
function dict2struct!(s, d :: Dict)
    # errorCnt = 0;
    @assert !isimmutable(s)  "Not mutable: $(typeof(s))"
    for pName in propertynames(s)
        if haskey(d, pName)
            if isa(d[pName], Dict)
                dict2struct!(getproperty(s, pName), d[pName]);
            else
                node2field!(s, pName, d[pName]);
            end
        end
    end
    return nothing
end


"""
	$(SIGNATURES)

Set one field in a `struct` from a `NodeInfo`. Catch errors and return `success` as `Bool`.
User can override for specific `NodeInfo` types `T`.
"""
function node2field!(s, pName :: Symbol, n :: NodeInfo{T}) where T
    success = true;
    try
        setproperty!(s, pName, node_value(n));
    catch
        success = false;
        nodeType = node_type(n);
        @warn """
            Cannot set property $pName of $(typeof(s))
              Node of type $nodeType
            """
    end
    return success
end

# ---------------