--------------------------------------------------------
-- [Rage] String
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