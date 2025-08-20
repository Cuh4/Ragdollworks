--------------------------------------------------------
-- [Rage] Table
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
    A library providing utility functions for tables.
]]
Table = {}

--[[
    Returns the length of a table via iteration, therefore working with non-sequential tables.
]]
function Table:GetLength(tbl: table): boolean
    local count = 0

    for _ in pairs(tbl) do
        count += 1
    end

    return count
end

export type Table = typeof(Table)

return Table