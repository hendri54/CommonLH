# Set up model for testing
using CommonLH

mutable struct Obj1 <: ModelObject
    objId :: ObjectId
    x :: Float64
    y :: Vector{Float64}
    z :: Array{Float64,2}
end

function init_obj1(objId)
    # objId = ObjectId(:obj1);
    valueX = 7.3;
    # Important to have vector of length 1 as test case
    valueY = fill(1.1, 1);
    valueZ = [3.3 4.4; 5.5 7.6];
    o1 = Obj1(objId, valueX, valueY, valueZ);
    return o1
end


mutable struct Obj3 <: ModelObject
    objId :: ObjectId
    x :: Float64
    y :: Vector{Int}
end

function init_obj3(objId :: ObjectId)
    return Obj3(make_child_id(objId, :obj3), 0.5, [1,2]);
end


mutable struct Obj2 <: ModelObject
    objId :: ObjectId
    a :: Float64
    y :: Float64
    b :: Array{Float64,2}
    obj3 :: Obj3
end

# function Obj2(a, y, b)
#     return Obj2(a, y, b, ParamVector(ObjectId(:pv1)))
# end

function init_obj2(objId)
    # objId = ObjectId(:obj2);
    valueX = 17.3;
    valueY = 9.4;
    valueB = 2.0 .+ [3.3 4.4; 5.5 7.6];
    o2 = Obj2(objId, valueX, valueY, valueB, init_obj3(objId));
    return o2
end

mutable struct TestModel <: ModelObject
    objId :: ObjectId
    o1 :: Obj1
    o2 :: Obj2
    a :: Float64
    y :: Float64
end

function init_test_model()
    objName = ObjectId(:testModel, "Test model");
    o1 = init_obj1(make_child_id(objName, :o1, "Child object 1"));
    o2 = init_obj2(make_child_id(objName, :o2, "Child object 2"));
    return TestModel(objName, o1, o2, 9.87, 87.73)
end

# ------------------