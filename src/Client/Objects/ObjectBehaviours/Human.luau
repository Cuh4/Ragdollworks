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

local ObjectBehaviour = require(Rage.ReplicatedStorage.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.ReplicatedStorage.Classes.Objects.Types)

local Limb = require(Rage.ReplicatedStorage.Classes.Limb)

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
function HumanObjectBehaviour.New(spawnedObject: ObjectTypes.SpawnedObject): HumanObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(spawnedObject), HumanObjectBehaviour) :: HumanObjectBehaviour
    self.Limbs = {} :: {[ObjectTypes.ObjectPart]: Limb.Limb}
    self.IsForceLimp = false

    return self
end

--[[
    Creates a limb for an object part.
]]
function HumanObjectBehaviour:CreateLimb(objectPart: ObjectTypes.ObjectPart)
    local limb = Limb.FromObjectPart(objectPart)
    self.Limbs[objectPart] = limb

    Rage.Logging:Info("Created limb: "..limb.LimbName)
end

--[[
    Setups all limps.
]]
function HumanObjectBehaviour:SetupLimbs()
    for _, limb in pairs(self.Limbs) do
        limb:Setup(self.Limbs)
    end
end

--[[
    Called when an object using this behaviour is spawned.
]]
function HumanObjectBehaviour:OnSpawn()
    for _, objectPart in pairs(self.SpawnedObject.Parts) do
        self:CreateLimb(objectPart)
    end

    self:SetupLimbs()
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function HumanObjectBehaviour:OnPreDespawn()
    for _, limb in pairs(self.Limbs) do
        limb:Cleanup()
    end
end

--[[
    Called when an object using this behaviour is activated.
]]
function HumanObjectBehaviour:OnActivate(objectPart: ObjectTypes.ObjectPart)
    self.IsForceLimp = not self.IsForceLimp

    for _, limb in pairs(self.Limbs) do
        limb:SetIsForceLimp(self.IsForceLimp)
    end
end

--[[
    Called when an object using this behaviour is updated.
]]
function HumanObjectBehaviour:OnUpdate()
    for _, limb in pairs(self.Limbs) do
        limb:Update()
    end
end

export type HumanObjectBehaviour = {
    Limbs: {[ObjectTypes.ObjectPart]: Limb.Limb},
    IsForceLimp: boolean
} & typeof(HumanObjectBehaviour) & ObjectTypes.ObjectBehaviour

return HumanObjectBehaviour