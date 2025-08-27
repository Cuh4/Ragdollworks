--------------------------------------------------------
-- [Ragdollworks] Menu
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

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a UI menu.
]]
Menu = {} :: Menu
Menu.__index = Menu

--[[
    Creates a new menu class instance.
]]
function Menu.New(name: string): Menu
    local self = setmetatable({}, Menu) :: Menu
    self.Name = name
    self.ScreenGUI = Rage.Player.PlayerGui:WaitForChild(name, 10) or Rage.Logging:Error("Menu:New(): Could not find screen GUI of name '"..name.."'.")
    self.Visible = false

    return self
end

--[[
    Setups the menu.
]]
function Menu:Setup()
    Rage.Logging:Error(self.Name..": Setup not implemented!")
end

--[[
    Shows the menu.
]]
function Menu:Show()
    self.Visible = true
    self:Update()
end

--[[
    Hides the menu.
]]
function Menu:Hide()
    self.Visible = false
    self:Update()
end

--[[
    Updates the screen GUI.
]]
function Menu:Update()
    self.ScreenGUI.Enabled = self.Visible
end

export type Menu = {
    Name: string,
    ScreenGUI: ScreenGui,
    Visible: boolean
} & typeof(Menu)

return Menu