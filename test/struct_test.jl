using Test, CommonLH

struct RTP2
    r1
    r2
end

struct RTP3
    r4
    r2
end

struct RTP1
    x :: RTP2
    y :: RTP3
end



@testset "StructLH" begin
    x = RTP2(1, 2);
    y = RTP3(4, 5);
    z = RTP1(x, y);

	@test has_property(z, :r1)
	@test !has_property(z, :r12)
    r1 = retrieve_property(z, :r1);
    @test r1 == x.r1
    r2 = retrieve_property(z, :r2);
    @test r2 == x.r2
    r3 = retrieve_property(z, :r3);
    @test isnothing(r3)
    r4 = retrieve_property(z, :x);
    @test isa(r4, RTP2)
end

# ---------------
