--------------------------------------------------------
-- [Ragdollworks] Wire
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