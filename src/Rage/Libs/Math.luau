--------------------------------------------------------
-- [Rage] Math
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Copyright (C) 2025 Cuh4

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

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