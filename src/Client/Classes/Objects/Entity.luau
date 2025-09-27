--------------------------------------------------------
-- [Ragdollworks] Entity
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