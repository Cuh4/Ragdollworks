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
local types = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a behaviour, similar to components in ECS frameworks, but purely for spawned objects.
]]
ObjectBehaviour = {} :: types.ObjectBehaviour
ObjectBehaviour.__index = ObjectBehaviour

--[[
    Creates a new ObjectBehaviour class instance.
]]
function ObjectBehaviour.New(spawnedObject: types.SpawnedObject): types.ObjectBehaviour
    local self = setmetatable({}, ObjectBehaviour)
    self.SpawnedObject = spawnedObject

    return self
end

--[[
    Called when an object using this behaviour is spawned.
]]
function ObjectBehaviour:OnSpawn(object: types.SpawnedObject)
    Rage.Logging:Error(self.Name..": OnSpawn not implemented!")
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function ObjectBehaviour:OnPreDespawn(object: types.SpawnedObject)
    Rage.Logging:Error(self.Name..": OnPreDespawn not implemented!")
end

--[[
    Called when an object using this behaviour is activated.
]]
function ObjectBehaviour:OnActivate(object: types.SpawnedObject, objectPart: types.ObjectPart)
    Rage.Logging:Error(self.Name..": OnActivate not implemented!")
end

--[[
    Called when an object using this behaviour is updated.
]]
function ObjectBehaviour:OnUpdate(object: types.SpawnedObject)
    Rage.Logging:Error(self.Name..": OnUpdate not implemented!")
end

return ObjectBehaviour