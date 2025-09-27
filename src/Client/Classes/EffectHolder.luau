--------------------------------------------------------
-- [Ragdollworks] Effect Holder
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

local Effect = require(Rage.Path.Classes.Effect)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing an effect that can be spawned.
]]
EffectHolder = {} :: EffectHolder
EffectHolder.__index = EffectHolder

--[[
    Creates a new EffectHolder class instance.
]]
function EffectHolder.New(name: string, effectClass: Effect.Effect): EffectHolder
    local self = setmetatable({}, EffectHolder) :: EffectHolder
    self.Name = name
    self.EffectClass = effectClass

    return self
end

--[[
    Creates an effect from this holder.
]]
function EffectHolder:Create(target: Effect.EffectTarget, settings: Effect.EffectSettings): Effect.Effect
    return self.EffectClass.New(target, settings)
end

export type EffectHolder = typeof(EffectHolder) & {
    Name: string,
    EffectClass: Effect.Effect
}

return EffectHolder