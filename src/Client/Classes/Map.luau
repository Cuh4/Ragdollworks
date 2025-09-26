--------------------------------------------------------
-- [Ragdollworks] Map
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