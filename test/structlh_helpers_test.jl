using CommonLH, Test

@common_fields set1 begin
    x :: Int
    y :: Float64
end

struct Foo
    @set1
    z
end


function common_fields_test()
    @testset "Common fields macro" begin
        f = Foo(1, 2.2, "abc");
        @test f.x == 1
        @test f.y == 2.2
        @test f.z == "abc"
	end
end

@testset "Helpers" begin
    common_fields_test();
end

# -------------