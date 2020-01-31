# --------------  Keyword arguments


# test this +++++


"""
	$(SIGNATURES)

Object to hold default values for keyword arguments.
"""
mutable struct KwArgs
	d :: Dict{Symbol, Any}
end


"""
	$(SIGNATURES)

Retrieve a default value by name.
"""
function default_value(name :: Symbol, kwS :: KwArgs)
	@assert has_default(name, kwS)  "$name not found"
	return kwS.d[name]
end

function has_default(name :: Symbol, kwS :: KwArgs)
	return haskey(kwS.d, name)
end


"""
	$(SIGNATURES)

Retrieve either the default value or the override in `kwargs`.
"""
function kw_arg(name :: Symbol, kwS :: KwArgs; kwargs...)
	if has_default(name, kwS)
		defaultVal = default_value(name, kwS);
		found = true;
	else
		defaultVal = nothing
        found = false;
	end

	if haskey(kwargs, name)
		found = true;
		outVal = kwargs[name];
	else
		outVal = defaultVal;
	end
	@assert found  "Argument $name not found."
	return outVal
end

# --------------------