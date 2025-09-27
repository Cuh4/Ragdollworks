--------------------------------------------------------
-- [Rage] Logging
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