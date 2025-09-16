--------------------------------------------------------
-- [Ragdollworks] Object Part Selection Mode
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
-- // Variable
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local BaseEnum = require(Rage.Path.Enums.BaseEnum) -- relative imports fuck with referencing the exported type below in other files for some fucking dumb reason
                                                                -- fuck you roblox lua lsp extension

-------------------------------
-- // Main
-------------------------------

--[[
    An enum representing the selection mode for object parts (smallest first, etc).
]]
local ObjectPartSelectionMode = BaseEnum("ObjectPartSelectionMode")
ObjectPartSelectionMode.SMALLEST = "SMALLEST"
ObjectPartSelectionMode.LARGEST = "LARGEST"
ObjectPartSelectionMode.CLOSEST_LAYER = "CLOSEST_LAYER"
ObjectPartSelectionMode.FARTHEST_LAYER = "FARTHEST_LAYER"

export type ObjectPartSelectionMode = string
return ObjectPartSelectionMode