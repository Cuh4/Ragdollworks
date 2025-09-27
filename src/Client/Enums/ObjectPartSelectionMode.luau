--------------------------------------------------------
-- [Ragdollworks] Object Part Selection Mode
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Source-Available No-Redistribution License
        Copyright (c) 2025 Cuh4. All rights reserved.

        IMPORTANT: This source code is NOT Open Source.

        1. PERMISSIONS (Limited):
        * View and read the source code.
        * Modify for private, non-public use only.
        * Contributions back to the project are permitted.

        2. PROHIBITIONS (Strict):
        * You MAY NOT copy, redistribute, publish, or share the code (modified or unmodified).
        * You MAY NOT use this code in ANY public or commercial project or service.

        Any violation automatically terminates your rights.
        Provided "AS IS" without warranty.
        Full terms governed by the laws of England and Wales.

        For the full license, see the `LICENSE` file provided with the source code.

    CREDIT:
        Author(s): @Cuh4 (GitHub)

    ----------------------------
]]

-------------------------------
-- // Variable
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local BaseEnum = require(Rage.Path.Enums.BaseEnum)

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