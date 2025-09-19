--------------------------------------------------------
-- [Ragdollworks] Organization
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