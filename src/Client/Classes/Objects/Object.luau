--------------------------------------------------------
-- [Ragdollworks] Object
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

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a spawnable object.
]]
Object = {} :: ObjectTypes.Object
Object.__index = Object

--[[
    Creates a new Object class instance.
]]
function Object.New(name: string, description: string, category: string, settings: ObjectTypes.ObjectSettings, behaviours: {ObjectTypes.ObjectBehaviour}, instance: Model, iconAssetID: string?): ObjectTypes.Object
    local self = setmetatable({}, Object) :: Object
    self.Name = name
    self.Description = description
    self.Category = category
    self.Settings = settings
    self.Behaviours = behaviours
    self.Instance = instance
    self.IconAssetID = iconAssetID

    return self
end

--[[
    Creates a new Object class instance from an actual object instance.
]]
function Object.FromInstance(instance: Model, behaviours: {ObjectTypes.ObjectBehaviour}): ObjectTypes.Object
    return Object.New(
        instance:GetAttribute("ObjectName") or Rage.Logging:Error(instance:GetFullName()..": No object name provided."),
        instance:GetAttribute("ObjectDescription") or Rage.Logging:Error(instance:GetFullName()..": No object description provided."),
        instance:GetAttribute("ObjectCategory"):upper() or Rage.Logging:Error(instance:GetFullName()..": No object category provided."),

        {
            CanPartsCollide = instance:GetAttribute("ObjectCanPartsCollide") or false,
            IsSpawnable = instance:GetAttribute("ObjectIsSpawnable") or false
        },

        behaviours,
        instance,
        instance:GetAttribute("ObjectIconAssetID")
    )
end

--[[
    Returns whether or not the part can be spawned by the player.
]]
function Object:CanPlayerSpawn(): boolean
    return self.Settings.IsSpawnable
end

--[[
    Creates a copy of the object instance and returns it.
]]
function Object:Spawn(): Model
    return self.Instance:Clone()
end

return Object