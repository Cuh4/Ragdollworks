--------------------------------------------------------
-- [Ragdollworks] Base Enum
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