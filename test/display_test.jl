using Test
using CommonLH.DisplayLH

@testset "DisplayLH" begin
	@testset "sprintf" begin
		fmtStr = "{:.1f} "
		z = [1.11 2.22]
		x = DisplayLH.sprintf(fmtStr, z)
		@test x == "1.1 2.2 "
		DisplayLH.printf(fmtStr, z)
	end

    sV = ["aaaa aaaa", "bbb bbb bbb", "cccccc cccccc cccccc", "dddddddddd"];
    DisplayLH.show_string_vector(sV, 25);
end

# -----------