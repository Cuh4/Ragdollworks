--------------------------------------------------------
-- [Rage] Service
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a service.
]]
Service = {} :: Service
Service.__index = Service

--[[
    Creates a new service class instance.
]]
function Service.New(name: string, startPriority: number): Service
    local self = setmetatable({}, Service) :: Service
    self.Name = name
    self.StartPriority = startPriority

    return self
end

--[[
    Returns the name of the service.
]]
function Service:GetName(): string
    return self.Name
end

--[[
    Invokes a callback for this service, and returns if it was successful or not.<br>
    false = no callback found with the given name.
]]
function Service:Invoke(name: string, spawnTask: boolean, ...: any): boolean
    local callback = self[name]

    if type(callback) ~= "function" then
        return false
    end

    if spawnTask then
        task.spawn(callback, self, ...)
    else
        callback(self, ...)
    end

    return true
end

export type Service = typeof(Service) & {
    Name: string,
    StartPriority: number,

    OnStart: ((self: Service) -> nil)?,
    OnPreSimulation: ((self: Service, deltaTime: number) -> nil)?,
    OnPostSimulation: ((self: Service, deltaTime: number) -> nil)?,
    OnHeartbeat: ((self: Service, deltaTime: number) -> nil)?
}

return Service