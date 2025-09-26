--------------------------------------------------------
-- [Rage] Assets
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