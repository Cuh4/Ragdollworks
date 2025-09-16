--------------------------------------------------------
-- [Ragdollworks] Menus
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

local Menu = require(Rage.Path.Classes.Menu)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling UI menus.
]]
Menus = Rage:Service("Menus") :: Menus
Menus.Menus = {} :: {[string]: Menu.Menu}

--[[
    Called when the service starts.
]]
function Menus:OnStart()
    self:LoadMenus()
end

--[[
    Returns a menu by name.
]]
function Menus:GetMenu(name: string): Menu.Menu?
    return self.Menus[name]
end

--[[
    Sets a menu as visible.
]]
function Menus:ShowMenu(name: string)
    local menu = self:GetMenu(name)

    if not menu then
        Rage.Logging:Error("Menus:ShowMenu(): No menu found with name '"..name.."'")
    end

    menu:Show()
end

--[[
    Sets a menu as hidden.
]]
function Menus:HideMenu(name: string)
    local menu = self:GetMenu(name)

    if not menu then
        Rage.Logging:Error("Menus:HideMenu(): No menu found with name '"..name.."'")
    end

    menu:Hide()
end

--[[
    Loads all menus.
]]
function Menus:LoadMenus()
    Rage.Logging:Info("Menus:LoadMenus(): Loading menus...")

    for _, menuModuleScript: ModuleScript in pairs(script.Menus:GetChildren()) do
        local menu = require(menuModuleScript).New() :: Menu.Menu
        menu:Hide()
        menu:Setup()
        self.Menus[menu.Name] = menu

        Rage.Logging:Info("Menus:LoadMenus(): Loaded menu: "..menu.Name)
    end
end

--[[
    Returns all available menus.
]]
function Menus:GetMenus(): {[string]: Menu.Menu}
    return self.Menus
end

export type Menus = typeof(Menus)
return Menus