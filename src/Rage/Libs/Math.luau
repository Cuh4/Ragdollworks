--------------------------------------------------------
-- [Rage] Math
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
    A library providing math utilities.
]]
Math = {}

--[[
    Lerps between two values.
]]
function Math:Lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

export type Math = typeof(Math)
return Math