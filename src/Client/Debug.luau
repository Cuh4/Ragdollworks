--------------------------------------------------------
-- [Ragdollworks] CLI
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

-------------------------------
-- // Main
-------------------------------

--[[
    A service for debuggng utilities.
]]
Debug = Rage:Service("Debug") :: Debug
Debug.DEBUG_PART_EXPIRATION_TIME = 2
Debug.DEBUG_PART_TRANSPARENCY = 0.8
Debug.DEBUG_PART_SIZE = Vector3.new(4, 4, 4)
Debug.DEBUG_PART_COLOR = Color3.fromRGB(0, 255, 0)
Debug.RAYCAST_HIT_COLOR = Color3.fromRGB(0, 0, 255)
Debug.RAYCAST_MISS_COLOR = Color3.fromRGB(255, 0, 0)
Debug.RAYCAST_VISUALIZATION_WIDTH = 0.01

Debug.DebugEnabled = false

--[[
    Called when the service starts.
]]
function Debug:OnStart()
    self:_CreateCommands()
end

--[[
    Creates a debug part at the provided position. Can be handy for visualising where a ray hits.
]]
function Debug:CreateDebugPart(partCFrame: CFrame, size: Vector3?): Part
    if not self.DebugEnabled then
        return
    end

    local part = Instance.new("Part")
    part.Name = "Debug"
    part.CanCollide = false
    part.CanQuery = false
    part.Anchored = true
    part.Size = size or self.DEBUG_PART_SIZE
    part.CFrame = partCFrame
    part.Material = Enum.Material.ForceField
    part.Transparency = self.DEBUG_PART_TRANSPARENCY
    part.Color = self.DEBUG_PART_COLOR

    part.Parent = Rage.Workspace

    Rage.Debris:AddItem(part, self.DEBUG_PART_EXPIRATION_TIME)

    return part
end

--[[
    Visualises a raycast.
]]
function Debug:VisualizeRaycast(origin: Vector3, direction: Vector3, result: RaycastResult?): Part
    if not self.DebugEnabled then
        return
    end

    local part = self:CreateDebugPart(
        CFrame.new(origin, origin + direction),
        Vector3.new(self.RAYCAST_VISUALIZATION_WIDTH, self.RAYCAST_VISUALIZATION_WIDTH, direction.Magnitude)
    )

    part.Color = result and self.RAYCAST_HIT_COLOR or self.RAYCAST_MISS_COLOR

    return part
end

--[[
    Sets whether or not debug is enabled.
]]
function Debug:SetDebug(state: boolean)
    self.DebugEnabled = state
    Rage.Logging:Info("Debug:SetDebug(): Set debug to "..tostring(state))
end

--[[
    Creates CLI commands.
]]
function Debug:_CreateCommands()
    CLI.Conch.register("debug", {
        description = "Sets debug mode.",

        arguments = function()
            return CLI.Conch.args.boolean("State", "Whether to enable debug or not.")
        end,

        callback = function(state: boolean)
            self:SetDebug(state)
        end
    })
end

export type Debug = typeof(Debug)
return Debug