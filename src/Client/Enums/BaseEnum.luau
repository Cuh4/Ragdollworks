--------------------------------------------------------
-- [Ragdollworks] Base Enum
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