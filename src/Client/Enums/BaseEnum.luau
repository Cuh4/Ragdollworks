--------------------------------------------------------
-- [Ragdollworks] Base Enum
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
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

-------------------------------
-- // Main
-------------------------------

export type BaseEnum = {
    Name: string
}

--[[
    Returns an enum-like table.
]]
return function(name: string): BaseEnum
    local enum = {} :: BaseEnum
    enum.Name = name

    setmetatable(enum, {
        __index = function(_, key)
            Rage.Logging:Error(("Enum %s does not have member %s"):format(name, key))
        end,

        __call = function(_, value)
            return Rage.Libs.Table:Find(enum, value)
        end,

        __tostring = function()
            return name
        end
    })

    return enum
end