--------------------------------------------------------
-- [Ragdollworks] Strut
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
    "Strut",
    "A strut that provides a rigid connection as if the parts are welded together.",
    Strut,
    true
)