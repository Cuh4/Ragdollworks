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
local types = require(Rage.ReplicatedStorage.Classes.Objects.Types)

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
function HumanObjectBehaviour.New(spawnedObject: types.SpawnedObject): HumanObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(spawnedObject), HumanObjectBehaviour) :: HumanObjectBehaviour
    self.Limbs = {} :: {[types.ObjectPart]: Limb.Limb}
    self.IsForceLimp = false

    return self
end

--[[
    Creates a limb for an object part.
]]
function HumanObjectBehaviour:CreateLimb(objectPart: types.ObjectPart)
    local limb = Limb.FromObjectPart(objectPart)
    limb:Setup()

    self.Limbs[objectPart] = limb

    Rage.Logging:Info("Created limb: "..limb.LimbName)
end

--[[
    Called when an object using this behaviour is spawned.
]]
function HumanObjectBehaviour:OnSpawn()
    for _, objectPart in pairs(self.SpawnedObject.Parts) do
        self:CreateLimb(objectPart)
    end
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function HumanObjectBehaviour:OnPreDespawn()

end

--[[
    Called when an object using this behaviour is activated.
]]
function HumanObjectBehaviour:OnActivate(objectPart: types.ObjectPart)
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
        limb:Update(self.Limbs)
    end
end

export type HumanObjectBehaviour = {
    Limbs: {[types.ObjectPart]: Limb.Limb},
    IsForceLimp: boolean
} & types.ObjectBehaviour

return HumanObjectBehaviour