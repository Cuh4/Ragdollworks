--------------------------------------------------------
-- [Rage] Classes
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
    A library providing utility functions for classes.
]]
Classes = {}

--[[
    Recursively gets the class (metatable) of a class instance by going upstream until
    the condition is met.
]]
function Classes:_GetClass(instance: table, condition: (table) -> boolean): table?
    local metatable = getmetatable(instance)

    while metatable do
        if condition(metatable) then
            return metatable
        end

        metatable = getmetatable(metatable) -- go up the chain
    end

    return nil
end

--[[
    Returns if a class instance is of the provided class.
]]
function Classes:IsClassInstance(instance: table, class: table): boolean
    local metatable = self:_GetClass(instance, function(metatable)
        return metatable == class
    end)

    return metatable ~= nil
end

--[[
    Returns if two instances are of the same class.
]]
function Classes:AreSameClass(instanceA: table, instanceB: table): boolean
    return getmetatable(instanceA) == getmetatable(instanceB)
end

export type Classes = typeof(Classes)
return Classes