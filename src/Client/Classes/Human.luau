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

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Limb = require(Rage.Path.Classes.Limb)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a human.
]]
Human = {} :: Human
Human.__index = Human

--[[
    Creates a new Human class instance.
]]
function Human.New(spawnedObject: ObjectTypes.SpawnedObject): Human
    local self = setmetatable({}, Human) :: Human
    self.SpawnedObject = spawnedObject
    self.Limbs = self:CreateLimbs()

    self:Setup()

    return self
end

--[[
    Finds and creates all limbs.
]]
function Human:CreateLimbs(): {[ObjectTypes.ObjectPart]: Limb.Limb}
    local limbs = {} :: {[ObjectTypes.ObjectPart]: Limb.Limb}

    for _, objectPart in pairs(self.SpawnedObject.Parts) do
        limbs[objectPart] = Limb.FromObjectPart(objectPart)
    end

    return limbs
end

--[[
    Removes the limb.
]]
function Human:RemoveLimb(limb: Limb.Limb)
    self.Limbs[limb.ObjectPart] = nil
end

--[[
    Setups the human. One-time use.
]]
function Human:Setup()
    for _, limb in pairs(self.Limbs) do
        limb:Setup(self.Limbs)
    end
end

--[[
    Updates this human.
]]
function Human:Update()
    for _, limb in pairs(self.Limbs) do
        limb:Update()
    end
end

--[[
    Cleans up the human.
]]
function Human:Cleanup()
    for _, limb in pairs(self.Limbs) do
        limb:Cleanup()
        self:RemoveLimb(limb)
    end
end

export type Human = typeof(Human) & {
    SpawnedObject: ObjectTypes.SpawnedObject,
    Limbs: {[ObjectTypes.ObjectPart]: Limb.Limb}
}

return Human