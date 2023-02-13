function display_test()
	@testset "DisplayLH" begin
		# @testset "sprintf" begin
		# 	fmtStr = "{:.1f} "
		# 	z = [1.11 2.22]
		# 	x = DisplayLH.sprintf(fmtStr, z)
		# 	@test x == "1.1 2.2 "
		# 	DisplayLH.printf(fmtStr, z)
		# end

		sV = ["aaaa aaaa", "bbb bbb bbb", "cccccc cccccc cccccc", "dddddddddd",
			"eee", "fff", "ggg ggg ggg"];
		stringWidth = maximum(length.(sV));
		CommonLH.show_string_vector(sV, 2 * stringWidth + 6; 
			stringWidth);
		lineV = CommonLH.string_vector_to_lines(sV, 25);
		@test length(lineV) == 4;
		@test startswith(lineV[1], sV[1])
		@test startswith(lineV[2], sV[3])
		@test startswith(lineV[3], sV[4])
	end
end

function multi_io_test()
	@testset "MultIO" begin
		fPath = joinpath(test_dir(), "multi_io_test.txt");
		open(fPath, "w") do io
			mio = MultiIO([stdout, io]);
			print(mio, "Line 1\n");
			println(mio, "Line 2");
		end
		lineV = readlines(fPath);
		for j = 1 : 2
			@test lineV[j] == "Line $j"
		end
	end
end

@testset "Display" begin
	display_test()
	multi_io_test()
end

# -----------