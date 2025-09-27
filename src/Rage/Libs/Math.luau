--------------------------------------------------------
-- [Rage] Math
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
    A library providing math utilities.
]]
Math = {}

--[[
    Lerps between two values.
]]
function Math:Lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

--[[
    Sets the randomseed.
]]
function Math:_RandomSeed()
    math.randomseed(os.time() * math.random())
end

--[[
    Returns a random number between the ranges, with better randomness.
]]
function Math:Random(min: number, max: number): number
    self:_RandomSeed()
    return math.random(min, max)
end

--[[
    Returns a random float between 0 and 1.
]]
function Math:RandomFloat(): number
    self:_RandomSeed()
    return math.random()
end

export type Math = typeof(Math)
return Math