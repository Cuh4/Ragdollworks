--------------------------------------------------------
-- [Ragdollworks] Human
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

local ObjectBehaviour = require(Rage.Path.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

local Human = require(Rage.Path.Classes.Human)

-------------------------------
-- // Main
-------------------------------

--[[
    An object behaviour for providing human-like behaviour (health, gore, balancing, etc).
]]
HumanObjectBehaviour = {} :: HumanObjectBehaviour
HumanObjectBehaviour.__index = HumanObjectBehaviour
setmetatable(HumanObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new HumanObjectBehaviour class instance.
]]
function HumanObjectBehaviour.New(...): HumanObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(...), HumanObjectBehaviour) :: HumanObjectBehaviour
    self.Humans = {} :: {[ObjectTypes.SpawnedObject]: Human.Human}

    return self
end

--[[
    Creates a human.
]]
function HumanObjectBehaviour:CreateHuman(spawnedObject: ObjectTypes.SpawnedObject)
    self.Humans[spawnedObject] = Human.New(spawnedObject)
end

--[[
    Removes a human.
]]
function HumanObjectBehaviour:RemoveHuman(human: Human.Human)
    human:Cleanup()
    self.Humans[human.SpawnedObject] = nil
end

--[[
    Returns a human from a spawned object.
]]
function HumanObjectBehaviour:GetHuman(spawnedObject: ObjectTypes.SpawnedObject): Human.Human
    return self.Humans[spawnedObject]
end

--[[
    Called when an object using this behaviour is spawned.
]]
function HumanObjectBehaviour:OnSpawn(spawnedObject: ObjectTypes.SpawnedObject)
    self:CreateHuman(spawnedObject)
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function HumanObjectBehaviour:OnPreDespawn(spawnedObject: ObjectTypes.SpawnedObject)
    local human = self:GetHuman(spawnedObject) :: Human.Human

    if not human then
        return
    end

    self:RemoveHuman(human)
end

--[[
    Called when an object using this behaviour is activated.
]]
function HumanObjectBehaviour:OnActivate(spawnedObject: ObjectTypes.SpawnedObject, objectPart: ObjectTypes.ObjectPart) end

--[[
    Called when an object using this behaviour is updated.
]]
function HumanObjectBehaviour:OnUpdate(spawnedObject: ObjectTypes.SpawnedObject)
    local human = self:GetHuman(spawnedObject) :: Human.Human

    if not human then
        return
    end

    human:Update()
end

export type HumanObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(HumanObjectBehaviour) & {
    Humans: {[ObjectTypes.SpawnedObject]: Human.Human}
}

return HumanObjectBehaviour