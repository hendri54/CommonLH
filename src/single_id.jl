## ----------  SingleId

"""
    SingleId

Id for one object or object vector. 
Does not keep track of location in model.
Keeps track of `name` (Symbol identifier), `index`, and `description` (for display purposes).

`index` is used when there is a vector or matrix of objects of the same type
`index` is typically empty (scalar object) or scalar (vector objects)
"""
struct SingleId
    name :: Symbol
    index :: Vector{Int}
    description :: String
end

"""
	$(SIGNATURES)

Constructor for `SingleId` from `name` only.
"""
SingleId(name :: Symbol) = SingleId(name, Vector{Int}(), "");

SingleId(name :: Symbol, idx :: T1, descr = "") where T1 <: Integer =
    SingleId(name, [idx], descr);

"""
	$(SIGNATURES)

Constructor for a `SingleId` with index.

# Example
```
SingleId(:myId, [2, 1])
```
"""
SingleId(name :: Symbol, idxM :: Vector{I1}) where I1 <: Integer =
    SingleId(name, idxM, "");

SingleId(name :: Symbol, descr :: String) = SingleId(name, Vector{Int}(), descr);


## ----------  Access

Base.broadcastable(s :: SingleId) = Ref(s);

"""
	$(SIGNATURES)

Description of a `SingleId`.
"""
description(s :: SingleId) = s.description;

name(s :: SingleId) = s.name;
index(s :: SingleId) = s.index;

"""
	$(SIGNATURES)

Does `SingleId` have an index, indicating that it is part of a `Vector` of objects?
"""
has_index(this :: SingleId) = !Base.isempty(this.index)

function Base.:(==)(id1 :: SingleId, id2 :: SingleId)
    return (id1.name == id2.name)  &&  (id1.index == id2.index)
end

Base.isequal(id1 :: SingleId, id2 :: SingleId) = 
    id1 == id2;

Base.:(==)(id1V :: Vector{SingleId},  id2V :: Vector{SingleId}) = 
    all(isequal.(id1V, id2V));

Base.isequal(id1V :: Vector{SingleId}, id2V :: Vector{SingleId}) = 
    all(isequal.(id1V, id2V));

# Must be implmented for storage in `Dict`.
Base.hash(id1 :: SingleId, h :: UInt) = 
    hash(id1.name, hash(id1.index, hash(:SingleId, h)));


## ----------------  Show

# Make a string of the form "x[2, 1]"
# function show_string(s :: SingleId)
#     outStr = string(s.name);
#     if has_index(s)
#         outStr = outStr * "$(index(s))";
#     end
#     return outStr
# end

Base.show(io :: IO,  s :: SingleId) = 
    print(io,  "SingleId:  $(make_string(s))");



"""
	$(SIGNATURES)

Make a string from a `SingleId`. Such as "x[2, 1]".
"""
function make_string(id :: SingleId)
    if !has_index(id)
        outStr = "$(name(id))"
    elseif length(id.index) == 1
        outStr = "$(name(id))$(index(id))"
    else
        outStr = "$(name(id))$(index(id))"
    end
    return outStr
end


"""
	$(SIGNATURES)

The inverse of [`make_string`](@ref).
"""
function make_single_id(s :: T1) where T1 <: AbstractString
    if occursin('[', s)
        # Pattern "id1[4, 3]"
        m = match(r"(.+)\[([0-9, ]+)+\]", s);
        idxV = parse.(Int, split(m[2], ","));
        sId = SingleId(Symbol(m[1]),  idxV);
    else
        sId = SingleId(Symbol(s));
    end
    return sId
end


# ----------------