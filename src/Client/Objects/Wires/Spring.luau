--------------------------------------------------------
-- [Ragdollworks] Spring
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Copyright (C) 2025 Cuh4

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

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