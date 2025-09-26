--------------------------------------------------------
-- [Ragdollworks] Wire Selection Menu
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

local Objects = require(Rage.Path.Objects)
local UI = require(Rage.Path.UI)

local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Menu = require(Rage.Path.Classes.Menu)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    The menu shown for selecting a wire to place.
]]
WireSelectionMenu = {} :: WireSelectionMenu
WireSelectionMenu.__index = WireSelectionMenu
setmetatable(WireSelectionMenu, Menu)

--[[
    Creates a new WireSelectionMenu class instance.
]]
function WireSelectionMenu.New(): WireSelectionMenu
    local self = setmetatable(Menu.New(
        "WireSelectionMenu",
        {"InMap"},
        {CanBeForceHidden = true}
    ), WireSelectionMenu) :: WireSelectionMenu

    self.WiresContainer = self.ScreenGUI.Wires

    return self
end

--[[
    Adds a wire to the menu.
]]
function WireSelectionMenu:AddWire(wire: ObjectTypes.Wire)
    local container = UI:GetComponent("Wire"):Clone() :: Frame
    local imageButton = container.IconButton :: ImageButton

    imageButton.MouseButton1Click:Connect(function()
        Objects:SelectWire(wire)
    end)

    imageButton.Image = wire:GetIcon()

    container.LayoutOrder = wire.ID
    container.Parent = self.WiresContainer
end

--[[
    Setups the menu.
]]
function WireSelectionMenu:OnSetup()
    for _, wire in pairs(Objects.ExistingWires) do
        self:AddWire(wire)
    end

    self.OnWireRegister = Objects.OnWireRegister:Connect(function(wire: ObjectTypes.Wire)
        self:AddWire(wire)
    end)
end

export type WireSelectionMenu = Menu.Menu & typeof(WireSelectionMenu) & {
    WiresContainer: Frame,

    OnWireRegister: signal.Connection
}

return WireSelectionMenu