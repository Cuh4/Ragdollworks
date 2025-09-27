--------------------------------------------------------
-- [Ragdollworks] Map
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

local RbxAssets = require(Rage.Path.RbxAssets)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a map.
]]
Map = {} :: Map
Map.__index = Map

--[[
    Creates a new Map class instance.
]]
function Map.New(name: string, description: string, size: Vector2, iconAssetID: string?, mapInstance: Model): Map
    local self = setmetatable({}, Map) :: Map
    self.Name = name
    self.Description = description
    self.Size = size
    self.IconAssetID = iconAssetID
    self.Instance = mapInstance

    return self
end

--[[
    Creates a new Map class instance from an actual map instance.
]]
function Map.FromInstance(mapInstance: Model): Map
    return Map.New(
        mapInstance:GetAttribute("MapName") or Rage.Logging:Error(mapInstance:GetFullName()..": No map name provided."),
        mapInstance:GetAttribute("MapDescription") or Rage.Logging:Error(mapInstance:GetFullName()..": No map description provided."),
        mapInstance:GetAttribute("MapSize") or Rage.Logging:Error(mapInstance:GetFullName()..": No map size provided."),
        mapInstance:GetAttribute("MapIconAssetID"),
        mapInstance
    )
end

--[[
    Returns the icon for this map.
]]
function Map:GetIcon(): string
    return self.IconAssetID or RbxAssets.UNKNOWN_ICON
end

--[[
    Creates (via cloning) the map instance.
]]
function Map:CreateInstance(): Model
    return self.Instance:Clone()
end

export type Map = typeof(Map) & {
    Name: string,
    Description: string,
    Size: Vector2,
    IconAssetID: string?,
    Instance: Model
}

return Map