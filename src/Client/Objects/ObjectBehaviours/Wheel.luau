--------------------------------------------------------
-- [Ragdollworks] Wheel
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

local Wheel = require(Rage.Path.Classes.Wheel)

-------------------------------
-- // Main
-------------------------------

--[[
    An object behaviour for handling wheel objects.
]]
WheelObjectBehaviour = {} :: WheelObjectBehaviour
WheelObjectBehaviour.__index = WheelObjectBehaviour
setmetatable(WheelObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new WheelObjectBehaviour class instance.
]]
function WheelObjectBehaviour.New(...): WheelObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(...), WheelObjectBehaviour) :: WheelObjectBehaviour
    self.Wheels = {} :: {[ObjectTypes.SpawnedObject]: Wheel.Wheel}

    return self
end

--[[
    Creates a wheel for a spawned object.
]]
function WheelObjectBehaviour:CreateWheel(spawnedObject: ObjectTypes.SpawnedObject): Wheel.Wheel
    local wheel = Wheel.New(spawnedObject)
    self.Wheels[spawnedObject] = wheel
end

--[[
    Returns a wheel from a spawned object.
]]
function WheelObjectBehaviour:GetWheel(spawnedObject: ObjectTypes.SpawnedObject): Wheel.Wheel?
    return self.Wheels[spawnedObject]
end

--[[
    Removes a wheel.
]]
function WheelObjectBehaviour:RemoveWheel(wheel: Wheel.Wheel)
    self.Wheels[wheel.SpawnedObject] = nil
end

--[[
    Called when an object using this behaviour is spawned.
]]
function WheelObjectBehaviour:OnSpawn(spawnedObject: ObjectTypes.SpawnedObject)
    self:CreateWheel(spawnedObject)
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function WheelObjectBehaviour:OnPreDespawn(spawnedObject: ObjectTypes.SpawnedObject)
    local wheel = self:GetWheel(spawnedObject)

    if not wheel then
        return
    end

    self:RemoveWheel(wheel)
end

--[[
    Called when an object using this behaviour is activated.
]]
function WheelObjectBehaviour:OnActivate(spawnedObject: ObjectTypes.SpawnedObject, _: ObjectTypes.ObjectPart)
    local wheel = self:GetWheel(spawnedObject)

    if not wheel then
        return
    end

    wheel:Toggle()
end

--[[
    Called when an object using this behaviour is updated.
]]
function WheelObjectBehaviour:OnUpdate(spawnedObject: ObjectTypes.SpawnedObject)
    local wheel = self:GetWheel(spawnedObject)

    if not wheel then
        return
    end

    wheel:Update()
end

export type WheelObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(WheelObjectBehaviour) & {
    Wheels: {[ObjectTypes.SpawnedObject]: Wheel.Wheel}
}

return WheelObjectBehaviour