--------------------------------------------------------
-- [Ragdollworks] Wire
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
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)
local ObjectTypes = require(script.Parent.Types)

local RbxAssets = require(Rage.Path.RbxAssets)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a spawable wire.
]]
Wire = {} :: ObjectTypes.Wire
Wire.__index = Wire

--[[
    Creates a new Wire class instance.
]]
function Wire.New(
    ID: number,
    name: string,
    description: string,
    wireClass: ObjectTypes.SpawnedWire,
    isDefault: boolean,
    iconAssetID: string
): ObjectTypes.Wire
    local self = setmetatable({}, Wire) :: Wire
    self.ID = ID
    self.Name = name
    self.Description = description
    self.WireClass = wireClass
    self.IsDefault = isDefault
    self.IconAssetID = iconAssetID

    return self
end

--[[
    Returns the icon asset ID.
]]
function Wire:GetIcon(): string
    return self.IconAssetID or RbxAssets.UNKNOWN_ICON
end

return Wire