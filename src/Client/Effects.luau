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

-------------------------------
-- // Main
-------------------------------

--[[
    A service for spawning particle effects.
]]
Effects = Rage:Service("Effects") :: Effects
Effects.EFFECTS_FOLDER = Rage.Assets:GetAsset("Effects") :: Folder

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
function Effects:SpawnEffect(name: string, lifetime: number, parent: Instance?, position: Vector3?): ParticleEmitter
    if parent and position then
        Rage.Logging:Error("Effects:SpawnEffect(): Both 'parent' and 'position' cannot be provided. Choose one or the other.")
    end

    if not parent and not position then
        Rage.Logging:Error("Effects:SpawnEffect(): Either 'parent' or 'position' must be provided.")
    end

    local effect = self:GetEffect(name):Clone()

    if not parent then
        parent = Instance.new("Part")
        parent.CanCollide = false
        parent.CanQuery = false
        parent.Anchored = true
        parent.Size = Vector3.new(1, 1, 1)
        parent.Position = position
        parent.Transparency = 1
        parent.Parent = game.Workspace

        effect.Destroying:Once(function()
            parent:Destroy()
        end)
    end

    effect.Enabled = true
    effect.Parent = parent

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

export type Effects = typeof(Effects)
return Effects