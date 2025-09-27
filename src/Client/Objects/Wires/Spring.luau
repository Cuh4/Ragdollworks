--------------------------------------------------------
-- [Ragdollworks] Spring
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Source-Available No-Redistribution License
        Copyright (c) 2025 Cuh4. All rights reserved.

        IMPORTANT: This source code is NOT Open Source.

        1. PERMISSIONS (Limited):
        * View and read the source code.
        * Modify for private, non-public use only.
        * Contributions back to the project are permitted.

        2. PROHIBITIONS (Strict):
        * You MAY NOT copy, redistribute, publish, or share the code (modified or unmodified).
        * You MAY NOT use this code in ANY public or commercial project or service.

        Any violation automatically terminates your rights.
        Provided "AS IS" without warranty.
        Full terms governed by the laws of England and Wales.

        For the full license, see the `LICENSE` file provided with the source code.

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
    3,
    "Spring",
    "A wire that acts as a spring.",
    Spring,
    false,
    RbxAssets.SPRING_WIRE_ICON
)