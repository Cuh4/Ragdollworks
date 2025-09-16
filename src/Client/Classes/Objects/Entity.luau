--------------------------------------------------------
-- [Ragdollworks] Entity
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

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