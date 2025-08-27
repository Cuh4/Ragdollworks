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
    self.DEFAULT_OBJECT_ICON = "rbxassetid://403653616" -- question mark image

    self.InfoContainer = self.ScreenGUI.Info
    self.PlayerContainer = self.InfoContainer.PlayerContainer
    self.PlayerIcon = self.PlayerContainer.PlayerIcon
    self.PlayerName = self.PlayerContainer.PlayerName

    self.ObjectsContainer = self.InfoContainer.ObjectsContainer

    self.ObjectsSpawnedContainer = self.ObjectsContainer.ObjectsSpawned
    self.ObjectsSpawnedNumberText = self.ObjectsSpawnedContainer.ObjectCountContainer.ObjectCountText

    self.SelectedObjectContainer = self.ObjectsContainer.SelectedObjectContainer
    self.SelectedObjectText = self.SelectedObjectContainer.ObjectName
    self.SelectedObjectIcon = self.SelectedObjectContainer.ObjectIcon

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
    if not Objects.SelectedObjectToSpawn then
        self.SelectedObjectContainer.Visible = false
        return
    end

    self.SelectedObjectContainer.Visible = true
    self.SelectedObjectText.Text = Objects.SelectedObjectToSpawn.Name
    self.SelectedObjectIcon.Image = Objects.SelectedObjectToSpawn.IconAssetID or self.DEFAULT_OBJECT_ICON
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

    self.OnObjectSelect = Objects.OnSelect:Connect(function()
        self:UpdateSelectedObject()
    end)
end

export type InMapMenu = {
    DEFAULT_OBJECT_ICON: string,

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

    OnMapStart: signal.Connection,
    OnMapExit: signal.Connection,

    OnObjectSpawn: signal.Connection,
    OnObjectDespawn: signal.Connection,
    OnObjectSelect: signal.Connection
} & typeof(InMapMenu) & Menu.Menu

return InMapMenu