--------------------------------------------------------
-- [Ragdollworks] Effect
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