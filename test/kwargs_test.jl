function return_kwargs(; kwargs...)
    return kwargs
end
    
    
function kwargs_test()
    @testset "kwargs" begin
        defaultVals = KwArgs(Dict([
            :a => "a",
            :b => 2,
            :c => [1, 2, 3]
        ]));

        @test has_default(:b, defaultVals)
        @test !has_default(:bb, defaultVals)
        @test default_value(:c, defaultVals) == [1,2,3]

        kwV = return_kwargs(; :a => "aa", :z => "zz");
        # In both
        @test kw_arg(:a, defaultVals; kwV...) == kwV[:a]
        # in defaults only
        @test kw_arg(:b, defaultVals; kwV...) == 2
        # in kwV only
        @test kw_arg(:z, defaultVals; kwV...) == kwV[:z]

        # Convenience function
        get_arg(name :: Symbol) = kw_arg(name, defaultVals; kwV...);
        @test get_arg(:a) == kwV[:a]
    end
end


@testset "KwArgs" begin
    kwargs_test()
end

# ---------