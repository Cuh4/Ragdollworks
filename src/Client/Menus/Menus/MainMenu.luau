--------------------------------------------------------
-- [Ragdollworks] Main Menu
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

local RbxAssets = require(Rage.Path.RbxAssets)
local Menus = require(Rage.Path.Menus)

local Menu = require(Rage.Path.Classes.Menu)

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
    local self = setmetatable(Menu.New(
        "MainMenu",
        {"MainMenu"},
        {CanBeForceHidden = false}
    ), MainMenu) :: MainMenu

    self.CYCLING_IMAGE_INTERVAL = 5

    self.RootContainer = self.ScreenGUI.Root
    self.Buttons = self.RootContainer.Buttons

    self.CyclingImageContainer = self.RootContainer.CyclingImage
    self.CyclingImage = self.CyclingImageContainer.Image

    self.ImageAssetIDs = Rage.Libs.Table:Values(RbxAssets:GetAssetsWithPrefix("MAIN_MENU_IMAGE"))
    self.AtCyclingImage = 1
    self.LastCycle = 0

    return self
end

--[[
    Handles the buttons.
]]
function MainMenu:HandleButtons()
    self.Buttons.Play.MouseButton1Click:Connect(function()
        Menus:SetScene("MapSelection")
    end)

    self.Buttons.Quit.MouseButton1Click:Connect(function()
        Rage.Player:Kick("You quit the game.")
    end)
end

--[[
    Updates the cycling image.
]]
function MainMenu:UpdateCyclingImage()
    local assetID = self.ImageAssetIDs[self.AtCyclingImage] or RbxAssets.UNKNOWN_ICON
    self.CyclingImage.Image = assetID
end

--[[
    Cycles the cycling image.
]]
function MainMenu:CycleImage()
    if not self:IsVisible() then
        return
    end

    if os.clock() - self.LastCycle < self.CYCLING_IMAGE_INTERVAL then
        return
    end

    self.LastCycle = os.clock()
    self.AtCyclingImage = self.AtCyclingImage + 1

    if self.AtCyclingImage > #self.ImageAssetIDs then
        self.AtCyclingImage = 1
    end

    self:UpdateCyclingImage()
end

--[[
    Setups the menu.
]]
function MainMenu:OnSetup()
    self:HandleButtons()
    self:UpdateCyclingImage()
end

--[[
    Called every heartbeat.
]]
function MainMenu:OnUpdate()
    self:CycleImage()
end

export type MainMenu = Menu.Menu & typeof(MainMenu) & {
    CYCLING_IMAGE_INTERVAL: number,

    RootContainer: Frame,
    Buttons: Frame,

    CyclingImageContainer: Frame,
    CyclingImage: ImageLabel,

    ImageAssetIDs: {string},
    AtCyclingImage: number,
    LastCycle: number
}

return MainMenu