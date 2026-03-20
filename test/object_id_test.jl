using CommonLH, Test

mo = CommonLH;

struct TestObj4 <: ModelObject
    objId :: ObjectId
end


function object_id_test()
    @testset "ObjectId" begin
        # Simplest case
        id1 = SingleId(:id1);
        o1 = ObjectId(id1);
        @test !mo.has_parent(o1)

        # Roundtrip between objectId and String
        s1 = make_string(id1);
        @test isequal(s1, "id1")
        o1a = make_object_id(s1)
        @test isequal(o1, o1a);
        @test o1 == o1a;

        # Index, no parents
        o2 = ObjectId(:id2, 2)
        println(o2);
        @test mo.own_index(o2) == [2]
        @test mo.own_name(o2) == :id2

        # Has id1 as parent
        o3 = ObjectId(:id3, 2, o1);
        println(o3)
        p3 = mo.get_parent_id(o3);
        @test mo.is_parent_of(p3, o3)
        s3 = mo.make_string(o3);
        @test isequal(s3, "id1 > id3[2]")
        o3a = make_object_id(s3)
        @test isequal(o3, o3a);
        @test o3 == o3a;

        # Make child id
        o4 = ObjectId(:id4, p3);
        obj4 = TestObj4(o4);
        childId = mo.make_child_id(obj4, :child);
        @test isequal(mo.own_id(childId),  SingleId(:child))
        @test isequal(o4, mo.get_parent_id(childId))
        @test isequal(mo.own_name(obj4), :id4)

        # Check `isequal` when "depth" of `ObjectId`s is different
        @test !isequal(obj4.objId, childId)
    end
end

function dict_object_id_test()
    @testset "Dict ObjectId" begin
        objIdV = [
            ObjectId(:id1), 
            ObjectId(:id2, 1), 
            make_child_id(ObjectId(:id1), :id3)];
        d = Dict{ObjectId, Int}([oId => j  for (j, oId) in enumerate(objIdV)]);
        for (id1, val) in d
            @test id1 isa ObjectId;
            @test val isa Integer;
        end
        for objId in objIdV
            @test haskey(d, objId);
        end
    end
end


function oid_broadcast_test()
    @testset "Broadcasting" begin
        sV = [ObjectId(:x), ObjectId(:y)];
        eqV = ObjectId(:x) .== sV;
        @test eqV[1]
        @test !eqV[2]
    end
end



@testset "ObjectId" begin
    object_id_test();
    dict_object_id_test();
    oid_broadcast_test();
end

# --------------