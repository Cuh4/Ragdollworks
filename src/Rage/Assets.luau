--------------------------------------------------------
-- [Rage] Assets
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

local logging = require(script.Parent.Logging)

-------------------------------
-- // Main
-------------------------------

--[[
    A library for retrieving assets stored in ReplicatedStorage.
]]
Assets = {}
Assets.RETRIEVAL_TIMEOUT = 5
Assets.LOCATION = game:GetService("ReplicatedStorage"):FindFirstChild("Assets") or logging:Error("Rage.Assets: Assets folder not found")

--[[
    Retrieves an asset by name.
]]
function Assets:GetAsset(name: string)
    return self.LOCATION:WaitForChild(name, self.RETRIEVAL_TIMEOUT) or logging:Error("Rage.Assets: Asset "..name.." not found")
end

return Assets