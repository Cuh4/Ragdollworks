--------------------------------------------------------
-- [Rage] Assets
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 cuhHub - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

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