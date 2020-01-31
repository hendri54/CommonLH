function display_test()
	@testset "DisplayLH" begin
		# @testset "sprintf" begin
		# 	fmtStr = "{:.1f} "
		# 	z = [1.11 2.22]
		# 	x = DisplayLH.sprintf(fmtStr, z)
		# 	@test x == "1.1 2.2 "
		# 	DisplayLH.printf(fmtStr, z)
		# end

		sV = ["aaaa aaaa", "bbb bbb bbb", "cccccc cccccc cccccc", "dddddddddd"];
		CommonLH.show_string_vector(sV, 25);
		lineV = CommonLH.string_vector_to_lines(sV, 25);
		@test length(lineV) == 3
		@test startswith(lineV[1], sV[1])
		@test startswith(lineV[2], sV[3])
		@test startswith(lineV[3], sV[4])
	end
end

# -----------