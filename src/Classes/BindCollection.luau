--------------------------------------------------------
-- [Ragdollworks] Bind Collection
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

    for _, bind in self.Binds do
        bind:Enter()
    end
end

--[[
    Exits from this bind collection.
]]
function BindCollection:Exit()
    if not self.Entered then
        return
    end

    for _, bind in self.Binds do
        bind:Exit()
    end
end

export type BindCollection = typeof(BindCollection) & {
    Binds: {Bind.Bind},
    Entered: boolean
}

return BindCollection