--------------------------------------------------------
-- [Ragdollworks] Context Menu
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)
local signal = require(Rage.WallyPackages.signal)

local ObjectTypes = require(script.Parent.Types)
local ContextMenuItem = require(script.Parent.ContextMenuItem)

local UI = require(Rage.Path.UI)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a context menu shown for object parts.
]]
ContextMenu = {} :: ObjectTypes.ContextMenu
ContextMenu.__index = ContextMenu

--[[
    Creates a new ContextMenu class instance.
]]
function ContextMenu.New(objectPart: ObjectTypes.ObjectPart): ObjectTypes.ContextMenu
    local self = setmetatable({}, ContextMenu) :: ObjectTypes.ContextMenu
    self.ObjectPart = objectPart
    self.Items = {}
    self.Visible = false

    self.OnShow = signal.new()
    self.OnHide = signal.new()

    self.ScreenGUI = UI:GetScreenGUI("ObjectContextMenu")
    self.ContextMenuUI = self.ScreenGUI:FindFirstChild("ContextMenu") :: ScrollingFrame

    if not self.ContextMenuUI then
        Rage.Logging:Error("ContextMenu:New(): Could not find context menu frame")
    end

    return self
end

--[[
    Adds an item to the context menu.
]]
function ContextMenu:AddContextMenuItem(name: string, onTrigger: ObjectTypes.ContextMenuItemCallback): ObjectTypes.ContextMenuItem
    local item = ContextMenuItem.New(name, self)
    item.OnTrigger:Connect(onTrigger)

    table.insert(self.Items, item)

    Rage.Logging:Info("ContextMenu:AddContextMenuItem(): Added context menu item: "..name)

    return item
end

--[[
    Adds all context menu items into the UI.
]]
function ContextMenu:_AddUIItems()
    for _, item in pairs(self.Items) do
        local frame, button = item:GetUI()

        button.MouseButton1Click:Once(function()
            item:Trigger()
            self:Hide()
        end)

        frame.Parent = self.ContextMenuUI
    end
end

--[[
    Removes all context menu items from the UI.
]]
function ContextMenu:_RemoveUIItems()
    for _, frame: Frame in pairs(self.ContextMenuUI:GetChildren()) do
        if not frame:IsA("Frame") then
            continue
        end

        frame:Destroy()
    end
end

--[[
    Shows the context menu.
]]
function ContextMenu:Show(position: UDim2): Frame
    if self.Visible then
        Rage.Logging:Error("ContextMenu:Show(): Context menu is already visible")
    end

    self.Visible = true
    self.ContextMenuUI.Visible = true
    self.ContextMenuUI.Position = position

    self:_AddUIItems()

    self.OnShow:Fire()
end

--[[
    Hides the context menu.
]]
function ContextMenu:Hide()
    if not self.Visible then
        Rage.Logging:Error("ContextMenu:Hide(): Context menu is not visible")
    end

    self.Visible = false
    self.ContextMenuUI.Visible = false

    self:_RemoveUIItems()

    self.OnHide:Fire()
end

return ContextMenu