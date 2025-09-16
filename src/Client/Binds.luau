--------------------------------------------------------
-- [Ragdollworks] Binds
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

local signal = require(Rage.WallyPackages.signal)

local CLI = require(Rage.Path.CLI)

local Bind = require(Rage.Path.Classes.Bind)
local BindCollection = require(Rage.Path.Classes.BindCollection)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling keybinds.
]]
Binds = Rage:Service("Binds") :: Binds
Binds.BindCollections = {} :: {[string]: BindCollection.BindCollection}
Binds.RegisteredBinds = {} :: {Bind.Bind}
Binds.EnteredBinds = {} :: {Bind.Bind}
Binds.ExitedBinds = {} :: {Bind.Bind}

Binds.OnBindEnter = signal.new() :: signal.Signal<Bind.Bind>
Binds.OnBindExit = signal.new() :: signal.Signal<Bind.Bind>
Binds.OnBindTrigger = signal.new() :: signal.Signal<Bind.Bind, Bind.BindContext>

--[[
    Called when the service starts.
]]
function Binds:OnStart()
    self.HeartbeatConnection = Rage.RunService.Heartbeat:Connect(function()
        self:Heartbeat()
    end)

    self:_CreateCommands()
end

--[[
    Creates a bind collection.
]]
function Binds:CreateBindCollection(name: string, binds: {Bind.Bind}): BindCollection.BindCollection
    local bindCollection = BindCollection.New(binds)
    self.BindCollections[name] = bindCollection

    return bindCollection
end

--[[
    Returns a bind collection by name.
]]
function Binds:GetBindCollection(name: string): BindCollection.BindCollection
    return self.BindCollections[name]
end

--[[
    Registers a bind.
]]
function Binds:_RegisterBind(bind: Bind.Bind)
    table.insert(self.RegisteredBinds, bind)
    table.insert(self.ExitedBinds, bind)
end

--[[
    Creates a bind.
]]
function Binds:CreateBind(
    name: string,
    summary: string,
    binds: {Bind.BindInputType},
    settings: {Bind.BindSettings},
    trigger: (Bind.BindContext) -> nil?,
    heartbeat: (Bind.BindContext) -> nil?,
    childBinds: {Bind.Bind}?
): Bind.Bind
    local bind = Bind.New(
        name,
        summary,
        binds,
        settings,
        childBinds
    )

    -- Register
    self:_RegisterBind(bind)

    -- Connect callbacks
    if trigger then
        bind.OnTrigger:Connect(trigger)
    end

    if heartbeat then
        bind.OnHeartbeat:Connect(heartbeat)
    end

    -- Handle events
    bind.OnTrigger:Connect(function(context: Bind.BindContext)
        self.OnBindTrigger:Fire(bind, context)
    end)

    bind.OnEnter:Connect(function()
        table.insert(self.EnteredBinds, bind)
        Rage.Libs.Table:Remove(self.ExitedBinds, bind)

        self.OnBindEnter:Fire(bind)

        Rage.Logging:Info(("Bind '%s': Entered"):format(name))
    end)

    bind.OnExit:Connect(function()
        Rage.Libs.Table:Remove(self.EnteredBinds, bind)
        table.insert(self.ExitedBinds, bind)

        self.OnBindExit:Fire(bind)

        Rage.Logging:Info(("Bind '%s': Exited"):format(name))
    end)

    -- Log
    local concatenated = table.concat(Rage.Libs.Table:Map(binds, function(value: Bind.BindInputType)
        return value.Name
    end), ", ")

    Rage.Logging:Info(("Binds:CreateBind(): Created bind '%s' with binds: %s"):format(name, concatenated))

    return bind
end

--[[
    Returns a bind by name.
]]
function Binds:GetBind(name: string): Bind.Bind?
    for _, bind in ipairs(self:GetBinds()) do
        if bind.Name == name then
            return bind
        end
    end
end

--[[
    Returns all binds.
]]
function Binds:GetBinds(): {Bind.Bind}
    return self.RegisteredBinds
end

--[[
    Returns all entered binds.
]]
function Binds:GetEnteredBinds(): {Bind.Bind}
    return self.EnteredBinds
end

--[[
    Returns all exited binds.
]]
function Binds:GetExitedBinds(): {Bind.Bind}
    return self.ExitedBinds
end

--[[
    Returns the input types of all entered binds.
]]
function Binds:GetInputTypesOfEnteredBinds(): {Bind.BindInputType}
    local inputTypes = {} :: {Bind.BindInputType}

    for _, bind in ipairs(self:GetEnteredBinds()) do
        for _, input in ipairs(bind.Binds) do
            table.insert(inputTypes, input)
        end
    end

    return inputTypes
end

--[[
    Invokes heartbeat for all binds.
]]
function Binds:Heartbeat()
    for _, bind in ipairs(self:GetBinds()) do
        bind:Heartbeat()
    end
end

--[[
    Creates CLI commands.
]]
function Binds:_CreateCommands()
    CLI.Conch.register("enter-bind", {
        description = "Enters a bind.",

        arguments = function()
            return CLI.Conch.args.string("Bind", "The bind name.")
        end,

        callback = function(bind: string)
            local foundBind = self:GetBind(bind)

            if not foundBind then
                Rage.Logging:Warn("No bind found with provided name.")
                return
            end

            foundBind:Enter()
        end
    })

    CLI.Conch.register("exit-bind", {
        description = "Exits a bind.",

        arguments = function()
            return CLI.Conch.args.string("Bind", "The bind name.")
        end,

        callback = function(bind: string)
            local foundBind = self:GetBind(bind)

            if not foundBind then
                Rage.Logging:Warn("No bind found with provided name.")
                return
            end

            foundBind:Exit()
        end
    })

    CLI.Conch.register("bind", {
        description = "Binds a key to an action.",

        arguments = function()
            return CLI.Conch.args.string("Key", "The key to bind."),
                CLI.Conch.args.string("Bind", "The bind name.")
        end,

        callback = function(key: string, bind: string)
            local foundBind = self:GetBind(key)

            if not foundBind then
                Rage.Logging:Warn("No bind found with provided name.")
                return
            end

            local input = Enum.KeyCode[key] or Enum.UserInputType[key]

            if not input then
                Rage.Logging:Warn("Invalid key provided.")
                return
            end

            foundBind:AddBind(input)
        end
    })

    CLI.Conch.register("unbind", {
        description = "Unbinds a key from an action.",

        arguments = function()
            return CLI.Conch.args.string("Key", "The key to unbind."),
                CLI.Conch.args.string("Bind", "The bind name.")
        end,

        callback = function(key: string, bind: string)
            local foundBind = self:GetBind(key)

            if not foundBind then
                Rage.Logging:Warn("No bind found with provided name.")
                return
            end

            local input = Enum.KeyCode[key] or Enum.UserInputType[key]

            if not input then
                Rage.Logging:Warn("Invalid key provided.")
                return
            end

            foundBind:RemoveBind(input)
        end
    })
end

export type Binds = Rage.Service & typeof(Binds)
return Binds