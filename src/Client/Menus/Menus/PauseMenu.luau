--------------------------------------------------------
-- [Ragdollworks] Pause Menu
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
local Menus = require(Rage.Path.Menus)

local Menu = require(Rage.Path.Classes.Menu)

-------------------------------
-- // Main
-------------------------------

--[[
    A menu shown when the user presses a specific bind during gameplay.
]]
PauseMenu = {} :: PauseMenu
PauseMenu.__index = PauseMenu
setmetatable(PauseMenu, Menu)

--[[
    Creates a new PauseMenu class instance.
]]
function PauseMenu.New(): PauseMenu
    local self = setmetatable(Menu.New(
        "PauseMenu",
        {"PauseMenu"},
        {CanBeForceHidden = false}
    ), PauseMenu) :: PauseMenu

    self.RootContainer = self.ScreenGUI.Root
    self.Buttons = self.RootContainer.Buttons

    return self
end

--[[
    Handles the buttons.
]]
function PauseMenu:HandleButtons()
    self.Buttons.MainMenu.MouseButton1Click:Connect(function()
        Maps:ExitMap()
    end)

    self.Buttons.Quit.MouseButton1Click:Connect(function()
        Rage.Player:Kick("You quit the game.")
    end)
end

--[[
    Setups the menu.
]]
function PauseMenu:OnSetup()
    self:HandleButtons()
end

export type PauseMenu = Menu.Menu & typeof(PauseMenu) & {
    RootContainer: Frame,
    Buttons: Frame
}

return PauseMenu