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

local Wire = require(Rage.Path.Classes.Objects.Wire)
local SpawnedWire = require(Rage.Path.Classes.Objects.SpawnedWire)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

local RbxAssets = require(Rage.Path.RbxAssets)

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
    self.RopeConstraint.Attachment0 = self.TargetA.Attachment
    self.RopeConstraint.Attachment1 = self.TargetB.Attachment
    self.RopeConstraint.Restitution = 0.3
    self.RopeConstraint.Visible = true
    self.RopeConstraint.Thickness = 0.5
    self.RopeConstraint.Length = (self.TargetA:GetPosition() - self.TargetB:GetPosition()).Magnitude + 0.001
    self.RopeConstraint.Parent = self.StorageInstance
end

--[[
    Called when the wire needs to be cleaned up.
]]
function Rope:OnCleanup()
    self.RopeConstraint:Destroy()
end

export type Rope = ObjectTypes.SpawnedWire & typeof(Rope) & {
    RopeConstraint: RopeConstraint
}

return Wire.New(
    4,
    "Rope",
    "A simple rope that attaches two objects together.",
    Rope,
    false,
    RbxAssets.ROPE_WIRE_ICON
)