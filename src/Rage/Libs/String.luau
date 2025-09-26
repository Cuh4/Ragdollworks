--------------------------------------------------------
-- [Rage] String
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