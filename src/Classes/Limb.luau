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

local Sounds = require(Rage.Path.Sounds)
local UI = require(Rage.Path.UI)
local Effects = require(Rage.Path.Effects)

local Sound, SoundCollection = require(script.Parent.Sound), require(script.Parent.SoundCollection) -- purely for types
local ObjectTypes = require(Rage.ReplicatedStorage.Classes.Objects.Types)

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
function Limb.New(name: string, objectPart: ObjectTypes.ObjectPart, maxHealth: number, maxStabilizationAngularVelocity: number, maxStabilizationTorque: number, bloodDecalCount: number): Limb
    local self = setmetatable({}, Limb) :: Limb
    self.BLOOD_DECAL_MIN_TRANSPARENCY = 0.3
    self.BRUISE_DECAL_MIN_TRANSPARENCY = 0.55

    self.IMPACT_THRESHOLD = 15
    self.IMPACT_COOLDOWN = 0.3
    self.IMPACT_DAMAGE_MULTIPLIER = 1.3
    self.IMPACT_MASS_MULTIPLIER = 0.1

    self.IMPACT_BRUISING_THRESHOLD = 20
    self.IMPACT_BRUISING_MULTIPLIER = 0.007

    self.BLEEDING_IMPACT_THRESHOLD = 55
    self.BLEEDING_IMPACT_HEALTH_THRESHOLD = 0.6 -- % of health needed until impacts can cause bleeding
    self.BLEEDING_IMPACT_MULTIPLIER = 0.001
    self.BLEEDING_HEALTH_LOSS_RATE = 0.012 -- per update (* 60 for a rough per-second estimate)

    self.BRAIN_DEAD_HEALTH_LOSS_RATE = 0.35 -- per update
    self.HEART_DEAD_HEALTH_LOSS_RATE = 0.1 -- per update

    self.UNGROUNDED_STABILIZATION_MULTIPLIER = 0.04

    self.LimbName = name
    self.ObjectPart = objectPart
    self.Health = maxHealth
    self.MaxHealth = maxHealth
    self.BloodDecalCount = bloodDecalCount
    self.Limbs = {}

    self.LastImpact = 0

    self.Bruising = 0
    self.Bleeding = 0
    self.IsLimbAlive = true
    self.IsGrounded = false
    self.IsForceLimp = false
    self.IsBrainAlive = true
    self.IsHeartBeating = true

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
    self.BleedingEffectDefaultRate = nil :: number
    self.BruiseDecal = nil :: Decal

    return self
end

--[[
    Creates a new Limb instance from an ObjectPart.
]]
function Limb.FromObjectPart(objectPart: ObjectTypes.ObjectPart): Limb
    return Limb.New(
        objectPart.Part.Name,
        objectPart,
        objectPart.Part:GetAttribute("MaxHealth") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `MaxHealth` attribute."),
        objectPart.Part:GetAttribute("MaxStabilizationAngularVelocity") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `MaxStabilizationAngularVelocity` attribute."),
        objectPart.Part:GetAttribute("MaxStabilizationTorque") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `MaxStabilizationTorque` attribute."),
        objectPart.Part:GetAttribute("BloodDecalCount") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `BloodDecalCount` attribute.")
    )
end

--[[
    Returns the stabilization force's responsiveness.
]]
function Limb:GetStabilizationForceResponsiveness(): number
    local responsiveness = 10 * self:GetHealthPercentage()

    if not self.IsGrounded then
        responsiveness *= self.UNGROUNDED_STABILIZATION_MULTIPLIER
    end

    return responsiveness
end

--[[
    Returns the stabilization force's max torque.
]]
function Limb:GetStabilizationForceMaxTorque(): number
    local maxForce = self.MaxStabilizationTorque * self:GetHealthPercentage()

    if not self.IsGrounded then
        maxForce *= self.UNGROUNDED_STABILIZATION_MULTIPLIER
    end

    return maxForce
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
    Returns all limbs, as parts, belonging to the human this limb belongs to.
]]
function Limb:GetLimbParts(): {Part}
    local parts = {} :: {Part}

    for _, limb in pairs(self.Limbs) do
        table.insert(parts, limb.ObjectPart.Part)
    end

    return parts
end

--[[
    Applies bleeding.
]]
function Limb:ApplyBleeding(amount)
    self.Bleeding = math.clamp(self.Bleeding + amount, 0, 1)
    Rage.Logging:Info(self.LimbName..": Bleeding += "..amount)
end

--[[
    Applies bruising.
]]
function Limb:ApplyBruising(amount: number)
    self.Bruising = math.clamp(self.Bruising + amount, 0, 1)
    Rage.Logging:Info(self.LimbName..": Bruising += "..amount)
end

--[[
    Returns if the human this limb belongs to is grounded (feet touching ground).
]]
function Limb:DetectIsGrounded(): boolean
    if Rage.Libs.String:EndsWith(self.LimbName, "Foot") then
        return self:IsTouchingBeneath()
        -- local raycastParams = RaycastParams.new()
        -- raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        -- raycastParams.FilterDescendantsInstances = self:GetLimbParts()

        -- local result = game.Workspace:Raycast(
        --     self.ObjectPart.Part.Position,
        --     -self.ObjectPart.Part.CFrame.UpVector * 2,
        --     raycastParams
        -- )

        -- Debug:CreateDebugPart(self.ObjectPart.Part.Position - (self.ObjectPart.Part.CFrame.UpVector * 2))

        -- if result then
        --     return true
        -- else
        --     return false
        -- end
    else
        return self:FindLimbByName("LeftFoot").IsGrounded or self:FindLimbByName("RightFoot").IsGrounded
    end
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

        if time() - self.LastImpact < self.IMPACT_COOLDOWN then
            return
        end

        self.LastImpact = time()

        local delta = (self.ObjectPart:GetVelocity3D() - part.AssemblyLinearVelocity).Magnitude
        local mass = part.Anchored and 1 or part.Mass

        if delta >= self.IMPACT_THRESHOLD then
            local impactAmount = (delta - self.IMPACT_THRESHOLD) + (mass * self.IMPACT_MASS_MULTIPLIER)
            self:HandleImpact(impactAmount)
        end
    end)
end

--[[
    Called when the limb received an impact.
]]
function Limb:HandleImpact(amount: number)
    -- Log
    Rage.Logging:Info(self.LimbName..": Impact, amount: "..amount)

    -- Inflict damage
    self:Damage(amount * self.IMPACT_DAMAGE_MULTIPLIER)

    -- Trigger bleeding
    if amount > self.BLEEDING_IMPACT_THRESHOLD and self:GetHealthPercentage() < self.BLEEDING_IMPACT_HEALTH_THRESHOLD then
        self:ApplyBleeding(amount * self.BLEEDING_IMPACT_MULTIPLIER)
    end

    -- Bruising
    if amount > self.IMPACT_BRUISING_THRESHOLD then
        self:ApplyBruising(amount * self.IMPACT_BRUISING_MULTIPLIER)
    end

    -- SFX
    self.ImpactSounds:PlayRandom({
        Sounds:CreateSoundModifier("PitchShiftSoundEffect", {
            Octave = math.clamp(1 - (amount / 175), 0.75, 1)
        })
    })

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
    Returns if the limb is touching anything beneath it.
]]
function Limb:IsTouchingBeneath(): boolean
    for _, part in pairs(self:GetTouchingParts()) do
        if part.Position.Y < self.ObjectPart.Part.Position.Y then
            return true
        end
    end

    return false
end

--[[
    Damages the limb.
]]
function Limb:Damage(amount: number)
    if self.Health <= 0 then
        return
    end

    self.Health = math.clamp(self.Health - amount, 0, self.MaxHealth)
end

--[[
    Returns the blood decal at the provided index.
]]
function Limb:GetBloodDecal(index: number): Decal
    local decal = self.ObjectPart.Part:FindFirstChild("Blood"..index)

    if not decal then
        Rage.Logging:Error(self.LimbName..": Missing blood decal at index #"..index)
    end

    return decal
end

--[[
    Returns whether or not the limb is alive.
]]
function Limb:IsAlive(): boolean
    return self.IsLimbAlive and self.IsBrainAlive and self.IsHeartBeating
end

--[[
    Handles limb stabilization. Call in `:Update()`.
]]
function Limb:HandleStabilization()
    self.StabilizationForce.MaxTorque = self:GetStabilizationForceMaxTorque()
    self.StabilizationForce.Responsiveness = self:GetStabilizationForceResponsiveness()
    self.StabilizationForce.Enabled = self:IsAlive() and not self.IsForceLimp
end

--[[
    Handles limb bleeding. Call in `:Update()`.
]]
function Limb:HandleBleeding()
    if self.Bleeding <= 0 then
        self.BleedingEffect.Enabled = false
        return
    end

    self:Damage(self.BLEEDING_HEALTH_LOSS_RATE * self.Bleeding)
    self.BleedingEffect.Rate = self.BleedingEffectDefaultRate * self.Bleeding
    self.BleedingEffect.Enabled = true
end

--[[
    Handles health UI. Call in `:Update()`.
]]
function Limb:HandleHealthUI()
    self.HealthContainer.BackgroundColor3 = Color3.fromRGB(
        math.floor((self.MaxHealth - self.Health) / self.MaxHealth * 255),
        math.floor(self:GetHealthPercentage() * 255),
        0
    )

    self.HealthContainer.Size = UDim2.new(self:GetHealthPercentage(), 0, 0.3, 0)
end

--[[
    Handles limb state. Call in `:Update()`.
]]
function Limb:HandleState()
    self.IsGrounded = self:DetectIsGrounded()
    self.IsLimbAlive = self.Health > 0
    self.IsBrainAlive = self:FindLimbByName("Head").IsLimbAlive
    self.IsHeartBeating = self:FindLimbByName("UpperTorso").IsLimbAlive
end

--[[
    Handles damage visuals. Call in `:Update()`.
]]
function Limb:HandleDamageVisuals()
    -- Bruising decal
    self.BruiseDecal.Transparency = Rage.Libs.Math:Lerp(1, self.BRUISE_DECAL_MIN_TRANSPARENCY, self.Bruising)

    -- Blood decals
    local step = self.MaxHealth / self.BloodDecalCount -- 33.3

    for index = 1, self.BloodDecalCount do
        local decal = self:GetBloodDecal(index)
        local startBound = (index - 1) * step
        local endBound = index * step
        local damage = self.MaxHealth - self.Health

        local progress = math.clamp((damage - startBound) / (endBound - startBound), 0, 1)
        decal.Transparency = Rage.Libs.Math:Lerp(1, self.BLOOD_DECAL_MIN_TRANSPARENCY, progress)
    end
end

--[[
    Handle passive damage. Call in `:Update()`.
]]
function Limb:HandlePassiveDamage()
    if not self.IsBrainAlive then
        self:Damage(self.BRAIN_DEAD_HEALTH_LOSS_RATE)
    end

    if not self.IsHeartBeating then
        self:Damage(self.HEART_DEAD_HEALTH_LOSS_RATE)
    end
end

--[[
    Setups the limb.
]]
function Limb:Setup(limbs: {[ObjectTypes.ObjectPart]: Limb})
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
    self.BleedingEffectDefaultRate = self.BleedingEffect.Rate
    self.BleedingEffect.Enabled = false

    self.BruiseDecal = self.ObjectPart.Part:FindFirstChild("Bruise") or Rage.Logging:Error(self.LimbName..": Missing `Bruise` decal.") :: Decal

    self:TrackImpacts()
end

--[[
    Updates this limb.
]]
function Limb:Update()
    self:HandleDamageVisuals()
    self:HandleState()
    self:HandleHealthUI()
    self:HandleStabilization()
    self:HandleBleeding()
    self:HandlePassiveDamage()
end

--[[
    Called when this limb needs cleaning up.
]]
function Limb:Cleanup()
    self.TouchConnection:Disconnect()
end

export type Limb = {
    BLOOD_DECAL_MIN_TRANSPARENCY: number,
    BRUISE_DECAL_MIN_TRANSPARENCY: number,

    IMPACT_THRESHOLD: number,
    IMPACT_COOLDOWN: number,
    IMPACT_DAMAGE_MULTIPLIER: number,
    IMPACT_MASS_MULTIPLIER: number,

    IMPACT_BRUISING_THRESHOLD: number,
    IMPACT_BRUISING_MULTIPLIER: number,

    BLEEDING_IMPACT_THRESHOLD: number,
    BLEEDING_IMPACT_HEALTH_THRESHOLD: number,
    BLEEDING_IMPACT_MULTIPLIER: number,
    BLEEDING_HEALTH_LOSS_RATE: number,

    BRAIN_DEAD_HEALTH_LOSS_RATE: number,
    HEART_DEAD_HEALTH_LOSS_RATE: number,

    UNGROUNDED_STABILIZATION_MULTIPLIER: number,

    LimbName: string,
    ObjectPart: ObjectTypes.ObjectPart,
    Health: number,
    MaxHealth: number,
    BloodDecalCount: number,
    Limbs: {[ObjectTypes.ObjectPart]: Limb},

    BillboardGUI: BillboardGui,
    HealthContainer: Frame,

    LastImpact: number,

    Bruising: number,
    Bleeding: number,
    IsLimbAlive: boolean,
    Grounded: boolean,
    IsForceLimp: boolean,
    IsBrainAlive: boolean,
    IsHeartBeating: boolean,

    StabilizationForce: AlignOrientation,
    Attachment: Attachment,
    MaxStabilizationAngularVelocity: number,
    MaxStabilizationTorque: number,

    ImpactSounds: SoundCollection.SoundCollection,

    ImpactEffects: {string},
    BleedingEffect: ParticleEmitter,
    BleedingEffectDefaultRate: number,
    BruiseDecal: Decal,

    TouchConnection: RBXScriptConnection
} & typeof(Limb)

return Limb