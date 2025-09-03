--------------------------------------------------------
-- [Ragdollworks] Context Menu Item
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

local UI = require(Rage.Path.UI)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing an item in a context menu.
]]
ContextMenuItem = {} :: ObjectTypes.ContextMenuItem
ContextMenuItem.__index = ContextMenuItem

--[[
    Creates a new ContextMenuItem class instance.
]]
function ContextMenuItem.New(name: string, contextMenu: ObjectTypes.ContextMenu): ObjectTypes.ContextMenuItem
    local self = setmetatable({}, ContextMenuItem) :: ObjectTypes.ContextMenuItem
    self.Name = name
    self.ContextMenu = contextMenu
    self.OnTrigger = signal.new()

    self._ContextMenuItemUI = UI:GetComponent("ContextMenuItem") :: Frame

    return self
end

--[[
    Returns UI for this item.
]]
function ContextMenuItem:GetUI(): (Frame, TextButton)
    local frame = self._ContextMenuItemUI:Clone()
    frame.Name = self.Name

    local button = frame:FindFirstChild("Button") :: TextButton

    if not button then
        Rage.Logging:Error("ContextMenuItem:GetUI(): Could not find button")
    end

    button.Text = self.Name

    return frame, button
end

--[[
    Triggers this context menu item.
]]
function ContextMenuItem:Trigger()
    self.OnTrigger:Fire(self)
end

return ContextMenuItem