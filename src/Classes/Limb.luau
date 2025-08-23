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
local Sounds = require(Rage.Path.Sounds)
local UI = require(Rage.Path.UI)
local Effects = require(Rage.Path.Effects)

local Sound, SoundCollection = require(script.Parent.Sound), require(script.Parent.SoundCollection) -- purely for types
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
    local self = setmetatable({}, Limb) :: Limb
    self.LimbName = objectPart.Part.Name
    self.ObjectPart = objectPart
    self.Health = maxHealth
    self.MaxHealth = maxHealth
    self.Limbs = {}

    self.ImpactThreshold = 7
    self.LastImpact = 0
    self.ImpactCooldown = 0.1

    self.IsBleeding = false
    self.BleedingImpactThreshold = 10
    self.BleedingImpactHealthThreshold = 0.6 -- % of health needed until impacts can cause bleeding

    self.IsLimbAlive = true
    self.Grounded = false
    self.IsForceLimp = false

    self.StabilizationForce = nil :: AlignOrientation
    self.Attachment = nil :: Attachment
    self.MaxStabilizationAngularVelocity = maxStabilizationAngularVelocity
    self.MaxStabilizationTorque = maxStabilizationTorque

    local _impactSettings = {
        Volume = 0.06
    } :: Sound.SoundSettings

    self.ImpactSounds = Sounds:CreateSoundCollection(
        Sounds:CreateSound(7446607140, _impactSettings),
        Sounds:CreateSound(7446609932, _impactSettings),
        Sounds:CreateSound(7446609976, _impactSettings),
        Sounds:CreateSound(7446606796, _impactSettings),
        Sounds:CreateSound(7446606976, _impactSettings),
        Sounds:CreateSound(7446606925, _impactSettings)
    )

    self.ImpactEffects = {
        "Impact1"
    }

    self.BleedingEffect = nil :: ParticleEmitter

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
function Limb:GetStabilizationForceResponsiveness(): number
    return 10 * self:GetHealthPercentage()
end

--[[
    Returns the stabilization force's max torque.
]]
function Limb:GetStabilizationForceMaxTorque(): number
    return 2500 * self:GetHealthPercentage()
end

--[[
    Finds a limb by name.
]]
function Limb:FindLimbByName(name: string): Limb?
    for _, limb in pairs(self.Limbs) do
        if limb.LimbName == name then
            return limb
        end
    end
end

--[[
    Makes this limb bleed.
]]
function Limb:StartBleeding()
    Rage.Logging:Info(self.LimbName..": Bleeding started")
    self.IsBleeding = true
end

--[[
    Stops the limb from bleeding.
]]
function Limb:StopBleeding()
    Rage.Logging:Info(self.LimbName..": Bleeding stopped")
    self.IsBleeding = false
end

--[[
    Returns if the human this limb belongs to is grounded (feet touching ground).
]]
function Limb:IsGrounded(): boolean
    local feet = {
        self:FindLimbByName("LeftFoot"),
        self:FindLimbByName("RightFoot")
    } :: {Limb}

    local limbsAsParts = {} :: Part

    for _, limb in pairs(self.Limbs) do
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
    Returns the limb's health percentage.
]]
function Limb:GetHealthPercentage(): number
    return self.Health / self.MaxHealth
end

--[[
    Tracks limb impacts.
]]
function Limb:TrackImpacts()
    self.TouchConnection = self.ObjectPart.Part.Touched:Connect(function(part: BasePart)
        if self:DoesPartBelongsToLimb(part) then
            return
        end

        if time() - self.LastImpact < self.ImpactCooldown then
            return
        end

        self.LastImpact = time()

        local delta = (self.ObjectPart:GetVelocity3D() - part.AssemblyLinearVelocity).Magnitude

        if delta >= self.ImpactThreshold then
            self:OnImpact(delta - self.ImpactThreshold)
        end
    end)
end

--[[
    Called when the limb received an impact.
]]
function Limb:OnImpact(amount: number)
    -- Inflict damage
    self:Damage(amount / 10)

    -- Trigger bleeding
    if amount > self.BleedingImpactThreshold and self:GetHealthPercentage() < self.BleedingImpactHealthThreshold then
        self:StartBleeding()
    end

    -- SFX
    self.ImpactSounds:PlayRandom()

    -- VFX
    Effects:SpawnEffect(Rage.Libs.Table:GetRandom(self.ImpactEffects), 0.07, self.ObjectPart.Part)
end

--[[
    Returns if a part belongs to a limb of the human this limb belongs to.
]]
function Limb:DoesPartBelongsToLimb(part: BasePart): boolean
    for _, limb in pairs(self.Limbs) do
        if limb.ObjectPart.Part == part then
            return true
        end
    end

    return false
end

--[[
    Returns touching parts that aren't limbs of the human this limb belongs to.
]]
function Limb:GetTouchingParts(): {BasePart}
    local touching = {} :: {BasePart}

    for _, part in pairs(self.ObjectPart.Part:GetTouchingParts()) do
        if self:DoesPartBelongsToLimb(part) then
            continue
        end

        table.insert(touching, part)
    end

    return touching
end

--[[
    Returns if the limb is touching anything.
]]
function Limb:IsTouching(): boolean
    return #self:GetTouchingParts() > 0
end

--[[
    Damages the limb.
]]
function Limb:Damage(amount: number)
    self.Health = math.clamp(self.Health - amount, 0, self.MaxHealth)
    Rage.Logging:Info(self.LimbName..": damaged, health = "..tostring(self.Health)..", damaged by = "..tostring(amount))
end

--[[
    Setups the limb.
]]
function Limb:Setup(limbs: {[types.ObjectPart]: Limb})
    self.Limbs = limbs

    self.Attachment = Instance.new("Attachment")
    self.Attachment.Name = "LimbAttachment"
    self.Attachment.Parent = self.ObjectPart.Part

    self.StabilizationForce = Instance.new("AlignOrientation")
    self.StabilizationForce.Name = "LimbStabilization"
    self.StabilizationForce.Mode = Enum.OrientationAlignmentMode.OneAttachment
    self.StabilizationForce.Attachment0 = self.Attachment
    self.StabilizationForce.MaxAngularVelocity = self.MaxStabilizationAngularVelocity
    self.StabilizationForce.Parent = self.ObjectPart.Part

    self.BillboardGUI = UI:GetComponent("LimbHealth"):Clone() :: BillboardGui
    self.BillboardGUI.Parent = self.ObjectPart.Part

    self.HealthContainer = self.BillboardGUI:FindFirstChild("Container") or Rage.Logging:Error(self.LimbName..": Missing `Container` object in health billboard GUI.") :: Frame

    self.BleedingEffect = Effects:SpawnEffect("Bleeding", -1, self.ObjectPart.Part)
    self.BleedingEffect.Enabled = false

    self:TrackImpacts()
end

--[[
    Updates this limb.
]]
function Limb:Update()
    local _previous = self.Grounded
    self.Grounded = self:IsGrounded()

    if _previous ~= self.Grounded then
        Rage.Logging:Info(self.LimbName..": grounded = "..tostring(self.Grounded))
    end

    self.IsLimbAlive = self.Health > 0

    self.StabilizationForce.MaxTorque = self:GetStabilizationForceMaxTorque()
    self.StabilizationForce.Responsiveness = self:GetStabilizationForceResponsiveness()
    self.StabilizationForce.Enabled = self.IsLimbAlive and self.Grounded and not self.IsForceLimp

    self.HealthContainer.BackgroundColor3 = Color3.fromRGB(
        math.floor((self.MaxHealth - self.Health) / self.MaxHealth * 255),
        math.floor(self:GetHealthPercentage() * 255),
        0
    )

    self.HealthContainer.Size = UDim2.new(self:GetHealthPercentage(), 0, 1, 0)

    self.BleedingEffect.Enabled = self.IsBleeding
end

--[[
    Called when this limb needs cleaning up.
]]
function Limb:Cleanup()
    self.TouchConnection:Disconnect()
end

export type Limb = {
    LimbName: string,
    ObjectPart: types.ObjectPart,
    Health: number,
    MaxHealth: number,
    Limbs: {[types.ObjectPart]: Limb},

    BillboardGUI: BillboardGui,
    HealthContainer: Frame,

    ImpactThreshold: number,
    LastImpact: number,
    ImpactCooldown: number,

    IsBleeding: boolean,
    BleedingImpactThreshold: number,
    BleedingImpactHealthThreshold: number,

    IsLimbAlive: boolean,
    Grounded: boolean,
    IsForceLimp: boolean,

    StabilizationForce: AlignOrientation,
    Attachment: Attachment,
    MaxStabilizationAngularVelocity: number,
    MaxStabilizationTorque: number,

    ImpactSounds: SoundCollection.SoundCollection,

    ImpactEffects: {string},
    BleedingEffect: ParticleEmitter,

    TouchConnection: RBXScriptConnection
} & typeof(Limb)

return Limb