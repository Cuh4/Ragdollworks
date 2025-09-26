--------------------------------------------------------
-- [Ragdollworks] Effect
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

local Trove = require(Rage.WallyPackages.trove)

local Organization = require(Rage.Path.Organization)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a spawned effect.
]]
Effect = {} :: Effect
Effect.__index = Effect
Effect._EffectPartsFolder = Organization:CreateFolder("EffectParts", Rage.Workspace)

--[[
    Creates a new Effect class instance.
]]
function Effect.New(target: EffectTarget, settings: EffectSettings): Effect
    local self = setmetatable({}, Effect) :: Effect
    self.Target = target

    self.Settings = {
        Lifetime = settings.Lifetime or 1,
        IsPermanent = settings.IsPermanent or false,
        Size = settings.Size or 1
    }

    self.Trove = Trove.new()
    self.CreatedAt = os.clock()

    return self
end

--[[
    Creates an invisible part to attach ParticleEmitters to if the target is a position.
]]
function Effect:CreateWorldPart(size: Vector3): BasePart
    if not Rage.Libs.Position:IsPosition(self.Target) then
        Rage.Logging:Error("Effect:CreateWorldPart(): Can't use `:CreateWorldPart()` when effect target is not a position.")
    end

    local part = Instance.new("Part")
    part.Name = "EffectWorldPart"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Position = Vector3.new(self.Target.X, self.Target.Y, 0)
    part.Size = size
    part.Transparency = 1
    part.Parent = self._EffectPartsFolder

    self.Trove:Add(part)

    return part
end

--[[
    Returns if the effect has expired.
]]
function Effect:HasExpired(): boolean
    if self.Settings.IsPermanent then
        return false
    end

    if os.clock() - self.CreatedAt < self.Settings.Lifetime then
        return false
    end

    return true
end

--[[
    Updates the effect. To be called every heartbeat.
]]
function Effect:Update()
    self:OnUpdate()
end

--[[
    Called when the effect is updated.<br>
    Optional abstractmethod.
]]
function Effect:OnUpdate() end

--[[
    Cleans up the effect.
]]
function Effect:Cleanup()
    self.Trove:Destroy()
    self:OnCleanup()
end

--[[
    Called when the effect is cleaned up.<br>
    Optional abstractmethod.
]]
function Effect:OnCleanup() end

export type EffectTarget = Rage.PositionType

export type EffectSettings = {
    Lifetime: number,
    IsPermanent: boolean,
    Size: number
}

export type Effect = typeof(Effect) & {
    _EffectPartsFolder: Folder,

    Target: EffectTarget,
    Settings: EffectSettings,
    Trove: Trove.Trove,
    CreatedAt: number
}

return Effect