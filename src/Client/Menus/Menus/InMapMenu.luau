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

local Objects = require(Rage.Path.Objects)
local RbxAssets = require(Rage.Path.RbxAssets)
local Binds = require(Rage.Path.Binds)
local UI = require(Rage.Path.UI)

local Bind = require(Rage.Path.Classes.Bind)
local Menu = require(Rage.Path.Classes.Menu)

local Trove = require(Rage.WallyPackages.trove)
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
    local self = setmetatable(Menu.New(
        "InMapMenu",
        {"InMap"},
        {CanBeForceHidden = true}
    ), InMapMenu) :: InMapMenu

    self.InfoContainer = self.ScreenGUI.Info

    self.BindsContainer = self.InfoContainer.BindsContainer
    self.BindTroves = {}

    self.ObjectsContainer = self.InfoContainer.ObjectsContainer

    self.DetailViewContainer = self.ObjectsContainer.DetailViewContainer

    self.SlomoStateContainer = self.ObjectsContainer.SlomoStateContainer
    self.SlomoStateText = self.SlomoStateContainer.Text

    self.ObjectsSpawnedContainer = self.ObjectsContainer.ObjectsSpawnedContainer
    self.ObjectsSpawnedNumberText = self.ObjectsSpawnedContainer.ObjectCountContainer.ObjectCountText

    self.SelectedObjectContainer = self.ObjectsContainer.SelectedObjectContainer
    self.SelectedObjectText = self.SelectedObjectContainer.ObjectName
    self.SelectedObjectIcon = self.SelectedObjectContainer.ObjectIcon

    self.SelectedWireContainer = self.ObjectsContainer.SelectedWireContainer
    self.SelectedWireText = self.SelectedWireContainer.WireName
    self.SelectedWireIcon = self.SelectedWireContainer.WireIcon

    self.PausedStateContainer = self.ObjectsContainer.PausedStateContainer
    self.PausedStateIcon = self.PausedStateContainer.PausedStateIcon

    self.Vignette = self.ScreenGUI.Vignette

    return self
end

--[[
    Updates the spawned objects counter.
]]
function InMapMenu:UpdateSpawnedObjectsCounter()
    self.ObjectsSpawnedNumberText.Text = Objects.SpawnedObjectCount
end

--[[
    Updates the selected object container.
]]
function InMapMenu:UpdateSelectedObject()
    if not Objects.SelectedObject then
        self.SelectedObjectContainer.Visible = false
        return
    end

    self.SelectedObjectContainer.Visible = true
    self.SelectedObjectText.Text = Objects.SelectedObject.Name
    self.SelectedObjectIcon.Image = Objects.SelectedObject:GetIcon()
end

--[[
    Updates the selected wire container.
]]
function InMapMenu:UpdateSelectedWire()
    if not Objects.SelectedWire then
        self.SelectedWireContainer.Visible = false
        return
    end

    self.SelectedWireContainer.Visible = true
    self.SelectedWireText.Text = Objects.SelectedWire.Name
    self.SelectedWireIcon.Image = Objects.SelectedWire:GetIcon()
end

--[[
    Updates the paused state container.
]]
function InMapMenu:UpdatePausedState()
    self.PausedStateIcon.Image = Objects.Paused and RbxAssets.PAUSED_ICON or RbxAssets.UNPAUSED_ICON
    self:UpdateVignette()
end

--[[
    Updates the vignette.
]]
function InMapMenu:UpdateVignette()
    self.Vignette.Visible = Objects.Paused or Objects.SlowMotion

    if Objects.Paused then
        self.Vignette.ImageTransparency = 0
    elseif Objects.SlowMotion then
        self.Vignette.ImageTransparency = 0.7
    end
end

--[[
    Updates the detail view UI.
]]
function InMapMenu:UpdateDetailViewState()
    self.DetailViewContainer.Visible = Objects.DetailView
end

--[[
    Updates the slomo state UI.
]]
function InMapMenu:UpdateSlomoState()
    self.SlomoStateText.Text = ("%.1fx"):format(Objects.SlomoSpeed)
    self.SlomoStateContainer.Visible = Objects.SlowMotion
end

--[[
    Adds a bind to the binds container.
]]
function InMapMenu:AddBind(bind: Bind.Bind)
    if not bind.Settings.ShowBindUI then
        return
    end

    if self.BindTroves[bind] then
        return
    end

    local trove = Trove.new()
    local icons = bind:GetIcons()

    for _, input in pairs(bind.Binds) do
        local bindFrame = UI:GetComponent("Bind"):Clone() :: Frame
        local bindIcon = bindFrame.BindIcon :: ImageLabel
        local bindName = bindFrame.BindName :: TextLabel

        bindIcon.Image = icons[input] or RbxAssets.UNKNOWN_ICON
        bindName.Text = bind.Name

        bindFrame.LayoutOrder = bind.ID
        bindFrame.Parent = self.BindsContainer

        trove:Add(bind.OnTrigger:Connect(function(context: Bind.BindContext)
            if context.Bind.IsBeingPressed then
                bindFrame:AddTag("UISelectedContainer")
                bindFrame:RemoveTag("UISecondaryContainer")
                return
            end

            if not context.Bind.IsBeingPressed then
                bindFrame:AddTag("UISecondaryContainer")
                bindFrame:RemoveTag("UISelectedContainer")
            end
        end))

        trove:Add(bindFrame)
    end

    self.BindTroves[bind] = trove
end

--[[
    Removes a bind from the binds container.
]]
function InMapMenu:RemoveBind(bind: Bind.Bind)
    local trove = self.BindTroves[bind]

    if not trove then
        return
    end

    trove:Destroy()
    self.BindTroves[bind] = nil
end

--[[
    Setups the menu.
]]
function InMapMenu:OnSetup()
    self:UpdateSelectedObject()
    self:UpdateSelectedWire()
    self:UpdateSpawnedObjectsCounter()
    self:UpdatePausedState()
    self:UpdateVignette()
    self:UpdateDetailViewState()
    self:UpdateSlomoState()

    self.OnObjectSpawn = Objects.OnSpawn:Connect(function()
        self:UpdateSpawnedObjectsCounter()
    end)

    self.OnObjectDespawn = Objects.OnDespawn:Connect(function()
        self:UpdateSpawnedObjectsCounter()
    end)

    self.OnObjectSelect = Objects.OnObjectSelect:Connect(function()
        self:UpdateSelectedObject()
    end)

    self.OnWireSelect = Objects.OnWireSelect:Connect(function()
        self:UpdateSelectedWire()
    end)

    self.OnPauseStateChange = Objects.OnPauseStateChange:Connect(function()
        self:UpdatePausedState()
    end)

    self.OnSlomoStateChange = Objects.OnSlomoStateChange:Connect(function()
        self:UpdateVignette()
        self:UpdateSlomoState()
    end)

    self.OnDetailViewStateChange = Objects.OnDetailViewStateChange:Connect(function()
        self:UpdateDetailViewState()
    end)

    self.OnBindEnter = Binds.OnBindEnter:Connect(function(bind: Bind.Bind)
        self:AddBind(bind)
    end)

    self.OnBindExit = Binds.OnBindExit:Connect(function(bind: Bind.Bind)
        self:RemoveBind(bind)
    end)

    for _, bind in pairs(Binds:GetEnteredBinds()) do
        self:AddBind(bind)
    end
end

export type InMapMenu = Menu.Menu & typeof(InMapMenu) & {
    InfoContainer: Frame,

    BindsContainer: Frame,
    BindTroves: {[Bind.Bind]: {Trove.Trove}},

    ObjectsContainer: Frame,

    DetailViewContainer: Frame,

    SlomoStateContainer: Frame,
    SlomoStateText: TextLabel,

    ObjectsSpawnedContainer: Frame,
    ObjectsSpawnedNumberText: TextLabel,

    SelectedObjectContainer: Frame,
    SelectedObjectText: TextLabel,
    SelectedObjectIcon: ImageLabel,

    SelectedWireContainer: Frame,
    SelectedWireText: TextLabel,
    SelectedWireIcon: ImageLabel,

    PausedStateContainer: Frame,
    PausedStateIcon: ImageLabel,

    Vignette: ImageLabel,

    OnObjectSpawn: signal.Connection,
    OnObjectDespawn: signal.Connection,
    OnObjectSelect: signal.Connection,
    OnWireSelect: signal.Connection,

    OnPauseStateChange: signal.Connection,
    OnSlomoStateChange: signal.Connection,
    OnDetailViewStateChange: signal.Connection,

    OnBindEnter: signal.Connection,
    OnBindExit: signal.Connection
}

return InMapMenu