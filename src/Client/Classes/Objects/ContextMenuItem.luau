--------------------------------------------------------
-- [Ragdollworks] Context Menu Item
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