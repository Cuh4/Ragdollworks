--------------------------------------------------------
-- [Rage] Logging
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
-- // Variables
-------------------------------

local RunService = game:GetService("RunService")

-------------------------------
-- // Main
-------------------------------

--[[
    A library for logging messages.
]]
Logging = {}

--[[
    Logs a message. Used internally.
]]
function Logging:_Log(logType: string, func: (...string) -> nil, ...: string)
    func(("[Rage] [%s] [%s]: %s"):format(RunService:IsServer() and "Server" or "Client", logType, table.concat({...}, " ")))
end

--[[
    Sends an info log.
]]
function Logging:Info(...: string)
    self:_Log("INFO", print, ...)
end

--[[
    Sends a warning log.
]]
function Logging:Warn(...: string)
    self:_Log("WARNING", warn, ...)
end

--[[
    Sends and raises an error
]]
function Logging:Error(...: string)
    self:_Log("ERROR", error, ...)
end

--[[
    Sends an error if the condition is false (assert).
]]
function Logging:Assert(condition: boolean, ...: string)
    if not condition then
        self:Error(...)
    end
end

return Logging