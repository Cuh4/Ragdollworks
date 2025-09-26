--------------------------------------------------------
-- [Ragdollworks] Organization
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
    A service for creating folders to insert instances into.<br>
    Keeps your explorer tidy and organised!
]]
Organization = Rage:Service("Organization") :: Organization

--[[
    Creates a folder parented to `parent` with a name of `name`.
]]
function Organization:CreateFolder(name: string, parent: Instance): Folder
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent

    return folder
end

export type Organization = Rage.Service & typeof(Organization)
return Organization