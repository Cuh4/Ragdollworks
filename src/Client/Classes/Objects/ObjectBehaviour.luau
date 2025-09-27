--------------------------------------------------------
-- [Ragdollworks] Object Behaviour
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
    A class representing a behaviour, similar to components in ECS frameworks, but purely for spawned objects.
]]
ObjectBehaviour = {} :: ObjectTypes.ObjectBehaviour
ObjectBehaviour.__index = ObjectBehaviour

--[[
    Creates a new ObjectBehaviour class instance.
]]
function ObjectBehaviour.New(name: string): ObjectTypes.ObjectBehaviour
    local self = setmetatable({}, ObjectBehaviour)
    self.Name = name

    return self
end

--[[
    Called when an object using this behaviour is spawned.
]]
function ObjectBehaviour:OnSpawn(spawnedObject: ObjectTypes.SpawnedObject)
    Rage.Logging:Error(self.Name..": OnSpawn not implemented!")
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function ObjectBehaviour:OnPreDespawn(spawnedObject: ObjectTypes.SpawnedObject)
    Rage.Logging:Error(self.Name..": OnPreDespawn not implemented!")
end

--[[
    Called when an object using this behaviour is activated.
]]
function ObjectBehaviour:OnActivate(spawnedObject: ObjectTypes.SpawnedObject, objectPart: ObjectTypes.ObjectPart)
    Rage.Logging:Error(self.Name..": OnActivate not implemented!")
end

--[[
    Called when an object using this behaviour is updated.
]]
function ObjectBehaviour:OnUpdate(spawnedObject: ObjectTypes.SpawnedObject)
    Rage.Logging:Error(self.Name..": OnUpdate not implemented!")
end

return ObjectBehaviour