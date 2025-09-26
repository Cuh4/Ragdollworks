--------------------------------------------------------
-- [Ragdollworks] Map Selection Menu
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

local Maps = require(Rage.Path.Maps)
local Menus = require(Rage.Path.Menus)
local UI = require(Rage.Path.UI)

local Menu = require(Rage.Path.Classes.Menu)
local Map = require(Rage.Path.Classes.Map)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    The menu shown for selecting a map to load into.
]]
MapSelectionMenu = {} :: MapSelectionMenu
MapSelectionMenu.__index = MapSelectionMenu
setmetatable(MapSelectionMenu, Menu)

--[[
    Creates a new MapSelectionMenu class instance.
]]
function MapSelectionMenu.New(): MapSelectionMenu
    local self = setmetatable(Menu.New(
        "MapSelectionMenu",
        {"MapSelection"},
        {CanBeForceHidden = false}
    ), MapSelectionMenu) :: MapSelectionMenu

    self.RootContainer = self.ScreenGUI.Root

    self.TitleContainer = self.RootContainer.Title
    self.GoBackButton = self.TitleContainer.GoBack

    self.MapContainer = self.RootContainer.MapContainer
    self.MapsContainer = self.MapContainer.Maps

    self.MapInfoContainer = self.MapContainer.MapInfo
    self.MapName = self.MapInfoContainer.MapName
    self.MapDescription = self.MapInfoContainer.MapDescription
    self.MapIcon = self.MapInfoContainer.Icon

    return self
end

--[[
    Handles buttons.
]]
function MapSelectionMenu:HandleButtons()
    self.GoBackButton.MouseButton1Click:Connect(function()
        Menus:SetMainMenuScene()
    end)
end

--[[
    Shows info for the selected map.
]]
function MapSelectionMenu:ShowMapInfo(map: Map.Map)
    self.MapName.Text = map.Name
    self.MapDescription.Text = map.Description
    self.MapIcon.Image = map:GetIcon()

    self.MapInfoContainer.Visible = true
end

--[[
    Adds a map to the map selection menu.
]]
function MapSelectionMenu:AddMap(map: Map.Map)
    local container = UI:GetComponent("Map"):Clone() :: Frame
    container.TitleText.Text = map.Name
    container.Icon.Image = map:GetIcon()

    local enterButton = container.Enter :: TextButton

    enterButton.MouseButton1Click:Connect(function()
        Maps:StartMap(map)
    end)

    container.MouseEnter:Connect(function()
        self:ShowMapInfo(map)
    end)

    container.Parent = self.MapsContainer
end

--[[
    Setups the menu.
]]
function MapSelectionMenu:OnSetup()
    self.MapInfoContainer.Visible = false

    for _, map in pairs(Maps:GetMaps()) do
        self:AddMap(map)
    end

    self.OnMapLoad = Maps.OnMapLoad:Connect(function(map: Map.Map)
        self:AddMap(map)
    end)

    self:HandleButtons()
end

export type MapSelectionMenu = Menu.Menu & typeof(MapSelectionMenu) & {
    RootContainer: Frame,

    TitleContainer: Frame,
    GoBackButton: TextButton,

    MapContainer: Frame,
    MapsContainer: Frame,

    MapInfoContainer: Frame,
    MapName: TextLabel,
    MapDescription: TextLabel,
    MapIcon: ImageLabel,

    OnMapLoad: signal.Connection
}

return MapSelectionMenu