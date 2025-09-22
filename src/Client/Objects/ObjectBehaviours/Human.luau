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

local Limb = require(Rage.Path.Classes.Limb)

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

    return self
end

--[[
    Creates a limb for an object part.
]]
function HumanObjectBehaviour:CreateLimb(objectPart: ObjectTypes.ObjectPart)
    local limb = Limb.FromObjectPart(objectPart)
    self.Limbs[objectPart] = limb

    Rage.Logging:Info("HumanObjectBehaviour: Created limb: "..limb.LimbName)
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
    Returns a limb from an object part.
]]
function HumanObjectBehaviour:GetLimb(objectPart: ObjectTypes.ObjectPart): Limb.Limb?
    return self.Limbs[objectPart]
end

--[[
    Creates context menu items.
]]
function HumanObjectBehaviour:CreateContextMenuItems(objectPart: ObjectTypes.ObjectPart)
    local limb = self:GetLimb(objectPart) :: Limb.Limb

    if not limb then
        Rage.Logging:Error("HumanObjectBehaviour:CreateContextMenuItems(): Missing limb for object part: "..objectPart.Part:GetFullName())
    end

    objectPart.ContextMenu:AddContextMenuItem("Wake Up", function()
        limb:WakeUp()
    end)

    objectPart.ContextMenu:AddContextMenuItem("Knockout", function()
        limb:SetUnconsciousFor(60)
    end)

    objectPart.ContextMenu:AddContextMenuItem("Heal Limb", function()
        limb:Heal()
    end)

    objectPart.ContextMenu:AddContextMenuItem("Heal Human", function()
        for _, _limb in pairs(self.Limbs) do
            _limb:Heal()
        end
    end)
end

--[[
    Called when an object using this behaviour is spawned.
]]
function HumanObjectBehaviour:OnSpawn()
    for _, objectPart in pairs(self.SpawnedObject.Parts) do
        self:CreateLimb(objectPart)
        self:CreateContextMenuItems(objectPart)
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
function HumanObjectBehaviour:OnActivate(objectPart: ObjectTypes.ObjectPart) end
--[[
    Called when an object using this behaviour is updated.
]]
function HumanObjectBehaviour:OnUpdate()
    for _, limb in pairs(self.Limbs) do
        limb:Update()
    end
end

export type HumanObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(HumanObjectBehaviour) & {
    Limbs: {[ObjectTypes.ObjectPart]: Limb.Limb}
}

return HumanObjectBehaviour