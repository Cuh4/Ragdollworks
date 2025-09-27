--------------------------------------------------------
-- [Rage] Classes
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