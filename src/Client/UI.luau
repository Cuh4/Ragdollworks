--------------------------------------------------------
-- [Ragdollworks] UI
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
    A mini-service for UI.
]]
UI = Rage:Service("UI"):: UI
UI.COMPONENTS_FOLDER = Rage.Assets:GetAsset("UIComponents") :: Folder
UI.PLAYER_GUI = Rage.Player.PlayerGui

--[[
    Returns a screen GUI by name.
]]
function UI:GetScreenGUI(name: string): ScreenGui
    return self.PLAYER_GUI:WaitForChild(name) or Rage.Logging:Error("UI:GetScreenGUI(): Screen '"..name.."' does not exist.")
end

--[[
    Returns a component by name.
]]
function UI:GetComponent(name: string): Frame
    return self.COMPONENTS_FOLDER:WaitForChild(name) or Rage.Logging:Error("UI:GetComponent(): Component '"..name.."' does not exist.")
end

export type UI = typeof(UI)
return UI