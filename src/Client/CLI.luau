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
    This is the client-side implementation, fit with an UI.
]]
CLI = Rage:Service("CLI"):: CLI
CLI.Conch = require(game:GetService("ReplicatedStorage").Packages.conch)
CLI.ConchUI = require(game:GetService("ReplicatedStorage").Packages.conch_ui)

--[[
    Called when the service is started.
]]
function CLI:OnStart()
    if not Rage.IsStudio then
        Rage.Logging:Warn("CLI has been disabled due to production environment.")
        return
    end

    self.Conch.initiate_default_lifecycle()
    self.ConchUI.bind_to(Enum.KeyCode.F4)
end

export type CLI = typeof(CLI)
return CLI