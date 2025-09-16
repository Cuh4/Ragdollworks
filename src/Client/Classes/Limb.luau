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
function Limb.New(name: string, objectPart: ObjectTypes.ObjectPart, maxHealth: number, maxStabilizationAngularVelocity: number, maxStabilizationTorque: number, bloodDecalCount: number): Limb
    local self = setmetatable({}, Limb) :: Limb
    self.GRUNT_IMPACT_THRESHOLD = 12
    self.GRUNT_COOLDOWN = 0.3

    self.UNCONSCIOUS_MAX_TIME = 80 -- seconds
    self.UNCONSCIOUS_MIN_TIME = 5 -- seconds
    self.UNCONSCIOUS_IMPACT_THRESHOLD = 38
    self.UNCONSCIOUS_IMPACT_TIME_MULTIPLIER = 1.1

    self.IMPACT_MAX_PROPAGATIONS = 4
    self.IMPACT_PROPAGATION_MULTIPLIER = 0.4
    self.IMPACT_THRESHOLD = 12
    self.IMPACT_COOLDOWN = 0.1
    self.IMPACT_DAMAGE_MULTIPLIER = 1.3
    self.IMPACT_MASS_MULTIPLIER = 0.25

    self.BRUISE_DECAL_MIN_TRANSPARENCY = 0.55
    self.IMPACT_BRUISING_THRESHOLD = 16
    self.IMPACT_BRUISING_MULTIPLIER = 0.0095

    self.BLOOD_DECAL_MIN_TRANSPARENCY = 0.25
    self.IMPACT_SKIN_DAMAGE_THRESHOLD = 14
    self.IMPACT_SKIN_DAMAGE_MULTIPLIER = 0.023

    self.GORY_IMPACT_SOUND_THRESHOLD = 45

    self.BLEEDING_SOUND_VOLUME = 0.7
    self.BLEEDING_IMPACT_THRESHOLD = 50
    self.BLEEDING_IMPACT_HEALTH_THRESHOLD = 0.6 -- % of health needed until impacts can cause bleeding
    self.BLEEDING_IMPACT_MULTIPLIER = 0.001
    self.BLEEDING_HEALTH_LOSS_RATE = 0.012 -- per update (* 60 for a rough per-second estimate)

    self.BRAIN_DEAD_HEALTH_LOSS_RATE = 0.35 -- per update
    self.HEART_DEAD_HEALTH_LOSS_RATE = 0.1 -- per update

    self.UNGROUNDED_STABILIZATION_MULTIPLIER = 0.02
    self.UNGROUNDED_STABILIZATION_MATCH_ANGLE_OFFSET = -6 -- degrees

    self.LimbName = name
    self.ObjectPart = objectPart
    self.Health = maxHealth
    self.MaxHealth = maxHealth
    self.BloodDecalCount = bloodDecalCount
    self.Limbs = {}
    self._LimbCache = {}
    self.ClosestLimb = nil

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

    self.StabilizationForce = nil :: AlignOrientation
    self.Attachment = nil :: Attachment
    self.MaxStabilizationAngularVelocity = maxStabilizationAngularVelocity
    self.MaxStabilizationTorque = maxStabilizationTorque

    local bleedingSound = Sounds:CreateSound(RbxAssets.BLEEDING_SOUND,{
        Looped = true
    }) :: Sound.RSound

    self.BleedingSound = bleedingSound:Play({}, self.ObjectPart.Part)

    self.GoryImpactSounds = Sounds:CreateSoundCollection(
        Sounds:CreateSound(RbxAssets.HUMAN_HEAVY_GORY_IMPACT_1, {Volume = 0.25}),
        Sounds:CreateSound(RbxAssets.HUMAN_HEAVY_GORY_IMPACT_2, {Volume = 0.27}),
        Sounds:CreateSound(RbxAssets.HUMAN_HEAVY_GORY_IMPACT_3, {Volume = 0.24})
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

    local _, _, rotationZ = self.ClosestLimb and self.ClosestLimb.ObjectPart.Part.CFrame:ToEulerAnglesXYZ() or 0, 0, 0
    return CFrame.Angles(0, 0, rotationZ + math.rad(self.UNGROUNDED_STABILIZATION_MATCH_ANGLE_OFFSET))
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
    self.ImpactSounds:PlayRandom({
        Sounds:CreateSoundModifier("PitchShiftSoundEffect", {
            Octave = math.clamp(1 - (impactAmount / 175), 0.75, 1)
        })
    }, self.ObjectPart.Part)

    if impactAmount >= self.GORY_IMPACT_SOUND_THRESHOLD then
        self.GoryImpactSounds:PlayRandom({}, self.ObjectPart.Part)
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

        local relativeVelocity = self.ObjectPart:GetVelocity3D() - part.AssemblyLinearVelocity :: Vector3
        local relativePosition = self.ObjectPart:GetPosition3D() - part.Position :: Vector3

        if relativePosition:Dot(relativeVelocity) > 0 then
            return -- the parts are moving away from each other
        end

        local mass = part.Anchored and 1 or part.Mass

        if relativeVelocity.Magnitude >= self.IMPACT_THRESHOLD then
            local impactAmount = (relativeVelocity.Magnitude - self.IMPACT_THRESHOLD) + (mass * self.IMPACT_MASS_MULTIPLIER)
            self:HandleImpact(impactAmount)
        end
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
    if not self.IsUnconscious then
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
    if self.IsUnconscious then
        self.UnconsciousTil = math.clamp(self.UnconsciousTil + seconds, self.UNCONSCIOUS_MIN_TIME, self.UNCONSCIOUS_MAX_TIME)
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
    Returns a random blood decal.
]]
function Limb:GetRandomBloodDecal(): (Decal, number)
    local index = Rage.Libs.Math:Random(1, self.BloodDecalCount)
    return self:GetBloodDecal(index), index
end

--[[
    Heals the limb.
]]
function Limb:Heal()
    self.Health = self.MaxHealth
    self:RemoveBleeding()
    self:RemoveBruising()
    self:RemoveSkinDamage()
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
function Limb:HandleImpact(amount: number, _propagations: number?)
    -- Log
    Rage.Logging:Info(self.LimbName..": Impact, amount: "..amount)

    -- Propagate impact across body
    if self.ClosestLimb and (_propagations and _propagations < self.IMPACT_MAX_PROPAGATIONS) then
        self.ClosestLimb:HandleImpact(amount * (self.IMPACT_PROPAGATION_MULTIPLIER / _propagations), _propagations + 1)
    end

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

    -- Knockouts
    if amount > self.UNCONSCIOUS_IMPACT_THRESHOLD then
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
    self.BruiseDecal.Transparency = Rage.Libs.Math:Lerp(1, self.BRUISE_DECAL_MIN_TRANSPARENCY, self.Bruising)

    -- Blood decals
    local globalOffset = self.SkinDamage / 2 -- so all decals are used even with minor damage
    local step = 1 / self.BloodDecalCount

    for index = 1, self.BloodDecalCount do
        local decal = self:GetBloodDecal(index)
        local startBound = (index - 1) * step
        local endBound = index * step

        local progress = math.clamp((self.SkinDamage - startBound) / (endBound - startBound), 0, 1)
        decal.Transparency = Rage.Libs.Math:Lerp(1, self.BLOOD_DECAL_MIN_TRANSPARENCY, math.clamp(progress + globalOffset, 0, 1))
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
    self.ClosestLimb = self:GetClosestLimb()

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
    self:HandleConsciousness()
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

export type Limb = typeof(Limb) & {
    GRUNT_IMPACT_THRESHOLD: number,
    GRUNT_COOLDOWN: number,

    UNCONSCIOUS_MAX_TIME: number,
    UNCONSCIOUS_MIN_TIME: number,
    UNCONSCIOUS_IMPACT_THRESHOLD: number,
    UNCONSCIOUS_IMPACT_TIME_MULTIPLIER: number,

    IMPACT_MAX_PROPAGATIONS: number,
    IMPACT_PROPAGATION_MULTIPLIER: number,
    IMPACT_THRESHOLD: number,
    IMPACT_COOLDOWN: number,
    IMPACT_DAMAGE_MULTIPLIER: number,
    IMPACT_MASS_MULTIPLIER: number,

    BRUISE_DECAL_MIN_TRANSPARENCY: number,
    IMPACT_BRUISING_THRESHOLD: number,
    IMPACT_BRUISING_MULTIPLIER: number,

    BLOOD_DECAL_MIN_TRANSPARENCY: number,
    IMPACT_SKIN_DAMAGE_THRESHOLD: number,
    IMPACT_SKIN_DAMAGE_MULTIPLIER: number,

    GORY_IMPACT_SOUND_THRESHOLD: number,

    BLEEDING_SOUND_VOLUME: number,
    BLEEDING_IMPACT_THRESHOLD: number,
    BLEEDING_IMPACT_HEALTH_THRESHOLD: number,
    BLEEDING_IMPACT_MULTIPLIER: number,
    BLEEDING_HEALTH_LOSS_RATE: number,

    BRAIN_DEAD_HEALTH_LOSS_RATE: number,
    HEART_DEAD_HEALTH_LOSS_RATE: number,

    UNGROUNDED_STABILIZATION_MULTIPLIER: number,
    UNGROUNDED_STABILIZATION_MATCH_ANGLE_OFFSET: number,

    LimbName: string,
    ObjectPart: ObjectTypes.ObjectPart,
    Health: number,
    MaxHealth: number,
    BloodDecalCount: number,
    Limbs: {[ObjectTypes.ObjectPart]: Limb},
    _LimbCache: {string: Limb},
    ClosestLimb: Limb,

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

    TouchConnection: RBXScriptConnection
}

return Limb