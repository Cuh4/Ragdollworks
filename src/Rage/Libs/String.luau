--------------------------------------------------------
-- [Rage] String
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
    A library providing utility functions for strings.
]]
String = {}

--[[
    Returns if a string starts with another string.
]]
function String:StartsWith(str: string, start: string): boolean
    return str:sub(1, #start) == start
end

--[[
    Returns if a string ends with another string.
]]
function String:EndsWith(str: string, ending: string): boolean
    return str:sub(-#ending) == ending
end

export type String = typeof(String)
return String