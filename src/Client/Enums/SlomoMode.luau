--------------------------------------------------------
-- [Ragdollworks] Slomo Mode
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

local BaseEnum = require(Rage.Path.Enums.BaseEnum)

-------------------------------
-- // Main
-------------------------------

--[[
    An enum representing a slomo mode for objects.
]]
local SlomoMode = BaseEnum("SlomoMode")
SlomoMode.FREEZING = "FREEZING"
SlomoMode.INTERPOLATION = "INTERPOLATION"
SlomoMode.FREEZING_INTERPOLATION = "FREEZING_INTERPOLATION"

export type SlomoMode = string
return SlomoMode