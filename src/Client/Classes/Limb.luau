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
local RbxAssets = require(Rage.Path.RbxAssets)
local Debug = require(Rage.Path.Debug)
local Maps = require(Rage.Path.Maps)
local Objects = require(Rage.Path.Objects)

local Sound, SoundCollection = require(script.Parent.Sound), require(script.Parent.SoundCollection) -- purely for types
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

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
function Limb.New(name: string, objectPart: ObjectTypes.ObjectPart, maxHealth: number, maxStabilizationAngularVelocity: number, maxStabilizationTorque: number, skinDamageDecalCount: number): Limb
    local self = setmetatable({}, Limb) :: Limb
    self.GRUNT_IMPACT_THRESHOLD = 12
    self.GRUNT_COOLDOWN = 0.3

    self.UNCONSCIOUS_MAX_TIME = 80 -- seconds
    self.UNCONSCIOUS_MIN_TIME = 5 -- seconds
    self.UNCONSCIOUS_IMPACT_THRESHOLD = 22
    self.UNCONSCIOUS_RNG = 2 -- 1 in x
    self.UNCONSCIOUS_IMPACT_TIME_MULTIPLIER = 1.1

    self.IMPACT_MAX_PROPAGATIONS = 5
    self.IMPACT_PROPAGATION_MULTIPLIER = 0.2 -- limb 1 = * IMPACT_PROPAGATION_MULTIPLIER, limb 2 = * IMPACT_PROPAGATION_MULTIPLIER / 2, etc
    self.IMPACT_THRESHOLD = 15
    self.IMPACT_COOLDOWN = 0.1
    self.IMPACT_DAMAGE_MULTIPLIER = 1.3
    self.IMPACT_MASS_MULTIPLIER = 0.25

    self.BRUISE_DECAL_TRANSPARENCY_RANGE = NumberRange.new(0.55, 1)
    self.IMPACT_BRUISING_THRESHOLD = 16
    self.IMPACT_BRUISING_MULTIPLIER = 0.0095

    self.SKIN_DAMAGE_DECAL_TRANSPARENCY_RANGE = NumberRange.new(0.25, 1)
    self.FLESH_DECAL_TRANSPARENCY_RANGE = NumberRange.new(0.95, 1)
    self.BONE_DECAL_TRANSPARENCY_RANGE = NumberRange.new(0.87, 1)
    self.BONE_FROM_SKIN_DAMAGE_MULTIPLIER = 1.2
    self.IMPACT_SKIN_DAMAGE_THRESHOLD = 24
    self.IMPACT_SKIN_DAMAGE_MULTIPLIER = 0.013

    self.GORY_IMPACT_SOUND_SKIN_DAMAGE_THRESHOLD = 0.95 -- %
    self.GORY_IMPACT_SOUND_THRESHOLD = 65

    self.BLEEDING_SOUND_VOLUME = 0.7
    self.BLEEDING_IMPACT_THRESHOLD = 50
    self.BLEEDING_IMPACT_HEALTH_THRESHOLD = 0.6 -- % of health needed until impacts can cause bleeding
    self.BLEEDING_IMPACT_MULTIPLIER = 0.001
    self.BLEEDING_HEALTH_LOSS_RATE = 0.012 -- per update (* 60 for a rough per-second estimate)

    self.BRAIN_DEAD_HEALTH_LOSS_RATE = 0.35 -- per update
    self.HEART_DEAD_HEALTH_LOSS_RATE = 0.1 -- per update

    self.UNGROUNDED_STABILIZATION_MULTIPLIER = 0.6
    self.UNGROUNDED_STABILIZATION_TARGET_RANDOMNESS = NumberRange.new(-45, 45) -- degrees

    self.LimbName = name
    self.ObjectPart = objectPart
    self.Health = maxHealth
    self.MaxHealth = maxHealth
    self.SkinDamageDecalCount = skinDamageDecalCount
    self.Limbs = {}
    self._LimbCache = {}
    self.ConnectedLimb = nil

    self.LastGrunt = 0
    self.LastImpact = 0

    self.Bruising = 0
    self.Bleeding = 0
    self.SkinDamage = 0
    self.IsLimbAlive = true
    self.IsGrounded = false
    self.IsUnconscious = false
    self.UnconsciousTil = 0
    self.IsBrainAlive = true
    self.IsHeartBeating = true
    self.PlayedDeathScream = false

    self.StatusBillboardGUI = nil :: BillboardGui
    self.StatusIcon = nil :: ImageLabel

    self.StabilizationForce = nil :: AlignOrientation
    self.Attachment = nil :: Attachment
    self.MaxStabilizationAngularVelocity = maxStabilizationAngularVelocity
    self.MaxStabilizationTorque = maxStabilizationTorque

    local bleedingSound = Sounds:CreateSound(RbxAssets.BLEEDING_SOUND,{
        Looped = true,
        RollOffMinDistance = 10,
        RollOffMaxDistance = 20
    }) :: Sound.RSound

    self.BleedingSound = bleedingSound:Play({}, self.ObjectPart.Part)

    self.GoryImpactSounds = Sounds:CreateSoundCollection(
        Sounds:CreateSound(RbxAssets.HUMAN_HEAVY_GORY_IMPACT_1, {Volume = 0.2}),
        Sounds:CreateSound(RbxAssets.HUMAN_HEAVY_GORY_IMPACT_2, {Volume = 0.2}),
        Sounds:CreateSound(RbxAssets.HUMAN_HEAVY_GORY_IMPACT_3, {Volume = 0.2})
    )

    local _impactSettings = {
        Volume = 0.06
    } :: Sound.SoundSettings

    self.ImpactSounds = Sounds:CreateSoundCollection(
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_1, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_2, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_3, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_4, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_5, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_6, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_7, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_8, _impactSettings),
        Sounds:CreateSound(RbxAssets.HUMAN_IMPACT_9, _impactSettings)
    )

    self.ImpactEffects = {
        "Impact1"
    }

    self.GruntSounds = Sounds:CreateSoundCollection(
        Sounds:CreateSound(RbxAssets.HUMAN_GRUNT_1, {Volume = 0.7}),
        Sounds:CreateSound(RbxAssets.HUMAN_GRUNT_2, {Volume = 1.2}),
        Sounds:CreateSound(RbxAssets.HUMAN_GRUNT_3, {Volume = 0.2}),
        Sounds:CreateSound(RbxAssets.HUMAN_GRUNT_4, {Volume = 0.4}),
        Sounds:CreateSound(RbxAssets.HUMAN_GRUNT_5, {Volume = 0.3}),
        Sounds:CreateSound(RbxAssets.HUMAN_GRUNT_6, {Volume = 0.35})
    )

    self.DeathSounds = Sounds:CreateSoundCollection(
        Sounds:CreateSound(RbxAssets.HUMAN_DEATH_1, {Volume = 0.4}),
        Sounds:CreateSound(RbxAssets.HUMAN_DEATH_2, {Volume = 0.5}),
        Sounds:CreateSound(RbxAssets.HUMAN_DEATH_3, {Volume = 0.7})
    )

    self.BleedingEffect = nil :: ParticleEmitter
    self.BleedingEffectDefaultRate = nil :: number
    self.BruiseDecal = nil :: Decal
    self.FleshDecal = nil :: Decal
    self.BoneDecal = nil :: Decal

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
        objectPart.Part:GetAttribute("SkinDamageDecalCount") or Rage.Logging:Error(objectPart.Part:GetFullName()..": Missing `SkinDamageDecalCount` attribute.")
    )
end

--[[
    Helper method to make a method only run on a certain limb.<br>
    Returns false if the method was attempted to be called on the wrong limb.
]]
function Limb:OnlyRunOnLimb(limbName: string, methodName: string, ...): boolean
    if self.LimbName ~= limbName then
        local limb = self:FindLimbByName(limbName)

        if not limb then
            Rage.Logging:Error("Limb:OnlyRunOnLimb(): Limb `"..limbName.."` does not exist.")
        end

        limb[methodName](limb, ...)
        return false
    end

    return true
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
    Returns the CFrame for the stabilization force to match.
]]
function Limb:GetStabilizationForceCFrame(): CFrame
    if self.IsGrounded then
        return CFrame.Angles(0, 0, 0)
    end

    local _, _, rotationZ = self.ConnectedLimb.ObjectPart.Part.CFrame:ToEulerAnglesXYZ() or 0, 0, 0
    rotationZ = math.deg(rotationZ)

    rotationZ += Rage.Libs.Math:Random( -- go crazy
        self.UNGROUNDED_STABILIZATION_TARGET_RANDOMNESS.Min,
        self.UNGROUNDED_STABILIZATION_TARGET_RANDOMNESS.Max
    )

    return CFrame.Angles(0, 0, math.deg(rotationZ))
end

--[[
    Finds a limb by name.
]]
function Limb:FindLimbByName(name: string): Limb?
    if self._LimbCache[name] then
        return self._LimbCache[name]
    end

    for _, limb in pairs(self.Limbs) do
        if limb.LimbName == name then
            self._LimbCache[name] = limb
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
    Returns the closest limb.
]]
function Limb:GetClosestLimb(): Limb
    return Rage.Libs.Table:GetMax(self.Limbs, function(current: Limb, max: Limb)
        local currentDistance = (current.ObjectPart:GetPosition3D() - self.ObjectPart:GetPosition3D()).Magnitude
        local maxDistance = (max.ObjectPart:GetPosition3D() - self.ObjectPart:GetPosition3D()).Magnitude

        return currentDistance < maxDistance and
            current.ClosestLimb ~= self and
            current.ObjectPart:GetPosition().Y < self.ObjectPart:GetPosition().Y
    end)
end

--[[
    Plays a grunt sound if possible.
]]
function Limb:Grunt()
    if not self:OnlyRunOnLimb("Head", "Grunt") then
        return
    end

    if os.clock() - self.LastGrunt < self.GRUNT_COOLDOWN then
        Rage.Logging:Warn(self.LimbName..": Grunt on cooldown")
        return -- still on cooldown
    end

    if not self:IsAlive() then
        Rage.Logging:Warn(self.LimbName..": Attempted to grunt while dead")
        return
    end

    if not self:IsAwake() then
        Rage.Logging:Warn(self.LimbName..": Attempted to grunt while unconscious")
        return
    end

    self.LastGrunt = os.clock()
    self.GruntSounds:PlayRandom({}, self.ObjectPart.Part)

    Rage.Logging:Info(self.LimbName..": Grunted")
end

--[[
    Plays an impact sound.
]]
function Limb:PlayImpactSound(impactAmount: number)
    local pitchShift = Sounds:CreateSoundModifier("PitchShiftSoundEffect", {
        Octave = math.clamp(1 - (impactAmount / 175), 0.7, 1)
    })

    self.ImpactSounds:PlayRandom({pitchShift}, self.ObjectPart.Part)

    if impactAmount >= self.GORY_IMPACT_SOUND_THRESHOLD or self.SkinDamage >= self.GORY_IMPACT_SOUND_SKIN_DAMAGE_THRESHOLD then
        self.GoryImpactSounds:PlayRandom({pitchShift}, self.ObjectPart.Part)
    end
end

--[[
    Plays a death sound if possible.
]]
function Limb:DeathScream()
    if not self:OnlyRunOnLimb("Head", "DeathScream") then
        return
    end

    if self.PlayedDeathScream then
        return
    end

    if not self:IsAwake() then
        Rage.Logging:Warn(self.LimbName..": Attempted to play death scream while unconscious")
        self.PlayedDeathScream = true
        return
    end

    self.DeathSounds:PlayRandom({}, self.ObjectPart.Part)
    self.PlayedDeathScream = true

    Rage.Logging:Info(self.LimbName..": Playing death scream")
end

--[[
    Applies bleeding.
]]
function Limb:ApplyBleeding(amount)
    self.Bleeding = math.clamp(self.Bleeding + amount, 0, 1)
    Rage.Logging:Info(self.LimbName..": Bleeding += "..amount)
end

--[[
    Removes all bleeding.
]]
function Limb:RemoveBleeding()
    self.Bleeding = 0
end

--[[
    Applies skin damage.
]]
function Limb:ApplySkinDamage(amount: number)
    self.SkinDamage = math.clamp(self.SkinDamage + amount, 0, 1)
    Rage.Logging:Info(self.LimbName..": Skin damage += "..amount)
end


--[[
    Removes all skin damage.
]]
function Limb:RemoveSkinDamage()
    self.SkinDamage = 0
end

--[[
    Applies bruising.
]]
function Limb:ApplyBruising(amount: number)
    self.Bruising = math.clamp(self.Bruising + amount, 0, 1)
    Rage.Logging:Info(self.LimbName..": Bruising += "..amount)
end

--[[
    Removes all bruising.
]]
function Limb:RemoveBruising()
    self.Bruising = 0
end

--[[
    Sets the status icon.
]]
function Limb:SetStatusIcon(icon: string)
    if self.LimbName ~= "Head" then
        return
    end

    if self.StatusIcon.Image == icon then
        return
    end

    self.StatusIcon.Image = icon
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

        local limbVelocity = self.ObjectPart:GetVelocity3D()
        local partVelocity = part.AssemblyLinearVelocity
        local relativeVelocity =  partVelocity - limbVelocity :: Vector3
        local directionVector = part.Position - self.ObjectPart:GetPosition3D() :: Vector3

        -- if limbVelocity:Dot(directionVector) <= 0 or (partVelocity:Dot(-directionVector) <= 0 and not part.Anchored) then
        --     return
        -- end

        if relativeVelocity.Magnitude < self.IMPACT_THRESHOLD then
            return
        end

        local mass = Maps:BelongsToMap(part) and 1 or part.Mass

        local impactAmount = (relativeVelocity.Magnitude - self.IMPACT_THRESHOLD) + (mass * self.IMPACT_MASS_MULTIPLIER)
        self:HandleImpact(impactAmount)

        Debug:CreateDebugText(
            self.ObjectPart:GetPosition(),
            ("%s: %.2f (mass: %.2f)"):format(self.LimbName, impactAmount, mass)
        )
    end)
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
    Returns if the human this limb belongs to is grounded (feet touching ground).
]]
function Limb:DetectIsGrounded(): boolean
    if Rage.Libs.String:EndsWith(self.LimbName, "Foot") then
        return self:IsTouchingBeneath()
    else
        return self:FindLimbByName("LeftFoot").IsGrounded or self:FindLimbByName("RightFoot").IsGrounded
    end
end

--[[
    Returns if the human this limb belongs to is conscious (awake).
]]
function Limb:IsAwake(): boolean
    return not self.IsUnconscious
end

--[[
    Wakes this limb's human up.
]]
function Limb:WakeUp()
    if self:IsAwake() then
        return
    end

    if not self:OnlyRunOnLimb("Head", "WakeUp") then
        return
    end

    self.IsUnconscious = false
    self.UnconsciousTil = 0

    Rage.Logging:Info(self.LimbName..": Woke up")
end

--[[
    Returns the amount of seconds remaining until this limb's human wakes up.
]]
function Limb:GetUnconsciousnessDuration(): number
    return self.UnconsciousTil - os.clock()
end

--[[
    Sets this limb's human to be unconscious for x seconds.
]]
function Limb:SetUnconsciousFor(seconds: number)
    if not self:IsAwake() then
        local remaining = self:GetUnconsciousnessDuration()

        if remaining + seconds > self.UNCONSCIOUS_MAX_TIME then
            seconds = self.UNCONSCIOUS_MAX_TIME - remaining
        end

        self.UnconsciousTil = self.UnconsciousTil + seconds
        Rage.Logging:Info((self.LimbName..": Unconsciousness extended, now at %.1f secs remaining"):format(self:GetUnconsciousnessDuration()))

        return
    end

    if not self:OnlyRunOnLimb("Head", "SetUnconsciousFor", seconds) then
        return
    end

    self.IsUnconscious = true
    self.UnconsciousTil = os.clock() + seconds

    Rage.Logging:Info((self.LimbName..": Unconscious for %.1f seconds"):format(seconds))
end

--[[
    Returns if the limb is touching anything beneath it.<br>
    Returns false if this is not called on a foot limb.
]]
function Limb:IsTouchingBeneath(): boolean
    if not Rage.Libs.String:EndsWith(self.LimbName, "Foot") then
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = self:GetLimbParts()

    local raycastResult = Rage.Workspace:Raycast(
        self.ObjectPart.Part.Position,
        Vector3.new(0, -self.ObjectPart.Part.Size.Y * 2, 0),
        raycastParams
    )

    return raycastResult ~= nil

    -- below is old and doesn't work when the feet are touching
    -- a rotated object below the center point

    -- for _, part in pairs(self:GetTouchingParts()) do
    --     if part.Position.Y < self.ObjectPart.Part.Position.Y then
    --         return true
    --     end
    -- end

    -- return false
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
    Returns the skin damage decal at the provided index.
]]
function Limb:GetSkinDamageDecal(index: number): Decal
    local decal = self.ObjectPart.Part:FindFirstChild("SkinDamage"..index)

    if not decal then
        Rage.Logging:Error(self.LimbName..": Missing skin damage decal at index #"..index)
    end

    return decal
end

--[[
    Returns a random skin damage decal.
]]
function Limb:GetRandomSkinDamageDecal(): (Decal, number)
    local index = Rage.Libs.Math:Random(1, self.SkinDamageDecalCount)
    return self:GetSkinDamageDecal(index), index
end

--[[
    Creates the status icon (if head only).
]]
function Limb:CreateStatusIcon()
    if self.LimbName ~= "Head" then
        return
    end

    local statusIcon = UI:GetComponent("HumanStatus") :: BillboardGui
    statusIcon.Parent = self.ObjectPart.Part

    self.StatusBillboardGUI = statusIcon
    self.StatusIcon = statusIcon:FindFirstChild("Icon") or Rage.Logging:Error(self.LimbName..": Missing `Icon` object in status billboard GUI.") :: ImageLabel
end

--[[
    Heals the limb.
]]
function Limb:Heal()
    self.Health = self.MaxHealth

    self:RemoveBleeding()
    self:RemoveBruising()
    self:RemoveSkinDamage()
    self:WakeUp()
end

--[[
    Returns whether or not the limb is alive.
]]
function Limb:IsAlive(): boolean
    return self.IsLimbAlive and self.IsBrainAlive and self.IsHeartBeating
end

--[[
    Called when the limb received an impact.
]]
function Limb:HandleImpact(amount: number, _propagations: number?, _propagationJourney: {[Limb]: boolean})
    -- Propagate impact across body
    _propagations = _propagations or 1
    _propagationJourney = _propagationJourney or {}

    if _propagations < self.IMPACT_MAX_PROPAGATIONS and not _propagationJourney[self] then
        _propagationJourney[self] = true

        self.ConnectedLimb:HandleImpact(
            amount * (self.IMPACT_PROPAGATION_MULTIPLIER / _propagations),
            _propagations + 1,
            _propagationJourney
        )
    end

    local isPropagatedImpact = _propagations > 1

    -- Log
    Rage.Logging:Info(self.LimbName..(": Impact with amount: %.2f. Was due to propagation: %s"):format(amount, tostring(isPropagatedImpact)))

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

    -- Skin damage
    if amount > self.IMPACT_SKIN_DAMAGE_THRESHOLD then
        self:ApplySkinDamage(amount * self.IMPACT_SKIN_DAMAGE_MULTIPLIER)
    end

    -- Propagated impact shouldn't cause anything else
    if isPropagatedImpact then
        return
    end

    -- Knockouts
    if self.LimbName == "Head" and amount > self.UNCONSCIOUS_IMPACT_THRESHOLD and Rage.Libs.Math:Random(1, self.UNCONSCIOUS_RNG) == 1 then
        local seconds = Rage.Libs.Math:Lerp(
            self.UNCONSCIOUS_MIN_TIME,
            self.UNCONSCIOUS_MAX_TIME,
            math.clamp((amount - self.UNCONSCIOUS_IMPACT_THRESHOLD) / self.UNCONSCIOUS_IMPACT_THRESHOLD, 0, 1)
        )

        self:SetUnconsciousFor(seconds)
    end

    -- SFX
    self:PlayImpactSound(amount)

    if amount > self.GRUNT_IMPACT_THRESHOLD then
        self:Grunt()
    end

    -- VFX
    Effects:SpawnEffect(Rage.Libs.Table:GetRandom(self.ImpactEffects), 0.07, self.ObjectPart.Part)
end

--[[
    Handles limb stabilization. Call in `:Update()`.
]]
function Limb:HandleStabilization()
    self.StabilizationForce.MaxTorque = self:GetStabilizationForceMaxTorque()
    self.StabilizationForce.Responsiveness = self:GetStabilizationForceResponsiveness()
    self.StabilizationForce.CFrame = self:GetStabilizationForceCFrame()
    self.StabilizationForce.Enabled = self:IsAlive() and self:IsAwake()
end

--[[
    Handles limb bleeding. Call in `:Update()`.
]]
function Limb:HandleBleeding()
    if self.Bleeding <= 0 then
        self.BleedingEffect.Enabled = false
        self.BleedingSound.Playing = false
        return
    end

    self:Damage(self.BLEEDING_HEALTH_LOSS_RATE * self.Bleeding)
    self.BleedingEffect.Rate = self.BleedingEffectDefaultRate * self.Bleeding
    self.BleedingEffect.Enabled = true

    self.BleedingSound.Volume = self.BLEEDING_SOUND_VOLUME * self.Bleeding
    self.BleedingSound.Playing = true
end

--[[
    Handles UI (health, etc). Call in `:Update()`.
]]
function Limb:HandleUI()
    -- Status icon
    if self.LimbName == "Head" then
        if self:IsAlive() then
            if self:IsAwake() then
                self:SetStatusIcon(RbxAssets.HUMAN_ALIVE_STATUS_ICON)
            else
                self:SetStatusIcon(RbxAssets.HUMAN_UNCONSCIOUS_STATUS_ICON)
            end
        else
            self:SetStatusIcon(RbxAssets.HUMAN_DEAD_STATUS_ICON)
        end
    end

    -- Health bar
    self.HealthContainer.BackgroundColor3 = Color3.fromRGB(
        math.floor((self.MaxHealth - self.Health) / self.MaxHealth * 255),
        math.floor(self:GetHealthPercentage() * 255),
        0
    )

    self.HealthContainer.Size = UDim2.fromScale(self:GetHealthPercentage(), 0.3)
end

--[[
    Handle consciousness.
]]
function Limb:HandleConsciousness()
    if not self:IsAwake() and os.clock() >= self.UnconsciousTil then
        self:WakeUp()
    end
end

--[[
    Handles limb state. Call in `:Update()`.
]]
function Limb:HandleState()
    self.IsGrounded = self:DetectIsGrounded()
    self.IsLimbAlive = self.Health > 0
    self.IsBrainAlive = self:FindLimbByName("Head").IsLimbAlive
    self.IsHeartBeating = self:FindLimbByName("UpperTorso").IsLimbAlive
    self.IsUnconscious = self:FindLimbByName("Head").IsUnconscious
    self.UnconsciousTil = self:FindLimbByName("Head").UnconsciousTil

    if not self.IsBrainAlive then
        if self.PlayedDeathScream then
            return
        end

        self:DeathScream()
    else
        self.PlayedDeathScream = false
    end
end

--[[
    Handles damage visuals. Call in `:Update()`.
]]
function Limb:HandleDamageVisuals()
    -- Bruising decal
    self.BruiseDecal.Transparency = Rage.Libs.Math:Lerp(
        self.BRUISE_DECAL_TRANSPARENCY_RANGE.Max,
        self.BRUISE_DECAL_TRANSPARENCY_RANGE.Min,
        self.Bruising
    )

    -- Skin damage decals
    local globalOffset = self.SkinDamage / 2 -- so all decals are used even with minor damage
    local step = 1 / self.SkinDamageDecalCount

    for index = 1, self.SkinDamageDecalCount do
        local decal = self:GetSkinDamageDecal(index)
        local startBound = (index - 1) * step
        local endBound = index * step

        local progress = math.clamp((self.SkinDamage - startBound) / (endBound - startBound), 0, 1)
        decal.Transparency = Rage.Libs.Math:Lerp(self.SKIN_DAMAGE_DECAL_TRANSPARENCY_RANGE.Max, self.SKIN_DAMAGE_DECAL_TRANSPARENCY_RANGE.Min, math.clamp(progress + globalOffset, 0, 1))
    end

    -- Flesh
    self.FleshDecal.Transparency = Rage.Libs.Math:Lerp(
        self.FLESH_DECAL_TRANSPARENCY_RANGE.Max,
        self.FLESH_DECAL_TRANSPARENCY_RANGE.Min,
        self.SkinDamage
    )

    -- Bone
    self.BoneDecal.Transparency = Rage.Libs.Math:Lerp(
        self.BONE_DECAL_TRANSPARENCY_RANGE.Max,
        self.BONE_DECAL_TRANSPARENCY_RANGE.Min,
        math.clamp(self.SkinDamage * self.BONE_FROM_SKIN_DAMAGE_MULTIPLIER, 0, 1)
    )
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

    local connectedTo = self.ObjectPart.Part:FindFirstChild("ConnectedTo") or Rage.Logging:Error(self.LimbName..": Missing `ConnectedTo` ObjectValue.") :: ObjectValue

    if not connectedTo.Value or not connectedTo.Value:IsA("BasePart") then
        Rage.Logging:Error(self.LimbName..": `ConnectedTo` value is not a part.")
    end

    local connectedObjectPart = Objects:GetObjectPartFromPart(connectedTo.Value) or Rage.Logging:Error(self.LimbName..": `ConnectedTo` value is not recognized as an object part.")
    self.ConnectedLimb = self.Limbs[connectedObjectPart] or Rage.Logging:Error(self.LimbName..": `ConnectedTo` value is not recognized as a limb.")

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
    self.FleshDecal = self.ObjectPart.Part:FindFirstChild("Flesh") or Rage.Logging:Error(self.LimbName..": Missing `Flesh` decal.") :: Decal
    self.BoneDecal = self.ObjectPart.Part:FindFirstChild("Bone") or Rage.Logging:Error(self.LimbName..": Missing `Bone` decal.") :: Decal

    self:TrackImpacts()
    self:CreateStatusIcon() -- head only. the method checks this though
end

--[[
    Updates this limb.
]]
function Limb:Update()
    self:HandleDamageVisuals()
    self:HandleConsciousness()
    self:HandleState()
    self:HandleUI()
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

export type Limb = typeof(Limb) & {
    GRUNT_IMPACT_THRESHOLD: number,
    GRUNT_COOLDOWN: number,

    UNCONSCIOUS_MAX_TIME: number,
    UNCONSCIOUS_MIN_TIME: number,
    UNCONSCIOUS_IMPACT_THRESHOLD: number,
    UNCONSCIOUS_RNG: number,
    UNCONSCIOUS_IMPACT_TIME_MULTIPLIER: number,

    IMPACT_MAX_PROPAGATIONS: number,
    IMPACT_PROPAGATION_MULTIPLIER: number,
    IMPACT_THRESHOLD: number,
    IMPACT_COOLDOWN: number,
    IMPACT_DAMAGE_MULTIPLIER: number,
    IMPACT_MASS_MULTIPLIER: number,

    BRUISE_DECAL_TRANSPARENCY_RANGE: NumberRange,
    IMPACT_BRUISING_THRESHOLD: number,
    IMPACT_BRUISING_MULTIPLIER: number,

    SKIN_DAMAGE_DECAL_TRANSPARENCY_RANGE: NumberRange,
    FLESH_DECAL_TRANSPARENCY_RANGE: NumberRange,
    BONE_DECAL_TRANSPARENCY_RANGE: NumberRange,
    BONE_FROM_SKIN_DAMAGE_MULTIPLIER: number,
    IMPACT_SKIN_DAMAGE_THRESHOLD: number,
    IMPACT_SKIN_DAMAGE_MULTIPLIER: number,

    GORY_IMPACT_SOUND_SKIN_DAMAGE_THRESHOLD: number,
    GORY_IMPACT_SOUND_THRESHOLD: number,

    BLEEDING_SOUND_VOLUME: number,
    BLEEDING_IMPACT_THRESHOLD: number,
    BLEEDING_IMPACT_HEALTH_THRESHOLD: number,
    BLEEDING_IMPACT_MULTIPLIER: number,
    BLEEDING_HEALTH_LOSS_RATE: number,

    BRAIN_DEAD_HEALTH_LOSS_RATE: number,
    HEART_DEAD_HEALTH_LOSS_RATE: number,

    UNGROUNDED_STABILIZATION_MULTIPLIER: number,
    UNGROUNDED_STABILIZATION_TARGET_RANDOMNESS: NumberRange,

    LimbName: string,
    ObjectPart: ObjectTypes.ObjectPart,
    Health: number,
    MaxHealth: number,
    SkinDamageDecalCount: number,
    Limbs: {[ObjectTypes.ObjectPart]: Limb},
    _LimbCache: {string: Limb},
    ConnectedLimb: Limb,

    BillboardGUI: BillboardGui,
    HealthContainer: Frame,

    LastGrunt: number,
    LastImpact: number,

    Bruising: number,
    Bleeding: number,
    SkinDamage: number,
    IsLimbAlive: boolean,
    Grounded: boolean,
    IsUnconscious: boolean,
    UnconsciousTil: number,
    IsBrainAlive: boolean,
    IsHeartBeating: boolean,
    PlayedDeathScream: boolean,

    StatusBillboardGUI: BillboardGui,
    StatusIcon: ImageLabel,

    StabilizationForce: AlignOrientation,
    Attachment: Attachment,
    MaxStabilizationAngularVelocity: number,
    MaxStabilizationTorque: number,

    BleedingSound: Sound,
    GoryImpactSounds: SoundCollection.SoundCollection,
    ImpactSounds: SoundCollection.SoundCollection,
    ImpactEffects: {string},
    GruntSounds: SoundCollection.SoundCollection,
    DeathSounds: SoundCollection.SoundCollection,
    BleedingEffect: ParticleEmitter,
    BleedingEffectDefaultRate: number,
    BruiseDecal: Decal,
    FleshDecal: Decal,
    BoneDecal: Decal,

    TouchConnection: RBXScriptConnection
}

return Limb