--------------------------------------------------------
-- [Ragdollworks] Main Menu
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

local Maps = require(Rage.Path.Maps)

local Menu = require(Rage.ReplicatedStorage.Classes.Menu)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    The main menu shown when you load in + when you exit a map.
]]
MainMenu = {} :: MainMenu
MainMenu.__index = MainMenu
setmetatable(MainMenu, Menu)

--[[
    Creates a new MainMenu class instance.
]]
function MainMenu.New(): MainMenu
    local self = setmetatable(Menu.New("MainMenu"), MainMenu) :: MainMenu
    self.RootContainer = self.ScreenGUI.Root
    self.Buttons = self.RootContainer.Buttons

    return self
end

--[[
    Handles the buttons.
]]
function MainMenu:HandleButtons()
    self.Buttons.Play.MouseButton1Click:Connect(function()
        Maps:StartMap(Rage.Libs.Table:GetRandom(Maps.ExistingMaps))
    end)
end

--[[
    Setups the menu.
]]
function MainMenu:Setup()
    self:HandleButtons()

    if not Maps.IsInMap then
        self:Show()
    end

    self.OnMapStart = Maps.OnMapStart:Connect(function()
        self:Hide()
    end)

    self.OnMapExit = Maps.OnMapExit:Connect(function()
        self:Show()
    end)
end

export type MainMenu = Menu.Menu & typeof(MainMenu) & {
    RootContainer: Frame,
    Buttons: Frame,

    OnMapStart: signal.Connection,
    OnMapExit: signal.Connection
}

return MainMenu