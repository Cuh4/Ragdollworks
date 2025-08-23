--------------------------------------------------------
-- [Ragdollworks] Limb
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local Debug = require(Rage.Path.Debug)
local Sound = require(Rage.Path.Sounds)

local types = require(Rage.ReplicatedStorage.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a human's limb.
]]
Limb = {} :: Limb
Limb.__index = Limb

--[[
    Creates a new Limb class instance.
]]
function Limb.New(objectPart: types.ObjectPart, maxHealth: number, maxStabilizationAngularVelocity: number, maxStabilizationTorque: number): Limb
    local self = setmetatable({}, Limb)
    self.LimbName = objectPart.Part.Name
    self.ObjectPart = objectPart
    self.Health = maxHealth
    self.MaxHealth = maxHealth

    self.IsBleeding = false
    self.IsLimbAlive = true
    self.Grounded = false
    self.IsForceLimp = false

    self.StabilizationForce = nil :: AlignOrientation
    self.Attachment = nil :: Attachment
    self.MaxStabilizationAngularVelocity = maxStabilizationAngularVelocity
    self.MaxStabilizationTorque = maxStabilizationTorque

    return self
end

--[[
    Creates a new Limb instance from an ObjectPart..
]]
function Limb.FromObjectPart(objectPart: types.ObjectPart): Limb
    return Limb.New(
        objectPart,
        objectPart.Part:GetAttribute("MaxHealth") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `MaxHealth` attribute."),
        objectPart.Part:GetAttribute("MaxStabilizationAngularVelocity") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `MaxStabilizationAngularVelocity` attribute."),
        objectPart.Part:GetAttribute("MaxStabilizationTorque") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `MaxStabilizationTorque` attribute.")
    )
end

--[[
    Returns the stabilization force's responsiveness.
]]
function Limb:GetStabilizationForceResponsiveness()
    return 10 * (self.Health / self.MaxHealth)
end

--[[
    Returns the stabilization force's max torque.
]]
function Limb:GetStabilizationForceMaxTorque()
    return 2500 * (self.Health / self.MaxHealth)
end

--[[
    Setups the limb.
]]
function Limb:Setup()
    self.Attachment = Instance.new("Attachment")
    self.Attachment.Name = "LimbAttachment"
    self.Attachment.Parent = self.ObjectPart.Part

    self.StabilizationForce = Instance.new("AlignOrientation")
    self.StabilizationForce.Name = "LimbStabilization"
    self.StabilizationForce.Mode = Enum.OrientationAlignmentMode.OneAttachment
    self.StabilizationForce.Attachment0 = self.Attachment
    self.StabilizationForce.MaxAngularVelocity = self.MaxStabilizationAngularVelocity
    self.StabilizationForce.Parent = self.ObjectPart.Part
end

--[[
    Finds a limb by name.
]]
function Limb:FindLimbByName(limbs: {[types.ObjectPart]: Limb}, name: string): Limb?
    for _, limb in pairs(limbs) do
        if limb.LimbName == name then
            return limb
        end
    end
end

--[[
    Returns if the human this limb belongs to is grounded (feet touching ground).
]]
function Limb:IsGrounded(limbs: {[types.ObjectPart]: Limb}): boolean
    local feet = {
        self:FindLimbByName(limbs, "LeftFoot"),
        self:FindLimbByName(limbs, "RightFoot")
    } :: {Limb}

    local limbsAsParts = {} :: Part

    for _, limb in pairs(limbs) do
        table.insert(limbsAsParts, limb.ObjectPart.Part)
    end

    for _, foot in pairs(feet) do
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = limbsAsParts

        local result = game.Workspace:Raycast(
            foot.ObjectPart.Part.Position,
            -foot.ObjectPart.Part.CFrame.UpVector * 2,
            raycastParams
        )

        Debug:CreateDebugPart(foot.ObjectPart.Part.Position - (foot.ObjectPart.Part.CFrame.UpVector * 2))

        if result then
            return true
        end
    end

    return false
end

--[[
    Forces/unforces the limb to be limp.
]]
function Limb:SetIsForceLimp(isForceLimp: boolean)
    self.IsForceLimp = isForceLimp
end

--[[
    Updates this limb.
]]
function Limb:Update(limbs: {[types.ObjectPart]: Limb})
    local _previous = self.Grounded
    self.Grounded = self:IsGrounded(limbs)

    if _previous ~= self.Grounded then
        Rage.Logging:Info(self.LimbName..": grounded = "..tostring(self.Grounded))
    end

    self.StabilizationForce.MaxTorque = self:GetStabilizationForceMaxTorque()
    self.StabilizationForce.Responsiveness = self:GetStabilizationForceResponsiveness()
    self.StabilizationForce.Enabled = self.IsLimbAlive and self.Grounded and not self.IsForceLimp
end

export type Limb = {
    LimbName: string,
    ObjectPart: types.ObjectPart,
    Health: number,
    MaxHealth: number,

    IsBleeding: boolean,
    IsLimbAlive: boolean,
    Grounded: boolean,
    IsForceLimp: boolean,

    StabilizationForce: AlignOrientation,
    Attachment: Attachment,
    MaxStabilizationAngularVelocity: number,
    MaxStabilizationTorque: number
} & typeof(Limb)

return Limb