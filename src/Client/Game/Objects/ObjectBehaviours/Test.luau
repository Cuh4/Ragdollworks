--------------------------------------------------------
-- [Ragdollworks] Test
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)
local ObjectBehaviour = require(Rage.ReplicatedStorage.Classes.Objects.ObjectBehaviour)
local types = require(Rage.ReplicatedStorage.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a behaviour, similar to components in ECS frameworks, but purely for spawned objects.
]]
TestObjectBehaviour = {} :: TestObjectBehaviour
TestObjectBehaviour.__index = TestObjectBehaviour
setmetatable(TestObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new ObjectBehaviour class instance.
]]
function TestObjectBehaviour.New(): TestObjectBehaviour
    local testObjectBehaviour = setmetatable(ObjectBehaviour.New("Test"), TestObjectBehaviour) :: TestObjectBehaviour
    testObjectBehaviour.Last = time()

    return testObjectBehaviour
end

--[[
    Called when an object using this behaviour is spawned.
]]
function TestObjectBehaviour:OnSpawn(object: types.SpawnedObject)
    Rage.Logging:Info("TestObjectBehaviour: object spawned!")
    print(object)
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function TestObjectBehaviour:OnPreDespawn(object: types.SpawnedObject)
    Rage.Logging:Info("TestObjectBehaviour: object about to be despawned!")
    print(object)
end

--[[
    Called when an object using this behaviour is activated.
]]
function TestObjectBehaviour:OnActivate(object: types.SpawnedObject, objectPart: types.ObjectPart)
    Rage.Logging:Info("TestObjectBehaviour: object activated for part:", objectPart.Part:GetFullName())
    print(object)
    print(objectPart)
end

--[[
    Called when an object using this behaviour is updated.
]]
function TestObjectBehaviour:OnUpdate(object: types.SpawnedObject)
    if time() - self.Last < 3 then
        return
    end

    self.Last = time()

    Rage.Logging:Info("TestObjectBehaviour: object updated!")
    print(object)
end

export type TestObjectBehaviour = {
    Last: number
} & types.ObjectBehaviour

return TestObjectBehaviour