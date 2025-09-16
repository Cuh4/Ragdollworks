--------------------------------------------------------
-- [Ragdollworks] Effects
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

local CLI = require(Rage.Path.CLI)
local Camera = require(Rage.Path.Camera)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for spawning particle effects.
]]
Effects = Rage:Service("Effects") :: Effects
Effects.EFFECTS_FOLDER = Rage.Assets:GetAsset("Effects") :: Folder

--[[
    Called when this service starts.
]]
function Effects:OnStart()
    self:_CreateCommands()
end

--[[
    Returns a particle effect of the given name.
]]
function Effects:GetEffect(name: string): ParticleEmitter
    return self.EFFECTS_FOLDER:FindFirstChild(name) or Rage.Logging:Error("Effects:GetEffect(): Particle effect '"..name.."' not found.")
end

--[[
    Spawns a particle effect of the given name.
    Use -1 lifetime for infinite lifetime.
]]
function Effects:SpawnEffect(name: string, lifetime: number, parent: Instance?, position: Vector2?, properties: ParticleProperties?): ParticleEmitter
    if parent and position then
        Rage.Logging:Error("Effects:SpawnEffect(): Both 'parent' and 'position' cannot be provided. Choose one or the other.")
    end

    if not parent and not position then
        Rage.Logging:Error("Effects:SpawnEffect(): Either 'parent' or 'position' must be provided.")
    end

    local effect = self:GetEffect(name):Clone()

    if properties then
        for index, value in pairs(properties) do
            effect[index] = value
        end
    end

    if not parent then
        parent = Instance.new("Part")
        parent.CanCollide = false
        parent.CanQuery = false
        parent.Anchored = true
        parent.Size = Vector3.new(1, 1, 1)
        parent.Position = Vector3.new(position.X, position.Y, 0)
        parent.Transparency = 1
        parent.Parent = Rage.Workspace

        effect.Destroying:Once(function()
            parent:Destroy()
        end)
    end

    effect.Enabled = true
    effect.Parent = parent

    Rage.Logging:Info(("Effects:SpawnEffect(): Spawned effect %s for %.2f seconds."):format(name, lifetime))

    if lifetime == -1 then
        return effect
    end

    -- Lifetime logic
    Rage.Debris:AddItem(effect, (lifetime + effect.Lifetime.Max) * 2)

    task.spawn(function()
        task.wait(lifetime)
        effect.Enabled = false
    end)

    return effect
end

--[[
    Creates CLI commands.
]]
function Effects:_CreateCommands()
    CLI.Conch.register("effect", {
        description = "Spawns a particle effect.",

        arguments = function()
            return CLI.Conch.args.string("Name", "The name of the effect."),
                CLI.Conch.args.number("Lifetime", "The lifetime in secs, -1 for infinte"),
                CLI.Conch.args.number("Size", "The size of the effect.")
        end,

        callback = function(name: string, lifetime: number, size: number)
            self:SpawnEffect(name, lifetime, nil, Camera.MouseWorldPosition, {
                Size = NumberSequence.new(size)
            })
        end
    })
end

export type ParticleProperties = {
    Brightness: number,
    Color: Color3,
    LightEmission: number,
    LightInfluence: number,
    Orientation: Enum.ParticleOrientation,
    Size: NumberSequence,
    Squash: NumberSequence,
    Texture: string,
    Transparency: NumberSequence,
    ZOffset: number,

    EmissionDirection: Enum.NormalId,
    Lifetime: NumberRange,
    Rate: number,
    Rotation: NumberRange,
    RotSpeed: NumberRange,
    Speed: NumberRange,
    SpreadAngle: NumberRange,

    Shape: Enum.ParticleEmitterShape,
    ShapeInOut: Enum.ParticleEmitterShapeInOut,
    ShapePartial: number,
    ShapeStyle: Enum.ParticleEmitterShapeStyle,

    FlipbookLayout: Enum.ParticleFlipbookLayout,
    FlipbookMode: Enum.ParticleFlipbookMode,
    FlipbookStartRandom: boolean,

    Acceleration: Vector3,

    Drag: number,
    LockedToPart: boolean,
    TimeScale: number,
    VelocityInheritance: number,
    WindAffectsDrag: number
}

export type Effects = Rage.Service & typeof(Effects)
return Effects