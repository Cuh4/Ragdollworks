--------------------------------------------------------
-- [Ragdollworks] Object Behaviour
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