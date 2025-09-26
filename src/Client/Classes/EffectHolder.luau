--------------------------------------------------------
-- [Ragdollworks] Effect Holder
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