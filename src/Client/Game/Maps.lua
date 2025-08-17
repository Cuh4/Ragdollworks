--------------------------------------------------------
-- [Ragdollworks] Maps
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 cuhHub - All Rights Reserved
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
    A service for handling maps.
]]
Maps = Rage:Service("Maps") :: Maps

function Maps:OnInit()
end

function Maps:OnStart()
end

export type Maps = {
} & typeof(Maps)

return Maps