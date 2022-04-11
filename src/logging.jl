## -------------  Messages during long calibration

export log_msg

"""
	$(SIGNATURES)

Display a message during calibration. Messages differ in their 'logLevel' (an Integer ≥ 1). 
"""
function log_msg(logLevel :: Integer, io,  msgV :: AbstractVector{String})
    top_separator(logLevel, io);
    log_lines(logLevel, io, msgV);
    bottom_separator(logLevel, io);
end

log_msg(logLevel :: Integer, io, msg :: AbstractString) = 
    log_msg(logLevel, io, [msg]);

function top_separator(logLevel :: Integer, io)
    if logLevel == 1
        println(io, "\n");
    end
    separator_line(logLevel, io);
end


function separator_line(logLevel :: Integer, io)
    nRepeat = separator_length(logLevel);
    if nRepeat > 0
        println(io, repeat('-', nRepeat));
    end
    return nothing
end

function separator_length(logLevel :: Integer)
    if logLevel == 1
        nRepeat = 40;
    else
        nRepeat = 0;
    end
    return nRepeat
end

function bottom_separator(logLevel :: Integer, io)
    separator_line(logLevel, io);
    if logLevel == 1
        println(io, " ");
    end
end

function log_lines(logLevel :: Integer, io, msgV :: AbstractVector{String})
    indentStr = log_indent(logLevel);
    indentBlank = repeat(' ', length(indentStr));
    for (j, msg) in enumerate(msgV)
        if j == 1
            print(io, indentStr);
        else
            print(io, indentBlank);
        end
        println(io, msg);
    end
end

function log_indent(logLevel :: Integer)
    if logLevel == 1
        return ""
    else
        nSpaces = clamp(2 * (logLevel - 2), 0, 8);
        nDashes = 10 - nSpaces;
        return repeat(' ', nSpaces) * repeat('-', nDashes) * "  ";
    end
end

# ----------