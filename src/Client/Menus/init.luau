--------------------------------------------------------
-- [Ragdollworks] Menus
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

local CLI = require(Rage.Path.CLI)

local Menu = require(Rage.Path.Classes.Menu)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling UI menus.
]]
Menus = Rage:Service("Menus") :: Menus
Menus.StartPriority = 99

Menus.MAIN_MENU_SCENE = "MainMenu"

Menus.CORE_GUI_TO_HIDE = {
    Enum.CoreGuiType.PlayerList,
    Enum.CoreGuiType.Health,
    Enum.CoreGuiType.Chat,
    Enum.CoreGuiType.SelfView,
    Enum.CoreGuiType.EmotesMenu,
    Enum.CoreGuiType.Backpack
} :: {Enum.CoreGuiType}

Menus.Menus = {} :: {[string]: Menu.Menu}
Menus.ForceHidden = false
Menus.Scenes = {} :: {string}

Menus.OnSceneSet = signal.new() :: signal.Signal<string>
Menus.OnSceneAdd = signal.new() :: signal.Signal<string>
Menus.OnSceneRemove = signal.new() :: signal.Signal<string>

--[[
    Called when the service starts.
]]
function Menus:OnStart()
    self:LoadMenus()
    self:HideCoreGUI()
    self:_CreateCommands()

    self:SetMainMenuScene()
end

--[[
    Called every heartbeat.
]]
function Menus:OnHeartbeat(deltaTime: number)
    for _, menu in pairs(self:GetMenus()) do
        menu:SetForceHidden(self.ForceHidden)
        menu:Update(deltaTime)
    end
end

--[[
    Sets the current scene to the main menu.
]]
function Menus:SetMainMenuScene()
    self:SetScene(self.MAIN_MENU_SCENE)
end

--[[
    Sets the current scene.
]]
function Menus:SetScene(scene: string)
    if self:HasScene(scene) and #self.Scenes == 1 then
        return
    end

    for _, _scene in pairs(self.Scenes) do
        if _scene == scene then
            continue
        end

        self.OnSceneRemove:Fire(_scene)
    end

    local wasInScene = self:HasScene(scene)

    self.Scenes = {scene}
    self:_UpdateAllMenusVisibility()
    self.OnSceneSet:Fire(scene)

    if not wasInScene then
        self.OnSceneAdd:Fire(scene)
    end

    Rage.Logging:Info("Menus: Set scene ONLY to "..scene)
end

--[[
    Adds a scene.
]]
function Menus:AddScene(scene: string)
    if self:HasScene(scene) then
        return
    end

    table.insert(self.Scenes, scene)
    self:_UpdateAllMenusVisibility()
    self.OnSceneAdd:Fire(scene)

    Rage.Logging:Info("Menus: Added scene "..scene)
end

--[[
    Removes a scene.
]]
function Menus:RemoveScene(scene: string)
    if not self:HasScene(scene) then
        return
    end

    table.remove(self.Scenes, Rage.Libs.Table:Find(self.Scenes, scene))
    self:_UpdateAllMenusVisibility()
    self.OnSceneRemove:Fire(scene)

    Rage.Logging:Info("Menus: Removed scene "..scene)
end

--[[
    Adds or removes the provided scene (toggle).
]]
function Menus:ToggleScene(scene: string)
    if self:HasScene(scene) then
        self:RemoveScene(scene)
    else
        self:AddScene(scene)
    end
end

--[[
    Returns if the provided scene is active.
]]
function Menus:HasScene(scene: string): boolean
    return Rage.Libs.Table:Find(self.Scenes, scene) ~= nil
end

--[[
    Shows/hides all menus that can be shown with the current scene.
]]
function Menus:_UpdateAllMenusVisibility()
    for _, menu in pairs(self:GetMenus()) do
        menu:SetVisible(menu:CanShowWithScenes(self.Scenes))
    end
end

--[[
    Hides most CoreGUI.
]]
function Menus:HideCoreGUI()
    for _, coreGuiType in pairs(self.CORE_GUI_TO_HIDE) do
        Rage.Logging:Info("Menus:HideCoreGUI(): Hiding CoreGUI: "..coreGuiType.Name)
        Rage.StarterGUI:SetCoreGuiEnabled(coreGuiType, false)
    end
end

--[[
    Sets whether or not force-hide compatible menus are forcefully hidden.
]]
function Menus:SetForceHidden(force: boolean)
    if self.ForceHidden == force then
        return
    end

    self.ForceHidden = force
end

--[[
    Returns a menu by name.
]]
function Menus:GetMenu(name: string): Menu.Menu?
    return self.Menus[name]
end

--[[
    Returns all available menus.
]]
function Menus:GetMenus(): {[string]: Menu.Menu}
    return self.Menus
end

--[[
    Loads all menus.
]]
function Menus:LoadMenus()
    Rage.Logging:Info("Menus:LoadMenus(): Loading menus...")

    for _, menuModuleScript: ModuleScript in pairs(script.Menus:GetChildren()) do
        local menu = require(menuModuleScript).New() :: Menu.Menu
        menu:Setup()
        self.Menus[menu.Name] = menu

        Rage.Logging:Info("Menus:LoadMenus(): Loaded menu: "..menu.Name)
    end
end

--[[
    Creates CLI commands.
]]
function Menus:_CreateCommands()
    CLI.Conch.register("ui", {
        description = "Toggles UI.",

        arguments = function()
            return CLI.Conch.args.boolean("Visible", "Whether or not UI should be visible.")
        end,

        callback = function(visible: boolean)
            self:SetForceHidden(not visible)
        end
    })
end

export type Menus = Rage.Service & typeof(Menus)
return Menus