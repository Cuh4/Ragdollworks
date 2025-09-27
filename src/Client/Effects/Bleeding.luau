--------------------------------------------------------
-- [Ragdollworks] Bleeding
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

local Effect = require(Rage.Path.Classes.Effect)
local EffectHolder = require(Rage.Path.Classes.EffectHolder)

-------------------------------
-- // Main
-------------------------------

--[[
    A bleeding effect.
]]
BleedingEffect = {} :: BleedingEffect
BleedingEffect.__index = BleedingEffect
setmetatable(BleedingEffect, Effect)

--[[
    Creates a new BleedingEffect class instance.
]]
function BleedingEffect.New(target: Effect.EffectTarget, settings: Effect.EffectSettings): BleedingEffect
    local self = setmetatable(Effect.New(target, settings), BleedingEffect)
    self.BleedingParticleEmitter = Rage.Assets:GetAsset("Effects")["Bleeding"]:Clone()
    self.MaxBleedingRate = self.BleedingParticleEmitter.Rate
    self.BleedingRate = 0

    self.Trove:Add(self.BleedingParticleEmitter)

    return self
end

--[[
    Sets the bleeding rate.
]]
function BleedingEffect:SetBleedingRate(rate: number)
    self.BleedingRate = rate
end

--[[
    Called when the effect is updated.
]]
function BleedingEffect:OnUpdate()
    self.BleedingParticleEmitter.Enabled = self.BleedingRate > 0
    self.BleedingParticleEmitter.Rate = self.MaxBleedingRate * self.BleedingRate
end

--[[
    Cleans up the effect.
]]
function BleedingEffect:OnCleanup() end

export type BleedingEffect = Effect.Effect & typeof(BleedingEffect) & {
    BleedingParticleEmitter: ParticleEmitter,
    MaxBleedingRate: number,
    BleedingRate: number -- 0 - 1
}

export type BleedingEffectHolder = EffectHolder.EffectHolder & {
    Name: string,
    EffectClass: BleedingEffect
}

return EffectHolder.New("Bleeding", BleedingEffect) :: BleedingEffectHolder