--------------------------------------------------------
-- [Ragdollworks] Light
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

local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a light (tied to a spawned object).
]]
Light = {} :: Light
Light.__index = Light

--[[
    Creates a new Light class instance.
]]
function Light.New(spawnedObject: ObjectTypes.SpawnedObject): Light
    local self = setmetatable({}, Light) :: Light
    self.LIGHT_COLORS = {
        ["Red"] = Color3.fromRGB(255, 105, 107),
        ["Orange"] = Color3.fromRGB(255, 176, 96),
        ["White"] = Color3.fromRGB(255, 255, 255),
        ["Blue"] = Color3.fromRGB(144, 179, 255),
        ["Yellow"] = Color3.fromRGB(255, 236, 125),
        ["Green"] = Color3.fromRGB(132, 255, 126)
    }

    self.DEFAULT_LIGHT_COLOR = self.LIGHT_COLORS.White

    self.LIGHT_MATERIAL_ON = Enum.Material.Neon
    self.LIGHT_MATERIAL_OFF = Enum.Material.SmoothPlastic

    self.SpawnedObject = spawnedObject
    self.LightPart = self.SpawnedObject:GetPartByName("LightSource") or Rage.Logging:Error("Light.New(): Could not find `LightSource` part from "..spawnedObject.Object.Name)
    self.Light = self.LightPart.Part:FindFirstChild("Light") or Rage.Logging:Error("Light.New(): Could not find `Light` from "..self.LightPart.Part:GetFullName())

    self.On = false
    self.LightColor = self.DEFAULT_LIGHT_COLOR

    self:Setup()

    return self
end

--[[
    Setups the light. One-time use.
]]
function Light:Setup()
    for _, part in pairs(self.SpawnedObject.Parts) do
        self:CreateContextMenuItems(part)
    end

    self:Update()
end

--[[
    Sets the light color.
]]
function Light:SetColor(color: Color3)
    self.LightColor = color
    self:Update()
end

--[[
    Creates context menu items.
]]
function Light:CreateContextMenuItems(part: ObjectTypes.ObjectPart)
    for colorName, color in pairs(self.LIGHT_COLORS) do
        part.ContextMenu:AddContextMenuItem("Set "..colorName, function(_: ObjectTypes.ContextMenuItem)
            self:SetColor(color)
        end)
    end

    part.ContextMenu:AddContextMenuItem("Set Default", function(_: ObjectTypes.ContextMenuItem)
        self:SetColor(self.DEFAULT_LIGHT_COLOR)
    end)
end

--[[
    Sets if the light is on or not.
]]
function Light:SetOn(on: boolean)
    self.On = on
    self:Update()
end

--[[
    Toggles the light.
]]
function Light:Toggle()
    self:SetOn(not self.On)
end

--[[
    Updates the light part.
]]
function Light:Update()
    self.Light.Enabled = self.On
    self.Light.Color = self.LightColor
    self.LightPart.Part.Material = self.Enabled and self.LIGHT_MATERIAL_ON or self.LIGHT_MATERIAL_OFF
end

export type Light = typeof(Light) & {
    LIGHT_COLORS: {[string]: Color3},
    DEFAULT_LIGHT_COLOR: Color3,

    LIGHT_MATERIAL_ON: Enum.Material,
    LIGHT_MATERIAL_OFF: Enum.Material,

    SpawnedObject: ObjectTypes.SpawnedObject,

    LightPart: ObjectTypes.ObjectPart,
    Light: SurfaceLight,

    On: boolean,
    LightColor: Color3
}

return Light