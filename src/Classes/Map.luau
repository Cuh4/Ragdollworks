--------------------------------------------------------
-- [Ragdollworks] Map
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
function Map.New(name: string, description: string, size: Vector2, mapInstance: Model): Map
    local map = setmetatable({}, Map)
    map.Name = name
    map.Description = description
    map.Size = size
    map.Instance = mapInstance

    return map
end

--[[
    Creates a new Map class instance from an actual map instance.
]]
function Map.FromInstance(mapInstance: Model): Map
    return Map.New(
        mapInstance:GetAttribute("MapName") or Rage.Logging:Error(mapInstance:GetFullName()..": No map name provided."),
        mapInstance:GetAttribute("MapDescription") or Rage.Logging:Error(mapInstance:GetFullName()..": No map description provided."),
        mapInstance:GetAttribute("MapSize") or Rage.Logging:Error(mapInstance:GetFullName()..": No map size provided."),
        mapInstance
    )
end

--[[
    Creates (via cloning) the map instance.
]]
function Map:CreateInstance(): Model
    return self.Instance:Clone()
end

export type Map = {
    Name: string,
    Description: string,
    Size: Vector2,
    Instance: Model
} & typeof(Map)

return Map