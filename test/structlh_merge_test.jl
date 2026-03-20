using Random, Test, CommonLH

mutable struct MoaTest
    x
    y
    z
    a
end

function merge_object_arrays_test()
    @testset "Merge object arrays" begin
        rng = MersenneTwister(123);
        # First dimension must be the same for all arrays
        n = 17;
        x = rand(rng, n, 2);
        y = rand(rng, n, 3);
        z = rand(rng, n, 3, 2);
        a = rand(rng, n);
        oTg = MoaTest(x, y, z, a);

        idxV = [3,4,8];
        nSrc = length(idxV);
        x2 = rand(rng, nSrc, 2);
        y2 = 9.3;
        z2 = rand(rng, nSrc, 3, 2);
        a2 = rand(rng, nSrc);
        oSrc = MoaTest(x2, y2, z2, a2);

        merge_object_arrays!(oSrc, oTg, idxV, false, dbg = true);

        @test oTg.x[idxV,:] ≈ x2
        @test oTg.y ≈ y  # Skipped field; not of array type in source
        @test oTg.z[idxV,:,:] ≈ z2
        @test oTg.a[idxV] ≈ a2
    end
end

@testset "Merge" begin
    merge_object_arrays_test()
end

# -------------