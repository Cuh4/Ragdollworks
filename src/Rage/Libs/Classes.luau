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
    return getmetatable(instance) == class
end

export type Classes = typeof(Classes)

return Classes