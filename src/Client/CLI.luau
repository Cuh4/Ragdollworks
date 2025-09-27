--------------------------------------------------------
-- [Ragdollworks] CLI
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
CLI = Rage:Service("CLI") :: CLI
CLI.Conch = require(game:GetService("ReplicatedStorage").Packages.conch)
CLI.ConchUI = require(game:GetService("ReplicatedStorage").Packages.conch_ui)

--[[
    Called when the service is started.
]]
function CLI:OnStart()
    self.Conch.initiate_default_lifecycle()
    self.ConchUI.bind_to(Enum.KeyCode.F4)
end

export type CLI = Rage.Service & typeof(CLI)
return CLI