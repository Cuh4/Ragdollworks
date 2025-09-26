--------------------------------------------------------
-- [Ragdollworks] UI
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Copyright (C) 2025 Cuh4

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

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