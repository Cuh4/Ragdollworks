--------------------------------------------------------
-- [Ragdollworks] Light
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