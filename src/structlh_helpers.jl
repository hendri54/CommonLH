"""
	$(SIGNATURES)

Macro to set common fields in structs. See
https://discourse.julialang.org/t/julia-learning-macros-metaprogramming/45753/3

# Example
```
@common_fields set1 begin
    x :: Int
    y :: Float64
end

struct Foo
    @set1
    z
end
```
"""
macro common_fields(name, definition)
    return quote
        macro $(esc(name))()
            esc($(Expr(:quote, definition)))
        end
    end
end

# ----------------