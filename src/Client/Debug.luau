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
local Organization = require(Rage.Path.Organization)

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
Debug.DEBUG_TEXT_EXPIRATION_TIME = 5
Debug.DEBUG_TEXT_COLOR = Color3.fromRGB(175, 255, 175)
Debug.DEBUG_TEXT_BG_COLOR = Color3.fromRGB(25, 25, 25)
Debug.DEBUG_TEXT_BG_TRANSPARENCY = 0.8

Debug.DebugFolder = Organization:CreateFolder("Debug", Rage.Workspace)
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
function Debug:CreateDebugPart(position: Rage.PositionType, size: Vector3?, noCleanup: boolean?): Part
    if not self.DebugEnabled then
        return
    end

    local part = Instance.new("Part")
    part.Name = "Debug"
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Anchored = true
    part.Size = size or self.DEBUG_PART_SIZE
    part.CFrame = Rage.Libs.Position:ToCFrame(position)
    part.Material = Enum.Material.ForceField
    part.Transparency = self.DEBUG_PART_TRANSPARENCY
    part.Color = self.DEBUG_PART_COLOR

    part.Parent = self.DebugFolder

    if not noCleanup then
        Rage.Debris:AddItem(part, self.DEBUG_PART_EXPIRATION_TIME)
    end

    return part
end

--[[
    Creates a debug text at the provided position.
]]
function Debug:CreateDebugText(position: Rage.PositionType, text: string)
    if not self.DebugEnabled then
        return
    end

    local part = self:CreateDebugPart(position, nil, true)
    part.Transparency = 1

    local billboardGUI = Instance.new("BillboardGui")
    billboardGUI.Name = "DebugText"
    billboardGUI.Size = UDim2.fromScale(10, 2)
    billboardGUI.Adornee = part
    billboardGUI.AlwaysOnTop = true
    billboardGUI.LightInfluence = 0
    billboardGUI.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "DebugText"
    textLabel.Text = text
    textLabel.TextColor3 = self.DEBUG_TEXT_COLOR
    textLabel.BackgroundColor3 = self.DEBUG_TEXT_BG_COLOR
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = self.DEBUG_TEXT_BG_TRANSPARENCY
    textLabel.Parent = billboardGUI

    Rage.Debris:AddItem(part, self.DEBUG_TEXT_EXPIRATION_TIME)
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

export type Debug = Rage.Service & typeof(Debug)
return Debug