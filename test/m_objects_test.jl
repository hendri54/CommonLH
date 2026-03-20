using CommonLH, Test

function collect_test()
    @testset "Collect" begin
        m = init_test_model();
        v = collect_model_objects(m);
        idV = collect_object_ids(m);
        @test length(v) == 4
        @test length(idV) == length(v)
        for o in v
            @test is_model_object(o)
        end
	end
end


function find_test()
    @testset "Find" begin
        m = init_test_model()
        childId1 = make_child_id(m, :child)

        # Find objects by name
        @test isnothing(find_object(m, childId1))
        @test isempty(find_object(m, :child));

        childId2 = make_child_id(m, :o1);
        child2 = find_object(m, childId2);
        @test isa(child2, ModelObject);

        child2 = find_object(m, :o1);
        @test length(child2) == 1
        @test isequal(child2[1].objId, childId2)
        child3 = find_only_object(m, :o1);
        @test isequal(get_object_id(child3), childId2);

        # Find the object itself. 
        m2 = find_object(m, m.objId);
        @test m2 isa TestModel

        # Get value of a parameter
        b = get_value(m, :o2, :b);
        @test isequal(m.o2.b, b)
    end
end


function structure_test()
    @testset "ObjectStructure" begin
        m = init_test_model();
        idV, typeV = object_structure(m);
        @test length(idV) == length(typeV)
        @test eltype(idV) == ObjectId
        @test eltype(typeV) == DataType
        show_object_structure(m)
    end
end


@testset "ModelObjects" begin
    collect_test();
    find_test();
    structure_test();
end

# ------------