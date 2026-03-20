using Random, Test

mutable struct S1
    x
end

Base.isapprox(x1 :: S1, x2 :: S1) = isapprox(S1.x, S2.x);

reduceFct(x :: Vector{T}) where T <: AbstractFloat = 
    T(sum(x) / length(x));
reduceFct(x :: Vector{T}) where T <: Integer =
    round(T, sum(x) / length(x));

function reduceFct(x :: Vector{S1})
    n = length(x);
    xSum = sum([x[j].x  for j = 1 : n]);
    return S1(xSum / n);
end

function reduce_scalars_test(T)
    rng = MersenneTwister(123);
    @testset "Reduce scalars" begin
        n = 9;
        if T == S1
            fieldV = [S1(x) for x in LinRange(1.0, 2.0, n)];
        else
            fieldV = rand(rng, T, n);
        end
        xr = reduce_scalar_vector(fieldV, reduceFct);
        @test xr isa T
        if T != S1
            @test isapprox(reduceFct(fieldV), xr);
        end
	end
end

function reduce_arrays_test(T)
    rng = MersenneTwister(123);
    @testset "Reduce arrays" begin
        n = 9;
        sz = (4,3,2);
        if T == S1
            fieldV = [fill(S1(rand(rng)), sz...)  for j = 1 : n];
        else
            fieldV = [rand(rng, T, sz)  for j = 1 : n];
        end
        xr = reduce_array_vector(fieldV, reduceFct);

        @test xr isa Array{T, 3};

        xr2 = similar(xr);
        for j in eachindex(fieldV[1])
            valueV = [fieldV[k][j]  for k = 1 : n];
            xr2[j] = reduceFct(valueV);
        end

        if T != S1
            @test all(isapprox.(xr2, xr));
        end
	end
end

@testset "Reduce" begin
    for T in (Float64, Float32, Int, S1)
        reduce_scalars_test(T);
        reduce_arrays_test(T);
    end
end

# -----------