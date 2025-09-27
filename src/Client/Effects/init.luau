--------------------------------------------------------
-- [Ragdollworks] Effects
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