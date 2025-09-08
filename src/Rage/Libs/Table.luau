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
-- // Variables
-------------------------------

local Math = require(script.Parent.Math)

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

--[[
    Returns the last value in a sequential table.
]]
function Table:GetLast(tbl: table): any
    if #tbl <= 0 then
        return
    end

    return tbl[#tbl]
end

--[[
    Returns a random value in a sequential table.
]]
function Table:GetRandom(tbl: table): any
    if #tbl <= 0 then
        return
    end

    return tbl[Math:Random(1, #tbl)]
end

--[[
    Merges two tables together via `table.insert` and iteration.
]]
function Table:Merge(tbl1: table, tbl2: table)
    local tbl = table.clone(tbl1)

    for _, value in pairs(tbl2) do
        table.insert(tbl, value)
    end

    return tbl
end

--[[
    Finds a value in a sequential table and returns the index, or nil if not found.
]]
function Table:Find(tbl: table, value: any): number?
    for index, _value in pairs(tbl) do
        if _value == value then
            return index
        end
    end
end

--[[
    Removes a value from a sequential table.
]]
function Table:Remove(tbl: table, value: any)
    local index = self:Find(tbl, value)

    if not index then
        return
    end

    table.remove(tbl, index)
end

--[[
    Reverse version of ipairs.
]]
function Table:IterateReverse(tbl: table, callback: (index: number, value: any) -> nil)
    if #tbl <= 0 then
        return
    end

    for index = #tbl, 1, -1 do
        local value = tbl[index]

        if value then
            callback(index, tbl[index])
        end
    end
end

export type Table = typeof(Table)
return Table