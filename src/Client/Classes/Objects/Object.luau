--------------------------------------------------------
-- [Ragdollworks] Object
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
    A class representing a spawnable object.
]]
Object = {} :: ObjectTypes.Object
Object.__index = Object

--[[
    Creates a new Object class instance.
]]
function Object.New(
    name: string,
    description: string,
    category: string,
    settings: ObjectTypes.ObjectSettings,
    behaviours: {ObjectTypes.ObjectBehaviour},
    instance: Model,
    iconAssetID: string?,
    isDefault: boolean?
): ObjectTypes.Object
    local self = setmetatable({}, Object) :: Object
    self.Name = name
    self.Description = description
    self.Category = category
    self.Settings = settings
    self.Behaviours = behaviours
    self.Instance = instance
    self.IconAssetID = iconAssetID
    self.IsDefault = isDefault or false

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
        instance:GetAttribute("ObjectIconAssetID"),
        instance:GetAttribute("ObjectIsDefault")
    )
end

--[[
    Returns the icon asset ID.
]]
function Object:GetIcon(): string
    return self.IconAssetID or RbxAssets.UNKNOWN_ICON
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