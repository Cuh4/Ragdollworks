--------------------------------------------------------
-- [Rage] Init
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
-- // Main
-------------------------------

--[[
    Rage, a minimal framework for Roblox games.
]]
Rage = {}
Rage.RunService = game:GetService("RunService")
Rage.IsServer = Rage.RunService:IsServer()
Rage.IsClient = not Rage.IsServer
Rage.IsStudio = Rage.RunService:IsStudio()
Rage.Workspace = game:GetService("Workspace")
Rage.Lighting = game:GetService("Lighting")
Rage.ReplicatedStorage = game:GetService("ReplicatedStorage")
Rage.Players = game:GetService("Players")
Rage.Camera = Rage.Workspace.CurrentCamera
Rage.Input = game:GetService("UserInputService")
Rage.Debris = game:GetService("Debris")

if Rage.IsServer then
    Rage.ServerScriptService = game:GetService("ServerScriptService")
else
    Rage.Player = Rage.Players.LocalPlayer

    function Rage:Character(): Model
        return Rage.Player.Character or Rage.Player.CharacterAdded:Wait()
    end
end

Rage.Logging = require(script.Logging)
Rage.Assets = require(script.Assets)

--[[
    A table of all built-in libraries.
]]
Rage.Libs = {}
Rage.Libs.Classes = require(script.Libs.Classes)
Rage.Libs.Table = require(script.Libs.Table)

--[[
    A table of all built-in classes.
]]
Rage.Classes = {}

local _service = require(script.Classes.Service)
export type Service = _service.Service -- boilerplate/cumbersome as fuck
Rage.Classes.Service = _service

--[[
    A table of all services, indexed by name.
]]
Rage.Services = {} :: {[string]: ModuleScript}

--[[
    A dictionary of paths to load services from.
]]
Rage.ServicePaths = {}

if Rage.IsClient then
    Rage.ServicePaths.Client = Rage.ReplicatedStorage.Client
end

if Rage.IsServer then
    Rage.ServicePaths.Server = Rage.ServerScriptService.Server
end

--[[
    Initializes Rage. This should only be ran once.
]]
function Rage:Initialize()
    -- Get service path
    local path = self:GetServicesPath()

    -- Wait for game to load
    if self.IsClient and not game:IsLoaded() then
        self.Logging:Info("Waiting for game to load before initializing Rage...")
        game.Loaded:Wait()
    end

    -- Log
    self.Logging:Info("Initializing Rage.")

    -- Load services
    self.Logging:Info("Loading all services at:", path:GetFullName())

    for _, service: Service in pairs(self:_LoadAll(path)) do
        if not self.Libs.Classes:IsClassInstance(service, Rage.Classes.Service) then
            continue
        end

        self:_LoadService(service)
    end

    -- Start services
    self:StartServices()
end

--[[
    Returns the path to load services from.
]]
function Rage:GetServicesPath(): Instance
    return self.IsServer and self.ServicePaths.Server or self.ServicePaths.Client
end

--[[
    Creates a service. To be used within a service script.
]]
function Rage:Service(name: string): Service
    return self.Classes.Service.New(name)
end

--[[
    Loads a service.
]]
function Rage:_LoadService(service: Service): Service
    self.Logging:Info("Loading service:", service.Name)

    self.Services[service.Name] = service
    return service
end

--[[
    Starts all services.
]]
function Rage:StartServices()
    for _, service in pairs(self.Services) do
        if not service.OnStart then
            self.Logging:Warn(service.Name, "(service) does not have an `OnStart` method. This method is not required to be implemented however.")
            continue
        end

        task.spawn(service.OnStart, service)
        self.Logging:Info("Started:", service.Name)
    end
end

--[[
    Requires all modules within `at` and returns them.
]]
function Rage:_LoadAll(at: Instance)
    local modules = {} :: {any}

    for _, module in pairs(at:GetDescendants()) do
        if module:IsA("ModuleScript") then
            table.insert(modules, require(module))
        end
    end

    return modules
end

return Rage