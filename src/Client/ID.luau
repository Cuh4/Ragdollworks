--------------------------------------------------------
-- [Ragdollworks] ID
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

-------------------------------
-- // Main
-------------------------------

--[[
    A service to get unique IDs.
]]
ID = Rage:Service("ID"):: ID
ID.CurrentID = 0

function ID:GetID(): number
    self.CurrentID += 1
    return self.CurrentID
end

export type ID = typeof(ID)
return ID