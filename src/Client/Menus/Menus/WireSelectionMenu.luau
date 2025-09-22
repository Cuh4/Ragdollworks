--------------------------------------------------------
-- [Ragdollworks] Wire Selection Menu
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
    local textContainer = container.TextContainer :: Frame
    local wireName = textContainer.WireName :: TextLabel

    imageButton.MouseButton1Click:Connect(function()
        Objects:SelectWire(wire)
    end)

    imageButton.Image = wire:GetIcon()
    wireName.Text = wire.Name

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