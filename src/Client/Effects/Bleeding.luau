--------------------------------------------------------
-- [Ragdollworks] Bleeding
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