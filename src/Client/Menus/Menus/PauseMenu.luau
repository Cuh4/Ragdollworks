--------------------------------------------------------
-- [Ragdollworks] Pause Menu
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

local Maps = require(Rage.Path.Maps)
local Objects = require(Rage.Path.Objects)
local Menus = require(Rage.Path.Menus)
local Debug = require(Rage.Path.Debug)

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

    self.Buttons.ToggleUI.MouseButton1Click:Connect(function()
        Menus:SetForceHidden(not Menus.ForceHidden)
        self:HideScene()
    end)

    self.Buttons.DespawnAll.MouseButton1Click:Connect(function()
        Objects:DespawnAllObjects()
        self:HideScene()
    end)

    self.Buttons.ToggleSunlight.MouseButton1Click:Connect(function()
        Maps:SetSunlight(not Maps.IsSunlight)
        self:HideScene()
    end)

    self.Buttons.Quit.MouseButton1Click:Connect(function()
        Rage.Player:Kick("You quit the game.")
    end)

    self.RootContainer.ToggleDebug.MouseButton1Click:Connect(function()
        Debug:SetDebug(not Debug.DebugEnabled)
    end)
end

--[[
    Hides the menu.
]]
function PauseMenu:HideScene()
    Menus:RemoveScene("PauseMenu")
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