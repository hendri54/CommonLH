using Test
using CommonLH

struct AF1
    x
    y
end

function make_test_af_object()
    return AF1(AF1(1.0, AF1(2.0, "x")),  AF1(2.0, nothing))
end

function CommonLH.describe(x :: AF1)
    return "AF1 object with children $(x.x) and $(x.y)"
end

function CommonLH.describe(x :: Float64)
    return "Float64 with value $x"
end

function apply_fct_test()
    # Note that `sum` has methods for any object. Cannot be used for testing.
    @testset "Apply function to object" begin
        x = 1 : 3;
        xResult = apply_fct_to_object(x, :x, sum);
        @test obj_name(xResult) == :x;
        @test obj_type(xResult) == typeof(x);
        @test fct_value(xResult) == sum(x);
        @test isnothing(children(xResult))

        x = make_test_af_object()
        xResult = apply_fct_to_object(x, :x, abs);
        @test obj_name(xResult) == :x;
        @test obj_type(xResult) == typeof(x);
        @test isnothing(fct_value(xResult));
        @test length(children(xResult)) == 2

        child1 = children(xResult)[1];
        @test length(children(child1)) == 2
    end
end

function describe_test()
    @testset "Describe object" begin
        x = make_test_af_object();
        outV = describe_object(x)
        @test isa(outV, Vector{String})
        @test length(outV) > 5
        for j = 1 : length(outV)
            println(outV[j])
        end
    end
end

@testset "Apply functions" begin
    apply_fct_test()
    describe_test()
end

# ----------------