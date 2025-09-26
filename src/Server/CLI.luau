--------------------------------------------------------
-- [Ragdollworks] CLI
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