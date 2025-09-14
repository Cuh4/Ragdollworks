--------------------------------------------------------
-- [Ragdollworks] Rbx Assets
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
    A service for storing and loading assets used throughout the game.
]]
RbxAssets = Rage:Service("RbxAssets") :: RbxAssets
RbxAssets.PRELOAD_DIRECTORIES = {
    Rage.Workspace,
    Rage.Player.PlayerGui,
    Rage.ReplicatedStorage
} :: {Instance}

RbxAssets.CURSOR_ICON = "rbxassetid://118815884093849"
RbxAssets.UNKNOWN_ICON = "rbxassetid://139531674672176"
RbxAssets.PAUSED_ICON = "rbxassetid://133133242300387"
RbxAssets.UNPAUSED_ICON = "rbxassetid://86420074878526"

RbxAssets.HUMAN_IMPACT_1 = "rbxassetid://7446607140"
RbxAssets.HUMAN_IMPACT_2 = "rbxassetid://7446609932"
RbxAssets.HUMAN_IMPACT_3 = "rbxassetid://7446609976"
RbxAssets.HUMAN_IMPACT_4 = "rbxassetid://7446606796"
RbxAssets.HUMAN_IMPACT_5 = "rbxassetid://7446606976"
RbxAssets.HUMAN_IMPACT_6 = "rbxassetid://7446606925"

RbxAssets.HUMAN_GRUNT_1 = "rbxassetid://72066124844939"
RbxAssets.HUMAN_GRUNT_2 = "rbxassetid://4596892095"
RbxAssets.HUMAN_GRUNT_3 = "rbxassetid://93792621035094"

RbxAssets.HUMAN_DEATH_1 = "rbxassetid://9125652432"
RbxAssets.HUMAN_DEATH_2 = "rbxassetid://6108566293"

--[[
    Called when the service starts.
]]
function RbxAssets:OnStart()
    self:PreloadAll()
end

--[[
    Preloads all assets in `RbxAssets.PRELOAD_DIRECTORIES`.
]]
function RbxAssets:PreloadAll()
    Rage.Logging:Info("RbxAssets:Preload(): Preloading all assets.")

    for _, directory in self.PRELOAD_DIRECTORIES do
        Rage.Logging:Info(("RbxAssets:Preload(): Preloading directory '%s'"):format(directory.Name))

        Rage.ContentProvider:PreloadAsync(directory:GetDescendants(), function(assetID: string, assetFetchStatus: Enum.AssetFetchStatus)
            Rage.Logging:Info(("RbxAssets:Preload(): Preloaded '%s' with status '%s'"):format(assetID, assetFetchStatus.Name:upper()))
        end)
    end
end

--[[
    Returns if the provided string is a valid asset ID.
]]
function RbxAssets:IsAsset(asset: string): boolean
    return Rage.Libs.String:StartsWith(asset, "rbxassetid://")
end

export type RbxAssets = typeof(RbxAssets)
return RbxAssets