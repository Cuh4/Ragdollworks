--------------------------------------------------------
-- [Ragdollworks] UI
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Source-Available No-Redistribution License
        Copyright (c) 2025 Cuh4. All rights reserved.

        IMPORTANT: This source code is NOT Open Source.

        1. PERMISSIONS (Limited):
        * View and read the source code.
        * Modify for private, non-public use only.
        * Contributions back to the project are permitted.

        2. PROHIBITIONS (Strict):
        * You MAY NOT copy, redistribute, publish, or share the code (modified or unmodified).
        * You MAY NOT use this code in ANY public or commercial project or service.

        Any violation automatically terminates your rights.
        Provided "AS IS" without warranty.
        Full terms governed by the laws of England and Wales.

        For the full license, see the `LICENSE` file provided with the source code.

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
UI = Rage:Service("UI") :: UI
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
function UI:GetComponent(name: string): GuiObject
    return self.COMPONENTS_FOLDER:WaitForChild(name) or Rage.Logging:Error("UI:GetComponent(): Component '"..name.."' does not exist.")
end

export type UI = Rage.Service & typeof(UI)
return UI