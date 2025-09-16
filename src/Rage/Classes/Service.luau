--------------------------------------------------------
-- [Rage] Service
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

export type Service = typeof(Service) & {
    Name: string,
    StartPriority: number,
    OnStart: ((self: Service) -> nil)|nil
}

return Service