using Random, Test

function scale_array_test()
    @testset "Scale array" begin
        x = rand(4,3,2);
        for d = 1 : 3
            totalV = collect(range(1.0, 2.0, length = size(x, d)));
            scale_array!(x, d, totalV);
            for j = 1 : size(x, d)
                @test isapprox(sum(selectdim(x, d, j)),  totalV[j])
            end
        end
	end
end


@testset "Arrays" begin
    scale_array_test()
end

# -------------