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
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local ObjectBehaviour = require(Rage.Path.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Light = require(Rage.Path.Classes.Light)

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
function LightObjectBehaviour.New(...): LightObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(...), LightObjectBehaviour) :: LightObjectBehaviour
    self.Lights = {} :: {[ObjectTypes.SpawnedObject]: Light.Light}

    return self
end

--[[
    Creates a light for a spawned object.
]]
function LightObjectBehaviour:CreateLight(spawnedObject: ObjectTypes.SpawnedObject): Light.Light
    local light = Light.New(spawnedObject)
    self.Lights[spawnedObject] = light

    return light
end

--[[
    Removes a light.
]]
function LightObjectBehaviour:RemoveLight(spawnedObject: ObjectTypes.SpawnedObject)
    self.Lights[spawnedObject] = nil
end

--[[
    Returns a light from a spawned object.
]]
function LightObjectBehaviour:GetLight(spawnedObject: ObjectTypes.SpawnedObject): Light.Light
    return self.Lights[spawnedObject]
end

--[[
    Called when an object using this behaviour is spawned.
]]
function LightObjectBehaviour:OnSpawn(spawnedObject: ObjectTypes.SpawnedObject)
    self:CreateLight(spawnedObject)
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function LightObjectBehaviour:OnPreDespawn(spawnedObject: ObjectTypes.SpawnedObject)
    self:RemoveLight(spawnedObject)
end

--[[
    Called when an object using this behaviour is activated.
]]
function LightObjectBehaviour:OnActivate(spawnedObject: ObjectTypes.SpawnedObject, _: ObjectTypes.ObjectPart)
    local light = self:GetLight(spawnedObject) :: Light.Light

    if not light then
        return
    end

    light:Toggle()
end

--[[
    Called when an object using this behaviour is updated.
]]
function LightObjectBehaviour:OnUpdate(spawnedObject: ObjectTypes.SpawnedObject) end

export type LightObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(LightObjectBehaviour) & {
    Lights: {[ObjectTypes.SpawnedObject]: Light.Light}
}

return LightObjectBehaviour