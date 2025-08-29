--------------------------------------------------------
-- [Ragdollworks] Light
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local ObjectBehaviour = require(Rage.ReplicatedStorage.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.ReplicatedStorage.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    An object behaviour for managing toggleable lights on objects.
]]
LightObjectBehaviour = {} :: LightObjectBehaviour
LightObjectBehaviour.__index = LightObjectBehaviour
setmetatable(LightObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new LightObjectBehaviour class instance.
]]
function LightObjectBehaviour.New(spawnedObject: ObjectTypes.SpawnedObject): LightObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(spawnedObject), LightObjectBehaviour) :: LightObjectBehaviour
    self.LIGHT_MATERIAL_ON = Enum.Material.Neon
    self.LIGHT_MATERIAL_OFF = Enum.Material.SmoothPlastic

    self.LightParts = {}

    return self
end

--[[
    Finds and registers all light parts.
]]
function LightObjectBehaviour:FindLightParts()
    for _, part in pairs(self.SpawnedObject.Parts) do
        if part.Part:GetAttribute("LightSource") then
            local light = self:GetLightFromPart(part)

            if not light then
                Rage.Logging:Error(("LightObjectBehaviour:FindLightParts(): No light found on '%s' of object '%s'."):format(part.Part:GetFullName(), self.SpawnedObject.Object.Name))
            end

            part.Part.Material = self.LIGHT_MATERIAL_OFF
            light.Enabled = false
            light.Color = part.Part.Color

            self.LightParts[part] = part

            part.OnDespawn:Once(function()
                self:RemoveLightPart(part)
            end)

            Rage.Logging:Info("LightObjectBehaviour:FindLightParts(): Found light part: "..part.Part:GetFullName())
        end
    end
end

--[[
    Removes a light part.
]]
function LightObjectBehaviour:RemoveLightPart(part: ObjectTypes.ObjectPart)
    self.LightParts[part] = nil
end

--[[
    Returns a light from a light part.
]]
function LightObjectBehaviour:GetLightFromPart(part: ObjectTypes.ObjectPart): Light
    return part.Part:FindFirstChild("Light") :: Light
end

--[[
    Called when an object using this behaviour is spawned.
]]
function LightObjectBehaviour:OnSpawn()
    self:FindLightParts()
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function LightObjectBehaviour:OnPreDespawn()
    self.LightParts = {}
end

--[[
    Called when an object using this behaviour is activated.
]]
function LightObjectBehaviour:OnActivate(_: ObjectTypes.ObjectPart)
    for _, part in pairs(self.LightParts) do
        local light = self:GetLightFromPart(part)
        light.Enabled = not light.Enabled
        part.Part.Material = light.Enabled and self.LIGHT_MATERIAL_ON or self.LIGHT_MATERIAL_OFF
    end
end

--[[
    Called when an object using this behaviour is updated.
]]
function LightObjectBehaviour:OnUpdate() end

export type LightObjectBehaviour = {
    LIGHT_MATERIAL_ON: Enum.Material,
    LIGHT_MATERIAL_OFF: Enum.Material,

    LightParts: {[ObjectTypes.ObjectPart]: ObjectTypes.ObjectPart}
} & typeof(LightObjectBehaviour) & ObjectTypes.ObjectBehaviour

return LightObjectBehaviour