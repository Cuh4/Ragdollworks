--------------------------------------------------------
-- [Ragdollworks] Strut
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
    A wire that provides a rigid connection as if the parts are welded together.
]]
Strut = {} :: Strut
Strut.__index = Strut
setmetatable(Strut, SpawnedWire)

--[[
    Creates a new Strut class instance.
]]
function Strut.New(): Strut
    local self = setmetatable(SpawnedWire.New(), Strut) :: Strut
    self.WeldConstraint = nil :: WeldConstraint
    self.VisualBeam = nil :: Beam

    return self
end

--[[
    Called every update.
]]
function Strut:OnUpdate() end

--[[
    Called on instantiation.
]]
function Strut:OnConnect()
    self.WeldConstraint = Instance.new("WeldConstraint")
    self.WeldConstraint.Name = "Strut"
    self.WeldConstraint.Part0 = self.TargetA.Part
    self.WeldConstraint.Part1 = self.TargetB.Part
    self.WeldConstraint.Parent = self.StorageInstance

    self.VisualBeam = Instance.new("Beam")
    self.VisualBeam.Name = "StrutVisuals"
    self.VisualBeam.Attachment0 = self.TargetA.Attachment
    self.VisualBeam.Attachment1 = self.TargetB.Attachment
    self.VisualBeam.Transparency = NumberSequence.new(0)
    self.VisualBeam.TextureSpeed = 0
    self.VisualBeam.Color = ColorSequence.new(Color3.fromRGB(25, 25, 25))
    self.VisualBeam.FaceCamera = true
    self.VisualBeam.Segments = 1
    self.VisualBeam.Width0 = 0.5
    self.VisualBeam.Width1 = 0.5
    self.VisualBeam.Parent = self.StorageInstance
end

--[[
    Called when the wire needs to be cleaned up.
]]
function Strut:OnCleanup()
    self.WeldConstraint:Destroy()
    self.VisualBeam:Destroy()
end

export type Strut = ObjectTypes.SpawnedWire & typeof(Strut) & {
    WeldConstraint: WeldConstraint,
    VisualBeam: Beam
}

return Wire.New(
    1,
    "Strut",
    "A strut that provides a rigid connection as if the parts are welded together.",
    Strut,
    true,
    RbxAssets.STRUT_WIRE_ICON
)