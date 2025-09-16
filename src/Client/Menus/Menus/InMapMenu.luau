--------------------------------------------------------
-- [Ragdollworks] In Map Menu
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
local Objects = require(Rage.Path.Objects)
local RbxAssets = require(Rage.Path.RbxAssets)

local Menu = require(Rage.Path.Classes.Menu)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    A menu only shown while in a map.<br>
    This is the overlay that shows quick but essential information.
]]
InMapMenu = {} :: InMapMenu
InMapMenu.__index = InMapMenu
setmetatable(InMapMenu, Menu)

--[[
    Creates a new InMapMenu class instance.
]]
function InMapMenu.New(): InMapMenu
    local self = setmetatable(Menu.New("InMap"), InMapMenu) :: InMapMenu
    self.InfoContainer = self.ScreenGUI.Info
    self.PlayerContainer = self.InfoContainer.PlayerContainer
    self.PlayerIcon = self.PlayerContainer.PlayerIcon
    self.PlayerName = self.PlayerContainer.PlayerName

    self.ObjectsContainer = self.InfoContainer.ObjectsContainer

    self.ObjectsSpawnedContainer = self.InfoContainer.ObjectsSpawned
    self.ObjectsSpawnedNumberText = self.ObjectsSpawnedContainer.ObjectCountContainer.ObjectCountText

    self.SelectedObjectContainer = self.ObjectsContainer.SelectedObjectContainer
    self.SelectedObjectText = self.SelectedObjectContainer.ObjectName
    self.SelectedObjectIcon = self.SelectedObjectContainer.ObjectIcon

    self.SelectedWireContainer = self.ObjectsContainer.SelectedWireContainer
    self.SelectedWireText = self.SelectedWireContainer.WireName
    self.SelectedWireIcon = self.SelectedWireContainer.WireIcon

    self.PausedStateContainer = self.ObjectsContainer.PausedStateContainer
    self.PausedStateIcon = self.PausedStateContainer.PausedStateIcon

    self.Vignette = self.ScreenGUI.Vignette

    return self
end

--[[
    Updates the spawned objects counter.
]]
function InMapMenu:UpdateSpawnedObjectsCounter()
    self.ObjectsSpawnedNumberText.Text = Objects.SpawnedObjectCount
end

--[[
    Updates the selected object container.
]]
function InMapMenu:UpdateSelectedObject()
    if not Objects.SelectedObject then
        self.SelectedObjectContainer.Visible = false
        return
    end

    self.SelectedObjectContainer.Visible = true
    self.SelectedObjectText.Text = Objects.SelectedObject.Name
    self.SelectedObjectIcon.Image = Objects.SelectedObject.IconAssetID or RbxAssets.UNKNOWN_ICON
end

--[[
    Updates the selected wire container.
]]
function InMapMenu:UpdateSelectedWire()
    if not Objects.SelectedWire then
        self.SelectedWireContainer.Visible = false
        return
    end

    self.SelectedWireContainer.Visible = true
    self.SelectedWireText.Text = Objects.SelectedWire.Name
    self.SelectedWireIcon.Image = Objects.SelectedWire.IconAssetID or RbxAssets.UNKNOWN_ICON
end

--[[
    Updates the paused state container.
]]
function InMapMenu:UpdatePausedState()
    self.PausedStateIcon.Image = Objects.Paused and RbxAssets.PAUSED_ICON or RbxAssets.UNPAUSED_ICON
    self:UpdateVignette()
end

--[[
    Updates the vignette.
]]
function InMapMenu:UpdateVignette()
    self.Vignette.Visible = Objects.Paused or Objects.SlowMotion

    if Objects.Paused then
        self.Vignette.ImageTransparency = 0
    elseif Objects.SlowMotion then
        self.Vignette.ImageTransparency = 0.7
    end
end

--[[
    Returns the player's icon.
]]
function InMapMenu:GetPlayerIcon(): (string, boolean)
    return Rage.Players:GetUserThumbnailAsync(
        Rage.Player.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size352x352
    )
end

--[[
    Setups the menu.
]]
function InMapMenu:Setup()
    self.PlayerIcon.Image = Rage.Players:GetUserThumbnailAsync(
        Rage.Player.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size352x352
    )

    self.PlayerName.Text = Rage.Player.Name

    self:UpdateSelectedObject()
    self:UpdateSelectedWire()
    self:UpdateSpawnedObjectsCounter()
    self:UpdatePausedState()
    self:UpdateVignette()

    self.OnMapStart = Maps.OnMapStart:Connect(function()
        self:Show()
    end)

    self.OnMapExit = Maps.OnMapExit:Connect(function()
        self:Hide()
    end)

    self.OnObjectSpawn = Objects.OnSpawn:Connect(function()
        self:UpdateSpawnedObjectsCounter()
    end)

    self.OnObjectDespawn = Objects.OnDespawn:Connect(function()
        self:UpdateSpawnedObjectsCounter()
    end)

    self.OnObjectSelect = Objects.OnObjectSelect:Connect(function()
        self:UpdateSelectedObject()
    end)

    self.OnWireSelect = Objects.OnWireSelect:Connect(function()
        self:UpdateSelectedWire()
    end)

    self.OnPauseStateChange = Objects.OnPauseStateChange:Connect(function()
        self:UpdatePausedState()
    end)

    self.OnSlomoStateChange = Objects.OnSlomoStateChange:Connect(function()
        self:UpdateVignette()
    end)
end

export type InMapMenu = Menu.Menu & typeof(InMapMenu) & {
    InfoContainer: Frame,
    PlayerContainer: Frame,
    PlayerIcon: ImageLabel,
    PlayerName: TextLabel,

    ObjectsContainer: Frame,

    ObjectsSpawnedContainer: Frame,
    ObjectsSpawnedNumberText: TextLabel,

    SelectedObjectContainer: Frame,
    SelectedObjectText: TextLabel,
    SelectedObjectIcon: ImageLabel,

    SelectedWireContainer: Frame,
    SelectedWireText: TextLabel,
    SelectedWireIcon: ImageLabel,

    PausedStateContainer: Frame,
    PausedStateIcon: ImageLabel,

    Vignette: ImageLabel,

    OnMapStart: signal.Connection,
    OnMapExit: signal.Connection,

    OnObjectSpawn: signal.Connection,
    OnObjectDespawn: signal.Connection,
    OnObjectSelect: signal.Connection,
    OnWireSelect: signal.Connection,

    OnPauseStateChange: signal.Connection,
    OnSlomoStateChange: signal.Connection
}

return InMapMenu