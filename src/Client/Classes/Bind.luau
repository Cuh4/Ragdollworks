--------------------------------------------------------
-- [Ragdollworks] Bind
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

local ContextActionService = game:GetService("ContextActionService")

local signal = require(Rage.WallyPackages.signal)

local RbxAssets = require(Rage.Path.RbxAssets)
local ID = require(Rage.Path.ID)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a Bind (keybind). See the `Binds` service.
]]
Bind = {} :: Bind
Bind.__index = Bind

--[[
    Creates a new Bind class instance.
]]
function Bind.New(name: string, summary: string, binds: {BindInputType}, settings: BindSettings, childBinds: {Bind}?): Bind
    local self = setmetatable({}, Bind) :: Bind
    self.ID = ID:GetID()
    self.Name = name
    self.Summary = summary
    self.Binds = binds
    self.Settings = settings
    self.Entered = false
    self.IsBeingPressed = false
    self.CurrentContext = nil
    self.ChildBinds = childBinds or {}

    self.OnTrigger = signal.new()
    self.OnEnter = signal.new()
    self.OnExit = signal.new()
    self.OnHeartbeat = signal.new()

    return self
end

--[[
    Returns icon asset IDs for all the binds.
]]
function Bind:GetIcons(): {[BindInputType]: string}
    local icons = {} :: {[BindInputType]: string}

    for _, bind in pairs(self.Binds) do
        icons[bind] = RbxAssets.BIND_ICONS[bind] or RbxAssets.UNKNOWN_ICON
    end

    return icons
end

--[[
    Returns the text summary of this context action.
]]
function Bind:GetSummary(): string
    return self.Summary
end

--[[
    Invokes heartbeat event.
]]
function Bind:Heartbeat()
    if not self.Entered then
        return
    end

    if not self.CurrentContext then
        return
    end

    self.OnHeartbeat:Fire(self.CurrentContext)
end

--[[
    Binds the action to ContextActionService.
]]
function Bind:_MakeBind()
    ContextActionService:BindAction(self.Name, function(_, state: Enum.UserInputState, inputObject: InputObject)
        if state == Enum.UserInputState.Begin then
            self.IsBeingPressed = true
        elseif state == Enum.UserInputState.End or Enum.UserInputState.Cancel then
            self.IsBeingPressed = false
        end

        self:_Trigger(state, inputObject)
    end, self.Settings.ShowTouchButton, table.unpack(self.Binds))
end

--[[
    Removes the bind from ContextActionService.
]]
function Bind:_RemoveBind()
    self.IsBeingPressed = false
    ContextActionService:UnbindAction(self.Name)
end

--[[
    Enters this bind (makes it available).
]]
function Bind:Enter()
    if self.Entered then
        return
    end

    self:_MakeBind()

    self.Entered = true
    self.OnEnter:Fire()
end

--[[
    Triggers this bind. Does nothing if this bind isn't entered.
]]
function Bind:_Trigger(state: Enum.UserInputState, inputObject: InputObject)
    if not self.Entered then
        return
    end

    self.CurrentContext = {
        Bind = self,
        InputObject = inputObject,
        State = state
    }

    if self.IsBeingPressed then
        for _, childBind in pairs(self.ChildBinds) do
            childBind:Enter()
        end
    else
        for _, childBind in pairs(self.ChildBinds) do
            childBind:Exit()
        end
    end

    self.OnTrigger:Fire(self.CurrentContext)
end

--[[
    Refreshes the bind.
]]
function Bind:Refresh()
    if not self.Entered then
        return
    end

    self:_RemoveBind()
    self:_MakeBind()
end

--[[
    Exits this bind (makes it unavailable).
]]
function Bind:Exit()
    if not self.Entered then
        return
    end

    self:_RemoveBind()

    self.Entered = false
    self.OnExit:Fire()
end

--[[
    Adds an accepted input to this bind.
]]
function Bind:AddBind(input: BindInputType)
    table.insert(self.Binds, input)
    self:Refresh()
end

--[[
    Removes an accepted input from this bind.
]]
function Bind:RemoveBind(input: BindInputType)
    Rage.Libs.Table:Remove(self.Binds, input)
    self:Refresh()
end

export type BindContext = {
    Bind: Bind,
    InputObject: InputObject,
    State: Enum.UserInputState
}

export type BindSettings = {
    ShowTouchButton: boolean
}

export type BindInputType = Enum.KeyCode | Enum.UserInputType

export type Bind = typeof(Bind) & {
    ID: number,
    Name: string,
    Summary: string,
    Binds: {BindInputType},
    Settings: BindSettings,
    Entered: boolean,
    IsBeingPressed: boolean,
    CurrentContext: BindContext?,
    ChildBinds: {Bind},

    OnTrigger: signal.Signal<BindContext>,
    OnEnter: signal.Signal,
    OnExit: signal.Signal,
    OnHeartbeat: signal.Signal<BindContext>
}

return Bind