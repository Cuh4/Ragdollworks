--------------------------------------------------------
-- [Ragdollworks] Map Selection Menu
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
local RbxAssets = require(Rage.Path.RbxAssets)
local Menus = require(Rage.Path.Menus)

local Menu = require(Rage.Path.Classes.Menu)


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

    return self
end

--[[
    Setups the menu.
]]
function MapSelectionMenu:OnSetup()
    
end

--[[
    Called every heartbeat.
]]
function MapSelectionMenu:OnUpdate()
    
end

export type MapSelectionMenu = Menu.Menu & typeof(MapSelectionMenu) & {
    RootContainer: Frame
}

return MapSelectionMenu