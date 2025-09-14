--------------------------------------------------------
-- [Ragdollworks] Wire Target Type
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    An enum representing the type of a wire target.
]]
local WireTargetType = {
    OBJECT_PART = "OBJECT_PART",
    WORLD = "WORLD"
}

export type WireTargetType = typeof(WireTargetType)
return WireTargetType