"""
	$(SIGNATURES)

Show a text file on the screen.
"""
function show_text_file(filePath; io = stdout)
    _, fName = splitdir(filePath);
    println(io, "----------  $fName  ----------");
    for line in eachline(filePath) 
        println(io, line);
    end
    println(io, "----------  [end] $fName  ----------");
    return nothing;
end


"""
    $(SIGNATURES)

Display string vector on fixed with screen.

# Arguments
- `width`: Width of screen in characters.
- `stringWidth`: If positive, pad all strings to this width. Strings that are longer remain unchanged.
"""
function show_string_vector(sV :: Vector{T1},  width :: Integer = 80;
        stringWidth = 0,
        io :: IO = stdout)  where T1 <: AbstractString

    isempty(sV)  &&  return nothing;

    iCol = 0;
    for s in sV
        len1 = length(s);
        if len1 > 0
            if len1 < stringWidth
                # Not efficient, but easy
                s = rpad(s, stringWidth);
                len1 = stringWidth;
            end
            if iCol + len1 > width
                println(io, " ")
                iCol = 0;
            end
            print(io, s);
            iCol = iCol + len1;
            print(io, "    ");
            iCol = iCol + 4;
        end
    end
    println(io, " ")
end



function string_vector_to_lines(sV :: Vector{T1}, width :: Integer = 80) where
    T1 <: AbstractString

    lineV = Vector{T1}();
    if isempty(sV)
        return lineV
    end

    n = length(sV);

    line = "";
    for s in sV
        if !isempty(s)
            if length(s) + length(line) > width
                # Start new line
                push!(lineV, line);
                line = "";
            end
            line = line * s * "    ";
        end
    end
    push!(lineV, line);
    return lineV
end


## ------------  Print to multiple IO streams 

"""
	$(SIGNATURES)

Object that holds multiple IO streams, so that a single `print` statement can be directed to all of them. Main use case: selectively write to optimization log and stdout.
This must be a subtype of IO for dispatch to work correctly.

Leads to method ambiguities, unless `print` and `println` are defined for each type.
E.g. `print(::IO, ::Unsigned)` vs `print(::MultiIO, args...)`.
Defining `print(::MultiIO, ::T) where T` does not help.

Based on https://discourse.julialang.org/t/issues-with-println-buffering-output-when-redirecting-stdout-to-a-txt-file/23738/13

# Example
```
fPath = "test.txt";
open(fPath, "w") do io
    mio = MultiIO([stdout, io]);
    print(mio, "Line 1\n");
    println(mio, "Line 2");
end
```
"""
struct MultiIO{T} <: IO
    ioV :: Vector{T}
end

function multi_print(io :: MultiIO, s)
    for io in io.ioV
        print(io, s);
    end
end

function multi_print(io :: MultiIO, args...)
    for io in io.ioV
        print(io, args);
    end
end

function multi_println(io :: MultiIO, s)
    for io in io.ioV
        println(io, s);
    end
end

function multi_println(io :: MultiIO, args...)
    for io in io.ioV
        println(io, args...);
    end
end

Base.print(io :: MultiIO, args...) = multi_print(io, args...);

# Avoid method ambiguity
Base.print(io :: MultiIO, s :: Union{SubString{String}, String}) = 
    multi_print(io, s);
Base.print(io :: MultiIO, x :: Unsigned) = multi_print(io, x);

Base.println(io :: MultiIO, args...) = multi_println(io, args...);

# Avoid method ambiguity (probably not needed; only `print is needed)`)
Base.println(io :: MultiIO, s :: Union{SubString{String}, String}) = 
    multi_println(io, s);


function print_flush(io :: MultiIO, args...)
    print(io, args...);
    flush(io);
end

function println_flush(io :: MultiIO, args...)
    println(io, args...);
    flush(io);
end

function Base.flush(io :: MultiIO)
    for io in io.ioV
        flush(io);
    end
end

# To avoid error "does not support ByteIO"
Base.write(io :: MultiIO, x :: UInt8) = print(io, x);


# """
# Print numeric vector (or array with 1 dim)

# IN
#     fmtStr
#         formatting string that works with Formatting package
# """
# function sprintf(fmtStr :: String, x :: Array{T}) where T <: Number
#     x2 = vec(x)
#     outStr = "";
#     for xVal in x2
#       outStr = outStr * Formatting.format(fmtStr, xVal)
#     end
#     return outStr
# end

# # Scalar input
# function sprintf(fmtStr :: String, x :: T1) where T1 <: Number
#     return sprintf(fmtStr, [x])
# end


# function printf(fmtStr :: String,  x :: Array{T}) where T <: Number
#     print(sprintf(fmtStr, x));
#     return nothing
# end

# ---------------------