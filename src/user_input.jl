"""
	$(SIGNATURES)

Ask user for a choice from a set of strings.
Returns chosen string or "" if no match.
"""
function ask_for_choice(questionStr :: String, choiceV :: Vector{String} = ["Yes", "No"])
	print(questionStr * "  ")
	print(choiceV);
	print("  ");
	ans1 = readline(stdin);
	idx = findfirst(isequal.(lowercase.(choiceV),  lowercase(ans1)));
	if isnothing(idx)
		outStr = "";
	else
		outStr = choiceV[idx];
	end
	return outStr
end


"""
	$(SIGNATURES)

Ask a yes/no question. Repeats until user makes a valid choice.
Returns `true` for "yes".
"""
function ask_yes_no(questionStr :: String)
	done = false;
	res = false;
	while !done
		outStr = ask_for_choice(questionStr, ["Yes", "No"]);
		if outStr == "Yes"
			done = true;
			res = true;
		elseif outStr == "No"
			done = true;
			res = false;
		end
	end
	return res
end


# -------------