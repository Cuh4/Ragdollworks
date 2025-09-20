--------------------------------------------------------
-- [Ragdollworks] Spring
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

local Wire = require(Rage.Path.Classes.Objects.Wire)
local SpawnedWire = require(Rage.Path.Classes.Objects.SpawnedWire)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A spring wire.
]]
Spring = {} :: Spring
Spring.__index = Spring
setmetatable(Spring, SpawnedWire)

--[[
    Creates a new Spring class instance.
]]
function Spring.New(): Spring
    local self = setmetatable(SpawnedWire.New(), Spring) :: Spring
    self.SpringConstraint = nil :: SpringConstraint

    return self
end

--[[
    Called every update.
]]
function Spring:OnUpdate() end

--[[
    Called on instantiation.
]]
function Spring:OnConnect()
    self.SpringConstraint = Instance.new("SpringConstraint")
    self.SpringConstraint.Name = "Spring"
    self.SpringConstraint.Attachment0 = self.TargetA.Attachment
    self.SpringConstraint.Attachment1 = self.TargetB.Attachment
    self.SpringConstraint.Stiffness = 1000
    self.SpringConstraint.FreeLength = (self.TargetA:GetPosition() - self.TargetB:GetPosition()).Magnitude * 0.9
    self.SpringConstraint.Damping = 25
    self.SpringConstraint.Visible = true
    self.SpringConstraint.Thickness = 0.5
    self.SpringConstraint.Parent = self.StorageInstance
end

--[[
    Called when the wire needs to be cleaned up.
]]
function Spring:OnCleanup()
    self.SpringConstraint:Destroy()
end

export type Spring = ObjectTypes.SpawnedWire & typeof(Spring) & {
    SpringConstraint: SpringConstraint
}

return Wire.New(
    "Spring",
    "A wire that acts as a spring.",
    Spring,
    false
)