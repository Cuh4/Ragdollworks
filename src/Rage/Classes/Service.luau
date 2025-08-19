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
Service = {}
Service.__index = Service

--[[
    Creates a new service class instance.
]]
function Service.New(name: string): Service
    local service = setmetatable({}, Service)
    service.Name = name

    return service
end

--[[
    Returns the name of the service.
]]
function Service:GetName(): string
    return self.Name
end

export type Service = {
    Name: string,
    OnStart: ((self: Service) -> nil)|nil
} & typeof(Service)

return Service