using CommonLH

# Must be outside of testset.
@common_fields test_fields begin
    x :: Float64
    # Comment
    y :: String
    # Parametric type
    z :: Vector{Int}
end

struct Foo
    @test_fields
    x1 :: Int
end

function struct_test()
    @testset "Structs" begin
        f = Foo(1.0, "y", [1,2], 3);
        @test f.x == 1.0;
        @test f.y == "y";
        @test f.z == [1,2];
        @test f.x1 == 3;
    end
end

@testset "Structs" begin
    struct_test();
end

# -----------