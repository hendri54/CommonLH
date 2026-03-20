
# """
# 	$(SIGNATURES)

# Common fields in `ModelSwitches`.
# """
# mutable struct CommonModelSwitches
#     objId :: ObjectId
# end


get_object_id(s :: ModelSwitches) = s.objId :: ObjectId;

# set_object_id!(s :: ModelSwitches)

# -----------