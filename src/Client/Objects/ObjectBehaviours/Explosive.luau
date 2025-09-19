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
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local ObjectBehaviour = require(Rage.Path.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Sound = require(Rage.Path.Classes.Sound)

local Organization = require(Rage.Path.Organization)
local Sounds = require(Rage.Path.Sounds)
local Effects = require(Rage.Path.Effects)

-------------------------------
-- // Main
-------------------------------

--[[
    An object behaviour that allows objects to explode.
]]
ExplosiveObjectBehaviour = {} :: ExplosiveObjectBehaviour
ExplosiveObjectBehaviour.__index = ExplosiveObjectBehaviour
ExplosiveObjectBehaviour._ExplosionsFolder = Organization:CreateFolder("Explosions", Rage.Workspace)

setmetatable(ExplosiveObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new ExplosiveObjectBehaviour class instance.
]]
function ExplosiveObjectBehaviour.New(spawnedObject: ObjectTypes.SpawnedObject): ExplosiveObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(spawnedObject), ExplosiveObjectBehaviour) :: ExplosiveObjectBehaviour
    self.LastPosition = Vector2.new(0, 0)
    self.MainPart = table.pack(next(self.SpawnedObject.Parts))[2]
    self.ExplosionRadius = self.SpawnedObject.Instance:GetAttribute("ExplosionRadius") or 10
    self.ExplosionPressure = self.SpawnedObject.Instance:GetAttribute("ExplosionPressure") or 50000
    self.ExplosionPositionDeltaThreshold = self.SpawnedObject.Instance:GetAttribute("ExplosionPositionDeltaThreshold") or 10
    self.ExplodeOnActivation = self.SpawnedObject.Instance:GetAttribute("ExplodeOnActivation") or false

    local soundAssetID = self.SpawnedObject.Instance:GetAttribute("ExplosionSoundAssetID") or Rage.Logging:Error(self.SpawnedObject.Instance:GetFullName()..": No explosion sound asset ID provided.")

    self.Sound = Sounds:CreateSound(soundAssetID, {
        Volume = self.SpawnedObject.Instance:GetAttribute("ExplosionSoundVolume") or Rage.Logging:Error(self.SpawnedObject.Instance:GetFullName()..": No explosion sound volume provided."),
        RollOffMinDistance = self.ExplosionRadius * 0.8
    })

    return self
end

--[[
    Updates the last position.
]]
function ExplosiveObjectBehaviour:UpdateLastPosition()
    self.LastPosition = self:GetPosition()
end

--[[
    Returns the current position.
]]
function ExplosiveObjectBehaviour:GetPosition()
    return Vector2.new(self.MainPart.Part.Position.X, self.MainPart.Part.Position.Y)
end

--[[
    Returns the position delta.
]]
function ExplosiveObjectBehaviour:GetPositionDelta()
    return self:GetPosition() - self.LastPosition
end

--[[
    Returns whether or not the object passed the position delta threshold.
]]
function ExplosiveObjectBehaviour:HasPassedPositionDeltaThreshold(delta: Vector2)
    return delta.Magnitude > self.ExplosionPositionDeltaThreshold
end

--[[
    Explodes and despawns the part.
]]
function ExplosiveObjectBehaviour:Explode()
    local explosion = Instance.new("Explosion")
    explosion.BlastRadius = self.ExplosionRadius
    explosion.BlastPressure = self.ExplosionPressure
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.DestroyJointRadiusPercent = 0
    explosion.Position = self.MainPart:GetPosition3D()
    explosion.Visible = false
    explosion.Parent = self._ExplosionsFolder

    self.Sound:Play({}, self.MainPart:GetPosition())

    Effects:SpawnEffect(
        "Explosion",
        0.5,
        nil,
        self.MainPart:GetPosition(),

        {
            Size = NumberSequence.new(self.ExplosionRadius)
        }
    )

    self.MainPart:Despawn()
    self.MainPart = nil
end

--[[
    Called when an object using this behaviour is spawned.
]]
function ExplosiveObjectBehaviour:OnSpawn() end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function ExplosiveObjectBehaviour:OnPreDespawn() end

--[[
    Called when an object using this behaviour is activated.
]]
function ExplosiveObjectBehaviour:OnActivate(objectPart: ObjectTypes.ObjectPart)
    if not self.ExplodeOnActivation then
        return
    end

    if objectPart ~= self.MainPart then
        return
    end

    self:Explode()
end

--[[
    Called when an object using this behaviour is updated.
]]
function ExplosiveObjectBehaviour:OnUpdate()
    if not self.MainPart then
        return
    end

    if self:HasPassedPositionDeltaThreshold(self:GetPositionDelta()) and #self.MainPart.Part:GetTouchingParts() >= 1 then
        self:Explode()
        return
    end

    self:UpdateLastPosition()
end

export type ExplosiveObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(ExplosiveObjectBehaviour) & {
    _ExplosionsFolder: Folder,

    LastPosition: Vector2,
    MainPart: ObjectTypes.ObjectPart,
    ExplosionRadius: number,
    ExplosionPressure: number,
    PositionDeltaThreshold: number,
    ExplodeOnActivation: boolean,
    Sound: Sound.RSound
}

return ExplosiveObjectBehaviour