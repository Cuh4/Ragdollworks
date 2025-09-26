--------------------------------------------------------
-- [Ragdollworks] Object Behaviour
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