--------------------------------------------------------
-- [Ragdollworks] Explosive
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
local Organization = require(Rage.Path.Organization)
local Effects = require(Rage.Path.Effects)

local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Sound = require(Rage.Path.Classes.Sound)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing an explosive (tied to a spawned object).
]]
Explosive = {} :: Explosive
Explosive.__index = Explosive
Explosive._ExplosionsFolder = Organization:CreateFolder("Explosions", Rage.Workspace)

--[[
    Creates a new Explosive class instance.
]]
function Explosive.New(part: ObjectTypes.ObjectPart): Explosive
    local self = setmetatable({}, Explosive) :: Explosive
    self.SpawnedObject = part.SpawnedObject
    self.Part = part
    self.Instance = self.SpawnedObject.Instance

    self.ExplosionRadius = self.SpawnedObject.Instance:GetAttribute("ExplosionRadius") or 10
    self.ExplosionPressure = self.SpawnedObject.Instance:GetAttribute("ExplosionPressure") or 50000
    self.ExplosionCollisionThreshold = self.SpawnedObject.Instance:GetAttribute("ExplosionCollisionThreshold") or 50
    self.ExplodeOnActivation = self.SpawnedObject.Instance:GetAttribute("ExplodeOnActivation") or false

    self.SoundAssetID = self.SpawnedObject.Instance:GetAttribute("ExplosionSoundAssetID") or Rage.Logging:Error(self.SpawnedObject.Instance:GetFullName()..": No explosion sound asset ID provided.")

    self.Sound = Sounds:CreateSound(self.SoundAssetID, {
        Volume = self.SpawnedObject.Instance:GetAttribute("ExplosionSoundVolume") or Rage.Logging:Error(self.SpawnedObject.Instance:GetFullName()..": No explosion sound volume provided."),
        RollOffMinDistance = self.ExplosionRadius * 0.8
    })

    self.Exploded = false

    self.OnExplode = signal.new()
    self.OnCleanup = signal.new()

    self:Setup()

    return self
end

--[[
    Setups the explosive.
]]
function Explosive:Setup()
    self:DetectCollision()
end

--[[
    Detects for collisions to trigger an explosion.
]]
function Explosive:DetectCollision()
    self.Part.OnCollision:Connect(function(context: ObjectTypes.ObjectPartCollisionContext)
        if context.ImpactAmount > self.ExplosionCollisionThreshold then
            self:Explode()
        end
    end)
end

--[[
    Explodes and despawns the part.
]]
function Explosive:Explode()
    if self.Exploded then
        return
    end

    local explosion = Instance.new("Explosion")
    explosion.BlastRadius = self.ExplosionRadius
    explosion.BlastPressure = self.ExplosionPressure
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.DestroyJointRadiusPercent = 0
    explosion.Position = self.Part:GetPosition3D()
    explosion.Visible = false
    explosion.Parent = self._ExplosionsFolder

    self.Exploded = true
    self.OnExplode:Fire()

    self.Sound:Play({}, self.Part:GetPosition())

    Effects:SpawnEffect(
        "Explosion",
        0.5,
        nil,
        self.Part:GetPosition(),

        {
            Size = NumberSequence.new(self.ExplosionRadius)
        }
    )

    self.Part:Despawn()
    self:Cleanup()
end

--[[
    Called on cleanup.
]]
function Explosive:Cleanup()
    self.Part = nil
    self.Instance = nil

    self.OnCleanup:Fire()
end

export type Explosive = typeof(Explosive) & {
    SpawnedObject: ObjectTypes.ObjectPart,
    Part: ObjectTypes.ObjectPart,
    Instance: Model,

    ExplosionRadius: number,
    ExplosionPressure: number,
    ExplosionCollisionThreshold: number,
    ExplodeOnActivation: boolean,

    SoundAssetID: string,
    Sound: Sound.RSound,

    Exploded: boolean,

    OnExplode: signal.Signal,
    OnCleanup: signal.Signal
}

return Explosive