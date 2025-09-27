--------------------------------------------------------
-- [Ragdollworks] Bind Collection
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

local Bind = require(script.Parent.Bind)

-------------------------------
-- // Main
-------------------------------

--[[
    A class holding a bunch of binds that can all be manipulated together in one place.
]]
BindCollection = {} :: BindCollection
BindCollection.__index = BindCollection

--[[
    Creates a new BindCollection class instance.
]]
function BindCollection.New(binds: {Bind.Bind}): BindCollection
    local self = setmetatable({binds}, BindCollection) :: BindCollection
    self.Binds = binds
    self.Entered = false

    return self
end

--[[
    Adds a new bind to this collection.
]]
function BindCollection:AddBind(bind: Bind.Bind)
    if self.Entered then
        bind:Enter()
    else
        bind:Exit()
    end

    table.insert(self.Binds, bind)
end

--[[
    Removes a bind from this collection.
]]
function BindCollection:RemoveBind(bind: Bind.Bind)
    Rage.Libs.Table:Remove(self.Binds, bind)
end

--[[
    Enters into this bind collection.
]]
function BindCollection:Enter()
    if self.Entered then
        return
    end

    for _, bind in ipairs(self.Binds) do
        bind:Enter()
    end

    self.Entered = true
end

--[[
    Exits from this bind collection.
]]
function BindCollection:Exit()
    if not self.Entered then
        return
    end

    for _, bind in ipairs(self.Binds) do
        bind:Exit()
    end

    self.Entered = false
end

export type BindCollection = typeof(BindCollection) & {
    Binds: {Bind.Bind},
    Entered: boolean
}

return BindCollection