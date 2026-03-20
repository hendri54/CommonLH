using CommonLH
using Random, Test


# Construct ROV object with child objects
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

mutable struct ROV
    x
    y
    z
end

function string_sum(sV :: Vector{String})
    outStr = "";
    for s in sV
        outStr = outStr * s;
    end
    return outStr
end

# Because `hasmethod(sum, Tuple{Vector{Any}})== true`, but `sum(["a", "b"])` errors, we cannot use sum for the test
function float_sum(sV :: Vector{F1}) where F1 <: Real
    return sum(sV);
end


function retrieve_test()
    @testset "Retrieve property" begin
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

        r2a = retrieve_child_property(z, :x, :r2);
        @test r2a == x.r2
        r2b = retrieve_child_property(z, :y, :r2);
        @test r2b == y.r2
        # Try an object that is in a different child
        @test isnothing(retrieve_child_property(z, :x, :r4))
    end
end

function reduce_ov_test()
    @testset "Reduce object vector" begin
        rov1 = ROV(rand(3,2), 1.23, "a");
        rov2 = ROV(rand(3,2), 3.2, "b");
        rov3 = ROV(rand(3,2), 0.6, "c");
        objV = [rov1, rov2, rov3];
        oOut = reduce_object_vector(objV, float_sum);

        @test oOut.y ≈ rov1.y .+ rov2.y .+ rov3.y
        @test oOut.x ≈ rov1.x .+ rov2.x .+ rov3.x

        oOut2 = reduce_object_vector(objV, string_sum, fieldTypes = [String]);
        @test oOut2.z == "abc"
    end
end


mutable struct STD1
    x
end

mutable struct STD2
    x
    y
end

Base.isequal(s1 :: STD1, s2 :: STD1) = isequal(s1.x, s2.x);
Base.isequal(s1 :: STD2, s2 :: STD2) =
    isequal(s1.x, s2.x)  &&  isequal(s1.y, s2.y);

function struct2dict_test()
    @test isequal(struct2dict(1.2), NodeInfo(1.2))
    @test isequal(struct2dict([1, 2]), NodeInfo{Array{Int64, 1}}((2,), [1, 2]))

    @test isequal(struct2dict("abc"), NodeInfo("abc"))
    @test isequal(struct2dict(["abc", "def"]),
        NodeInfo{Array{String,1}}((2,), ["abc", "def"]))

    @test isequal(struct2dict(STD1([1, 2])),
        Dict{Symbol, Any}([:x => NodeInfo{Array{Int64,1}}((2,), [1, 2])]))

    s1 = STD2(1.2, STD1([1,2]));
    d1 = struct2dict(s1);
    @test isequal(d1[:x], NodeInfo(1.2))
    @test isequal(d1[:y], struct2dict(STD1([1,2])))

    s11 = STD2(0.0, STD1([1]));
    dict2struct!(s11, d1);
    @test isequal(s11.x, s1.x)
    @test isequal(s11, s1)
    d11 = struct2dict(s11);
    @test isequal(d1, d11)
end


@testset "StructLH" begin
    retrieve_test()
    reduce_ov_test()
    struct2dict_test()
    include("structlh_merge_test.jl");
    include("apply_fct_test.jl");
    include("reduce_test.jl");
    include("structlh_helpers_test.jl");
end
