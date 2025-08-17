--------------------------------------------------------
-- [Rage] Logging
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 cuhHub - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

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

return Logging