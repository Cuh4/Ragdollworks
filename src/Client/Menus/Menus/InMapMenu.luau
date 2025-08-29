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

local Menu = require(Rage.ReplicatedStorage.Classes.Menu)

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

    return self
end

--[[
    Updates the spawned objects counter.
]]
function InMapMenu:UpdateSpawnedObjectsCounter()
    self.ObjectsSpawnedNumberText.Text = Objects.SpawnedObjectCount
end

--[[
    Updates the selected object.
]]
function InMapMenu:UpdateSelectedObject()
    if not Objects.SelectedObject then
        self.SelectedObjectContainer.Visible = false
        self:UpdateObjectsContainer()
        return
    end

    self.SelectedObjectContainer.Visible = true
    self.SelectedObjectText.Text = Objects.SelectedObject.Name
    self.SelectedObjectIcon.Image = Objects.SelectedObject.IconAssetID or RbxAssets.UNKNOWN_ICON
    self:UpdateObjectsContainer()
end

--[[
    Updates the selected wire.
]]
function InMapMenu:UpdateSelectedWire()
    if not Objects.SelectedWire then
        self.SelectedWireContainer.Visible = false
        self:UpdateObjectsContainer()
        return
    end

    self.SelectedWireContainer.Visible = true
    self.SelectedWireText.Text = Objects.SelectedWire.Name
    self.SelectedWireIcon.Image = Objects.SelectedWire.IconAssetID or RbxAssets.UNKNOWN_ICON
    self:UpdateObjectsContainer()
end

--[[
    Update objects container.
]]
function InMapMenu:UpdateObjectsContainer()
    -- to prevent a space in container column
    self.ObjectsContainer.Visible = self.SelectedWireContainer.Visible or self.SelectedObjectContainer.Visible
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
end

export type InMapMenu = {
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

    OnMapStart: signal.Connection,
    OnMapExit: signal.Connection,

    OnObjectSpawn: signal.Connection,
    OnObjectDespawn: signal.Connection,
    OnObjectSelect: signal.Connection,
    OnWireSelect: signal.Connection
} & typeof(InMapMenu) & Menu.Menu

return InMapMenu