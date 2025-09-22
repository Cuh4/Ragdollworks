--------------------------------------------------------
-- [Ragdollworks] Wire
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