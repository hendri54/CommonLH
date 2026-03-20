"""
    ObjectId

Complete, unique ID of a `ModelObject`

Contains own id and a vector of parent ids, so one knows exactly where the object
is placed in the model tree.
"""
struct ObjectId
    # Store IDs as vector, not tuple (b/c empty tuples are tricky)
    # "Youngest" member is positioned last in vector
    ids :: Vector{SingleId}
end


## ---------  Constructors

"""
	$(SIGNATURES)

Construct an ObjectId from a vector of `SingleId`.
"""
ObjectId() = ObjectId(Vector{SingleId}());

# Without a parent or index
function ObjectId(ownId :: SingleId)
    return ObjectId([ownId]);
end

# With parent; no index
function ObjectId(name :: Symbol, parentIds :: ObjectId = ObjectId())
    return ObjectId(vcat(parentIds.ids, SingleId(name)))
end

# With everything
function ObjectId(name :: Symbol, index :: Vector{T1},
    parentIds :: ObjectId = ObjectId()) where T1 <: Integer

    return ObjectId(vcat(parentIds.ids, SingleId(name, index)))
end

function ObjectId(name :: Symbol, idx :: T1,
    parentIds :: ObjectId = ObjectId()) where T1 <: Integer

    return ObjectId(vcat(parentIds.ids,  SingleId(name, [idx])))
end

ObjectId(name :: Symbol, descr :: String, 
    parentIds :: ObjectId = ObjectId()) = 
    ObjectId(vcat(parentIds.ids,  SingleId(name, descr)));


## ------  Parent info

function has_parent(oId :: ObjectId)
    return length(oId.ids) > 1
end

function get_parent_id(oId :: ObjectId)
    if has_parent(oId)
        return ObjectId(oId.ids[1 : (end-1)])
    else
        return ObjectId()
    end
end

is_parent_of(pId :: ObjectId,  oId :: ObjectId) = isequal(pId, get_parent_id(oId))

"""
	$(SIGNATURES)

Number of parents of an `ObjectId`.
"""
n_parents(pId :: ObjectId) = length(pId.ids) - 1;


"""
	$(SIGNATURES)

Make child ObjectId from parent ObjectId.
"""
function make_child_id(obj :: T1, name :: Symbol,
    index :: Vector{T2} = Vector{Int}()) where {T1, T2 <: Integer}

    return ObjectId(name, index, obj.objId)
end

# Make child ID from parent's ID
function make_child_id(parentId :: ObjectId, name :: Symbol,
    index :: Vector{T2} = Vector{Int}()) where {T2 <: Integer}

    return ObjectId(name, index, parentId)
end

make_child_id(parentId :: ObjectId, name :: Symbol, descr :: String) = 
    ObjectId(name, descr, parentId);


## -----------  Basic properties

Base.broadcastable(oId :: ObjectId) = Ref(oId);

"""
	$(SIGNATURES)

Checks whether two `ObjectId`s are the same. Does not consider descriptions.
"""
function Base.:(==)(id1 :: ObjectId,  id2 :: ObjectId)
    outVal = (length(id1.ids) == length(id2.ids))  &&  all(isequal.(id1.ids, id2.ids))
    return outVal
end

Base.isequal(id1 :: ObjectId,  id2 :: ObjectId) = id1 == id2;

# Must be implmented for storage in `Dict`.
Base.hash(id1 :: ObjectId, h :: UInt) = 
    hash(id1.ids, hash(:ObjectId, h));

"""
	$(SIGNATURES)

Description of an `ObjectId`.
"""
description(oId :: ObjectId) = description(own_id(oId));

own_index(oId :: ObjectId) = oId.ids[end].index
# Return own SingleId
own_id(oId :: ObjectId) = oId.ids[end];


"""
	$(SIGNATURES)

Return object's own name as `Symbol`.
"""
function own_name(oId :: ObjectId)
    return name(own_id(oId))
end



"""
	$(SIGNATURES)

Make string from ObjectId. Such as "p > q > r[4, 2]".
"""
function make_string(id :: ObjectId)
    outStr = "";
    for i1 = 1 : length(id.ids)
        if i1 > 1
            outStr = outStr  * ObjIdSeparator;
        end
        outStr = outStr * CommonLH.make_string(id.ids[i1]);
    end
    return outStr
end


"""
	$(SIGNATURES)

The inverse of `make_string`.
"""
function make_object_id(s :: T1) where T1 <: AbstractString
    if occursin(ObjIdSeparator, s)
        strV = split(s, ObjIdSeparator);
        singleIdV = similar(strV, SingleId);
        for (j, str) in enumerate(strV)
            singleIdV[j] = make_single_id(str);
        end
        return ObjectId(singleIdV)
    else
        return ObjectId(Symbol(s));
    end
end


"""
	$(SIGNATURES)

Show an object id.
"""
function Base.show(io :: IO,  id :: ObjectId)
    print(io,  "ObjectId: " * make_string(id));
end

# ----------------