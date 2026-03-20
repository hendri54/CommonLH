"""
	$(SIGNATURES)

Retrieve a property from an object or its child objects.
If the property is not unique, returns the first match and then stops.
Returns `nothing` if not found.
"""
function retrieve_property(o, pName :: Symbol)
    if hasproperty(o, pName)
        outVal = getproperty(o, pName);
    else
        outVal = nothing;
        pn = propertynames(o);
        for propName in pn
            outVal = retrieve_property(getproperty(o, propName), pName);
            if !isnothing(outVal)
                break;
            end
        end
    end
    return outVal
end


"""
	$(SIGNATURES)

Retrieve a property in a child object of a given name.
Does not retrieve property from object itself.
This helps when properties are not unique.
"""
function retrieve_child_property(o, childName :: Symbol, pName :: Symbol)
    # First retrieve the child
    child = retrieve_property(o, childName);
    @assert !isnothing(child)  "Cannot find $childName"
    return retrieve_property(child, pName)
end


"""
	$(SIGNATURES)

Does object or a child object have a property?
"""
function has_property(o, pName :: Symbol)
    return !isnothing(retrieve_property(o, pName))
end

# -------------