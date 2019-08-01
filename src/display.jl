module DisplayLH

using Formatting
using Printf

export show_string_vector


"""
## Display string vector on fixed with screen
"""
function show_string_vector(sV :: Vector{T1},  width :: T2 = 80) where
    {T1 <: AbstractString,  T2 <: Integer}

    n = length(sV);
    if n < 1
        return nothing
    end

    iCol = 0;
    for s in sV
        len1 = length(s);
        if len1 > 0
            if iCol + len1 > width
                println(" ")
                iCol = 0;
            end
            print(s);
            iCol = iCol + len1;
            print("    ");
            iCol = iCol + 4;
        end
    end
    println(" ")
end


"""
Print numeric vector (or array with 1 dim)

IN
    fmtStr
        formatting string that works with Formatting package
"""
function sprintf(fmtStr :: String, x :: Array{T}) where T <: Number
    x2 = vec(x)
    outStr = "";
    for xVal in x2
      outStr = outStr * Formatting.format(fmtStr, xVal)
    end
    return outStr
end

# Scalar input
function sprintf(fmtStr :: String, x :: T1) where T1 <: Number
    return sprintf(fmtStr, [x])
end


function printf(fmtStr :: String,  x :: Array{T}) where T <: Number
    print(sprintf(fmtStr, x));
    return nothing
end


end # module
