--------------------------------------------------------
-- [Ragdollworks] Wire Target Type
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Copyright (C) 2025 Cuh4

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

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
    An enum representing the type of a wire target.
]]
local WireTargetType = BaseEnum("WireTargetType")
WireTargetType.OBJECT_PART = "OBJECT_PART"
WireTargetType.WORLD = "WORLD"

export type WireTargetType = string
return WireTargetType