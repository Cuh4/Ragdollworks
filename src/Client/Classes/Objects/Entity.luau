--------------------------------------------------------
-- [Ragdollworks] Entity
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

local ObjectTypes = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A base entity class. Used by objects, wires, etc.
]]
Entity = {} :: ObjectTypes.Entity
Entity.__index = Entity

--[[
    Creates a new Entity class instance.
]]
function Entity.New(name: string): ObjectTypes.Entity
    local self = setmetatable({}, Entity) :: ObjectTypes.Entity
    self.Name = name

    return self
end

--[[
    Returns the name of this entity.
]]
function Entity:GetName(): string
    return self.Name
end

--[[
    To be overridden. Handles despawning this entity.
]]
function Entity:Despawn()
    Rage.Logging:Error("Entity: Missing `:Despawn()` override method.")
end

--[[
    To be overridden. Handles removing this entity from the game and despawning.
]]
function Entity:Remove()
    Rage.Logging:Error("Entity: Missing `:Remove()` override method.")
end

return Entity