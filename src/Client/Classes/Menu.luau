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
function Menu.New(
    name: string,
    scenes: {string},
    settings: {
        CanBeForceHidden: boolean
    }?
): Menu
    settings = settings or {}

    local self = setmetatable({}, Menu) :: Menu
    self.Name = name
    self.Scenes = scenes
    self.ScreenGUI = Rage.Player.PlayerGui:WaitForChild(name, 5) or Rage.Logging:Error("Menu:New(): Could not find screen GUI of name '"..name.."'.")
    self.Visible = false
    self.ForceHidden = false
    self.CanBeForceHidden = settings.CanBeForceHidden ~= nil and settings.CanBeForceHidden or true

    return self
end

--[[
    Setups the menu.<br>
    Optional abstractmethod.
]]
function Menu:OnSetup() end

--[[
    Updates the menu.<br>
    Optional abstractmethod.
]]
function Menu:OnUpdate() end

--[[
    Returns if this menu is allowed to show with the provided scene.
]]
function Menu:CanShowWithScene(scene: string): boolean
    if Rage.Libs.Table:Find(self.Scenes, "*") then
        return true
    end

    return Rage.Libs.Table:Find(self.Scenes, scene) ~= nil
end

--[[
    Sets menu visibility.
]]
function Menu:SetVisible(visible: boolean)
    if self.Visible == visible then
        return
    end

    self.Visible = visible
    self:Refresh()

    Rage.Logging:Info(self.Name.." (Menu): Set visible to "..tostring(visible))
end

--[[
    Shows the menu.
]]
function Menu:Show()
    self:SetVisible(true)
end

--[[
    Hides the menu.
]]
function Menu:Hide()
    self:SetVisible(false)
end

--[[
    Sets whether or not the menu is force hidden.
]]
function Menu:SetForceHidden(forceHide: boolean)
    if not self.CanBeForceHidden then
        return
    end

    if self.ForceHidden == forceHide then
        return
    end

    self.ForceHidden = forceHide
    self:Refresh()

    Rage.Logging:Info(self.Name.." (Menu): Set force hidden to "..tostring(forceHide))
end

--[[
    Forces the menu to be hidden.
]]
function Menu:ForceHide()
    self:SetForceHidden(true)
end

--[[
    Allows the menu to be visible/invisible.
]]
function Menu:UnforceHide()
    self:SetForceHidden(false)
end

--[[
    Returns if the menu is visible.
]]
function Menu:IsVisible(): boolean
    if self.ForceHidden then
        return false
    end

    return self.Visible
end

--[[
    Setups the menu.
]]
function Menu:Setup()
    self.ScreenGUI.ResetOnSpawn = false

    self:Hide()
    self:OnSetup()
end

--[[
    Updates the menu. To be called every frame.
]]
function Menu:Update()
    self:OnUpdate()
end

--[[
    Refreshes the menu.
]]
function Menu:Refresh()
    self.ScreenGUI.Enabled = self:IsVisible()
end

export type Menu = typeof(Menu) & {
    Name: string,
    Scenes: {string},
    ScreenGUI: ScreenGui,
    Visible: boolean,
    ForceHidden: boolean,
    CanBeForceHidden: boolean
}

return Menu