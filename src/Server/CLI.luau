--------------------------------------------------------
-- [Ragdollworks] CLI
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
    A service to setup CMDR, a command line interface package.<br>
    This is the server-side implementation.
]]
CLI = Rage:Service("CLI") :: CLI
CLI.Conch = require(game:GetService("ReplicatedStorage").Packages.conch)

function CLI:OnStart()
    self.Conch.initiate_default_lifecycle()
end

export type CLI = typeof(CLI)
return CLI