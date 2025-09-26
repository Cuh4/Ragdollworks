--------------------------------------------------------
-- [Ragdollworks] Effects
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

local CLI = require(Rage.Path.CLI)
local Camera = require(Rage.Path.Camera)

local Effect = require(Rage.Path.Classes.Effect)
local EffectHolder = require(Rage.Path.Classes.EffectHolder)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling effects in the game.
]]
Effects = Rage:Service("Effects") :: Effects
Effects.EffectHolders = {} :: {[string]: EffectHolder.EffectHolder}
Effects.Effects = {} :: {Effect.Effect}

--[[
    Called when this service starts.
]]
function Effects:OnStart()
    self:LoadEffectHolders()
    self:_CreateCommands()
end

--[[
    Called every heartbeat.
]]
function Effects:OnHeartbeat()
    self:UpdateEffects()
end

--[[
    Updates all effects.
]]
function Effects:UpdateEffects()
    for _, effect in pairs(self:GetEffects()) do
        if effect:HasExpired() then
            self:RemoveEffect(effect)
            continue
        end

        effect:Update()
    end
end

--[[
    Registers an effect holder.
]]
function Effects:RegisterEffectHolder(effectHolder: EffectHolder.EffectHolder)
    self.EffectHolders[effectHolder.Name] = effectHolder
    Rage.Logging:Info("Effects:RegisterEffectHolder(): Registered effect holder: "..effectHolder.Name)
end

--[[
    Loads all effect holders.
]]
function Effects:LoadEffectHolders()
    for name, effectHolder: EffectHolder.EffectHolder in pairs(Rage:LoadAll(self)) do
        if not Rage.Libs.Classes:IsClassInstance(effectHolder, EffectHolder) then
            Rage.Logging:Error(("Effects:LoadEffectHolders(): %s is not an instance of EffectHolder"):format(name))
        end

        self:RegisterEffectHolder(effectHolder)
    end
end

--[[
    Registers an effect.
]]
function Effects:RegisterEffect(effect: Effect.Effect)
    table.insert(self.Effects, effect)
    Rage.Logging:Info("Effects:RegisterEffect(): Registered effect: "..effect.Name)
end

--[[
    Unregisters an effect.
]]
function Effects:UnregisterEffect(effect: Effect.Effect)
    Rage.Libs.Table:Remove(self.Effects, effect)
end

--[[
    Spawns an effect by name.
]]
function Effects:SpawnEffect(name: string, target: Effect.EffectTarget, settings: Effect.EffectSettings): Effect.Effect
    local effectHolder = self:GetEffectHolder(name)

    if not effectHolder then
        Rage.Logging:Error("Effects:SpawnEffect(): Effect not found, name: "..name)
    end

    local effect = effectHolder:Create(target, settings)
    self:RegisterEffect(effect)

    return effect
end

--[[
    Removes an effect.
]]
function Effects:RemoveEffect(effect: Effect.Effect)
    effect:Cleanup()
    self:UnregisterEffect(effect)

    Rage.Logging:Info("Effects:RemoveEffect(): Removed effect.")
end

--[[
    Returns all active effects.
]]
function Effects:GetEffects(): {Effect.Effect}
    return self.Effects
end

--[[
    Returns an effect holder by name.
]]
function Effects:GetEffectHolder(name: string): EffectHolder.EffectHolder?
    return self.EffectHolders[name]
end

--[[
    Creates CLI commands.
]]
function Effects:_CreateCommands()
    CLI.Conch.register("effect", {
        description = "Spawns an effect.",

        arguments = function()
            return CLI.Conch.args.string("Name", "The name of the effect."),
                CLI.Conch.args.number("Lifetime", "The lifetime in secs, 0 for infinte"),
                CLI.Conch.args.number("Size", "The size of the effect.")
        end,

        callback = function(name: string, lifetime: number, size: number)
            self:SpawnEffect(name, Camera.MouseWorldPosition, {
                Lifetime = lifetime,
                IsPermanent = lifetime == 0,
                Size = size
            })
        end
    })
end

export type Effects = Rage.Service & typeof(Effects)
return Effects