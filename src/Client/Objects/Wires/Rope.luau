--------------------------------------------------------
-- [Ragdollworks] Rope
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

local SpawnedWire = require(Rage.ReplicatedStorage.Classes.Objects.SpawnedWire)
local ObjectTypes = require(Rage.ReplicatedStorage.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A simple rope-like wire.
]]
Rope = {} :: Rope
Rope.__index = Rope
setmetatable(Rope, SpawnedWire)

--[[
    Creates a new Rope class instance.
]]
function Rope.New(): Rope
    local self = setmetatable(SpawnedWire.New(), Rope) :: Rope
    self.RopeConstraint = nil :: RopeConstraint

    return self
end

--[[
    Called every update.
]]
function Rope:OnUpdate() end

--[[
    Called on instantiation.
]]
function Rope:OnConnect()
    self.RopeConstraint = Instance.new("RopeConstraint")
    self.RopeConstraint.Name = "Rope"
    self.RopeConstraint.Attachment0 = self.ObjectPartA.AttachmentInstance
    self.RopeConstraint.Attachment1 = self.ObjectPartB.AttachmentInstance
    self.RopeConstraint.Restitution = 0.3
    self.RopeConstraint.Visible = true
    self.RopeConstraint.Thickness = 0.5
    self.RopeConstraint.Length = (self.ObjectPartA:GetPosition() - self.ObjectPartB:GetPosition()).Magnitude
    self.RopeConstraint.Parent = self.ObjectPartA.Part
end

--[[
    Called when the wire needs to be cleaned up.
]]
function Rope:OnCleanup()
    self.RopeConstraint:Destroy()
end

export type Rope = {
    RopeConstraint: RopeConstraint
} & typeof(Rope) & ObjectTypes.SpawnedWire

return {
    Name = "Rope",
    Description = "A simple rope that attaches two objects together.",
    WireClass = Rope
} :: ObjectTypes.Wire