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
    Returns if a class instance is of the provided class.
]]
function Classes:IsClassInstance(instance: table, class: table): boolean
    local metatable = getmetatable(instance)

    while metatable do
        if metatable == class then
            return true
        end

        metatable = getmetatable(metatable) -- go up the chain
    end

    return false
end

export type Classes = typeof(Classes)
return Classes