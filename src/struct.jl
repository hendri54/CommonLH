function retrieve_property(o, pName :: Symbol)
    if isdefined(o, pName)
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

function has_property(o, pName :: Symbol)
    return !isnothing(retrieve_property(o, pName))
end

# ----------------