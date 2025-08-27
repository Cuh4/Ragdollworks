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
function Debug:CreateDebugPart(position: Vector3)
    if not self.DebugEnabled then
        return
    end

    local part = Instance.new("Part")
    part.Name = "Debug"
    part.CanCollide = false
    part.CanQuery = false
    part.Anchored = true
    part.Size = Vector3.new(4, 4, 4)
    part.Position = position
    part.Material = Enum.Material.ForceField
    part.Transparency = 0.5
    part.Color = Color3.fromRGB(0, 255, 0)

    part.Parent = game.Workspace

    Rage.Debris:AddItem(part, self.DEBUG_PART_EXPIRATION_TIME)
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