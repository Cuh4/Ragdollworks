--------------------------------------------------------
-- [Ragdollworks] Spawned Wire
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

local WireTarget = require(script.Parent.WireTarget)
local Entity = require(script.Parent.Entity)
local ObjectPart = require(script.Parent.ObjectPart)
local ObjectTypes = require(script.Parent.Types)

local WireTargetType = require(Rage.Path.Enums.WireTargetType)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a wire responsible for connecting two object parts together.
]]
SpawnedWire = {} :: ObjectTypes.SpawnedWire
SpawnedWire.__index = SpawnedWire
setmetatable(SpawnedWire, Entity)

--[[
    Creates a new wire class instance.
]]
function SpawnedWire.New(): ObjectTypes.SpawnedWire
    local self = setmetatable(Entity.New("SpawnedWire"), SpawnedWire) :: ObjectTypes.SpawnedWire
    self.TargetA = nil
    self.TargetB = nil

    return self
end

--[[
    Setups the wire.<br>
    Vector2 + Vector2 is not allowed.
]]
function SpawnedWire:Setup(
    targetA: ObjectTypes.WireTarget,
    mousePosA: Vector2,
    targetB: ObjectTypes.WireTarget,
    mousePosB: Vector2
)
    if typeof(targetA) == "Vector2" and typeof(targetB) == "Vector2" then
        Rage.Logging:Error("SpawnedWire:Setup(): Cannot connect a wire between two Vector2s. Part + Vector2 only, or Part + Part.")
    end

    self.TargetA = WireTarget.New(targetA)
    self.TargetA:CreateAttachment(mousePosA)

    self.TargetB = WireTarget.New(targetB)
    self.TargetB:CreateAttachment(mousePosB)

    self.StorageInstance = self.TargetA.Type == WireTargetType.OBJECT_PART and self.TargetA.Target.Part or self.TargetB.Target.Part

    self:OnConnect()
end

--[[
    Despawns the wire.
]]
function SpawnedWire:Despawn()
    self.TargetA:Cleanup()
    self.TargetB:Cleanup()

    self:OnCleanup()
end

--[[
    Despawns the wire and removes it from the game itself.
]]
function SpawnedWire:Remove()
    require(Rage.Path.Objects):RemoveWire(self)
end

--[[
    Returns if this wire is connected to the provided part.
]]
function SpawnedWire:IsConnectedToPart(part: ObjectTypes.ObjectPart): boolean
    return self.TargetA:BelongsTo(part) or self.TargetB:BelongsTo(part)
end

--[[
    Updates this wire.
]]
function SpawnedWire:Update()
    self:OnUpdate()
end

--[[
    Called when the wire needs to be updated.
]]
function SpawnedWire:OnUpdate()
    Rage.Logging:Error(self.Name..": :OnUpdate() not implemented!")
end

--[[
    Called when two object parts need to be connected together with this wire.
]]
function SpawnedWire:OnConnect()
    Rage.Logging:Error(self.Name..": :OnConnect() not implemented!")
end

--[[
    Called when the wire needs to be cleaned up.
]]
function SpawnedWire:OnCleanup()
    Rage.Logging:Error(self.Name..": :OnCleanup() not implemented!")
end

return SpawnedWire