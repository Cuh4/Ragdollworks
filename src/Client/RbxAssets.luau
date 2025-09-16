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

RbxAssets.HUMAN_HEAVY_GORY_IMPACT_1 = "rbxassetid://105517372211480"

RbxAssets.HUMAN_GRUNT_1 = "rbxassetid://72066124844939"
RbxAssets.HUMAN_GRUNT_2 = "rbxassetid://4596892095"
RbxAssets.HUMAN_GRUNT_3 = "rbxassetid://93792621035094"

RbxAssets.HUMAN_DEATH_1 = "rbxassetid://9125652432"
RbxAssets.HUMAN_DEATH_2 = "rbxassetid://6108566293"

RbxAssets.BLEEDING_SOUND = "rbxassetid://95168252930081"

RbxAssets.POSITIVE_FEEDBACK_SOUND = "rbxassetid://116995696565929"
RbxAssets.INFO_FEEDBACK_SOUND = "rbxassetid://17582299860"
RbxAssets.NEGATIVE_FEEDBACK_SOUND = "rbxassetid://7441284478"

RbxAssets.BIND_ICONS = { -- https://devforum.roblox.com/t/images-for-almost-every-keycode-and-userinputtype/2932907
    [Enum.KeyCode.U] = "rbxassetid://17164171424",
    [Enum.KeyCode.Five] = "rbxassetid://17164184242",
    [Enum.KeyCode.B] = "rbxassetid://17164182862",
    [Enum.UserInputType.MouseWheel] = "rbxassetid://17164175886",
    [Enum.KeyCode.Insert] = "rbxassetid://17164177453",
    [Enum.KeyCode.W] = "rbxassetid://17164171052",
    [Enum.KeyCode.F9] = "rbxassetid://17164179222",
    [Enum.KeyCode.PageUp] = "rbxassetid://17164174200",
    [Enum.KeyCode.Three] = "rbxassetid://17164184445",
    [Enum.KeyCode.Plus] = "rbxassetid://17164174067",
    [Enum.KeyCode.Asterisk] = "rbxassetid://17164183034",
    [Enum.KeyCode.RightBracket] = "rbxassetid://17164182331",
    [Enum.KeyCode.F2] = "rbxassetid://17164180129",
    [Enum.KeyCode.F12] = "rbxassetid://17164178634",
    [Enum.KeyCode.Space] = "rbxassetid://17164171928",
    [Enum.KeyCode.S] = "rbxassetid://17164172818",
    [Enum.KeyCode.Up] = "rbxassetid://17164171320",
    [Enum.KeyCode.Four] = "rbxassetid://17164184342",
    [Enum.KeyCode.O] = "rbxassetid://17164174938",
    [Enum.KeyCode.F11] = "rbxassetid://17164178865",
    [Enum.KeyCode.H] = "rbxassetid://17164177748",
    [Enum.KeyCode.LessThan] = "rbxassetid://17164177063",
    [Enum.KeyCode.Return] = "rbxassetid://17164180817",
    [Enum.KeyCode.F6] = "rbxassetid://17164179581",
    [Enum.KeyCode.F5] = "rbxassetid://17164179726",
    [Enum.KeyCode.V] = "rbxassetid://17164171198",
    [Enum.KeyCode.Question] = "rbxassetid://17164185563",
    [Enum.KeyCode.Nine] = "rbxassetid://17164183617",
    [Enum.KeyCode.L] = "rbxassetid://17164176934",
    [Enum.KeyCode.X] = "rbxassetid://17164170805",
    [Enum.KeyCode.Semicolon] = "rbxassetid://17164172533",
    [Enum.UserInputType.MouseMovement] = "rbxassetid://17164175520",
    [Enum.KeyCode.One] = "rbxassetid://17164184706",
    [Enum.KeyCode.G] = "rbxassetid://17164177883",
    [Enum.KeyCode.N] = "rbxassetid://17164175216",
    [Enum.KeyCode.Escape] = "rbxassetid://17164180538",
    [Enum.KeyCode.LeftBracket] = "rbxassetid://17164182420",
    [Enum.UserInputType.MouseButton3] = "rbxassetid://17164176366",
    [Enum.KeyCode.Zero] = "rbxassetid://17164184873",
    [Enum.KeyCode.Seven] = "rbxassetid://17164183931",
    [Enum.KeyCode.RightAlt] = "rbxassetid://17164183213",
    [Enum.KeyCode.Z] = "rbxassetid://17164170232",
    [Enum.KeyCode.M] = "rbxassetid://17164176674",
    [Enum.KeyCode.Six] = "rbxassetid://17164184131",
    [Enum.KeyCode.C] = "rbxassetid://17164182218",
    [Enum.KeyCode.Backspace] = "rbxassetid://17164182513",
    [Enum.KeyCode.F] = "rbxassetid://17164180448",
    [Enum.UserInputType.MouseButton2] = "rbxassetid://17164176250",
    [Enum.KeyCode.End] = "rbxassetid://17164181281",
    [Enum.KeyCode.KeypadPlus] = "rbxassetid://17164173955",
    [Enum.KeyCode.Minus] = "rbxassetid://17164176583",
    [Enum.KeyCode.Eight] = "rbxassetid://17164183773",
    [Enum.KeyCode.Print] = "rbxassetid://17164173817",
    [Enum.KeyCode.NumLock] = "rbxassetid://17164175073",
    [Enum.KeyCode.Tilde] = "rbxassetid://17164171596",
    [Enum.KeyCode.T] = "rbxassetid://17164171856",
    [Enum.KeyCode.Q] = "rbxassetid://17164173679",
    [Enum.KeyCode.Down] = "rbxassetid://17164181555",
    [Enum.KeyCode.Right] = "rbxassetid://17164173155",
    [Enum.KeyCode.Two] = "rbxassetid://17164184536",
    [Enum.KeyCode.R] = "rbxassetid://17164173353",
    [Enum.KeyCode.E] = "rbxassetid://17164181436",
    [Enum.KeyCode.Y] = "rbxassetid://17164170504",
    [Enum.KeyCode.Slash] = "rbxassetid://17164172092",
    [Enum.KeyCode.F7] = "rbxassetid://17164179459",
    [Enum.KeyCode.PageDown] = "rbxassetid://17164174448",
    [Enum.KeyCode.A] = "rbxassetid://17164183473",
    [Enum.KeyCode.Tab] = "rbxassetid://17164171761",
    [Enum.KeyCode.GreaterThan] = "rbxassetid://17164177171",
    [Enum.KeyCode.LeftShift] = "rbxassetid://17164172459",
    [Enum.KeyCode.Backspace] = "rbxassetid://17164182687",
    [Enum.KeyCode.F4] = "rbxassetid://17164179911",
    [Enum.KeyCode.D] = "rbxassetid://17164181789",
    [Enum.KeyCode.F8] = "rbxassetid://17164179350",
    [Enum.KeyCode.F10] = "rbxassetid://17164179041",
    [Enum.KeyCode.CapsLock] = "rbxassetid://17164182096",
    [Enum.KeyCode.QuotedDouble] = "rbxassetid://17164173486",
    [Enum.KeyCode.F3] = "rbxassetid://17164180019",
    [Enum.KeyCode.P] = "rbxassetid://17164174692",
    [Enum.KeyCode.Left] = "rbxassetid://17164176834",
    [Enum.KeyCode.Home] = "rbxassetid://17164177604",
    [Enum.KeyCode.I] = "rbxassetid://17164185671",
    [Enum.KeyCode.KeypadEnter] = "rbxassetid://17164180648",
    [Enum.KeyCode.J] = "rbxassetid://17164177374",
    [Enum.KeyCode.LeftControl] = "rbxassetid://17164181979",
    [Enum.KeyCode.K] = "rbxassetid://17164177296",
    [Enum.KeyCode.F1] = "rbxassetid://17164180325",
    [Enum.KeyCode.RightShift] = "rbxassetid://17164172362",
    [Enum.UserInputType.MouseButton1] = "rbxassetid://17164176481",
    [Enum.KeyCode.Delete] = "rbxassetid://17164185786",
    [Enum.KeyCode.DPadUp] = "rbxassetid://17164632019",
    [Enum.KeyCode.ButtonR2] = "rbxassetid://17164626784",
    [Enum.KeyCode.DPadDown] = "rbxassetid://17164632333",
    [Enum.KeyCode.DPadRight] = "rbxassetid://17164632118",
    [Enum.KeyCode.ButtonY] = "rbxassetid://17164625585",
    [Enum.KeyCode.Thumbstick2] = "rbxassetid://17164629151",
    [Enum.KeyCode.Menu] = "rbxassetid://17164626282",
    [Enum.KeyCode.ButtonL1] = "rbxassetid://17164629964",
    [Enum.KeyCode.ButtonL2] = "rbxassetid://17164633611",
    [Enum.KeyCode.ButtonR1] = "rbxassetid://17164627364",
    [Enum.KeyCode.Thumbstick1] = "rbxassetid://17164631447",
    [Enum.KeyCode.ButtonX] = "rbxassetid://17164625869",
    [Enum.KeyCode.ButtonR3] = "rbxassetid://17164627156",
    [Enum.KeyCode.ButtonB] = "rbxassetid://17164632497",
    [Enum.KeyCode.ButtonA] = "rbxassetid://17164632783",
    [Enum.KeyCode.DPadLeft] = "rbxassetid://17164632209",
    [Enum.KeyCode.ButtonL3] = "rbxassetid://17164629782"
}

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

        local counts = {} :: {[Enum.AssetFetchStatus]: number}

        Rage.ContentProvider:PreloadAsync(directory:GetDescendants(), function(assetID: string, assetFetchStatus: Enum.AssetFetchStatus)
            local count = counts[assetFetchStatus] or 0
            counts[assetFetchStatus] = count + 1
        end)

        for status, count in pairs(counts) do
            Rage.Logging:Info(("%s: %s"):format(status.Name, count))
        end
    end
end

--[[
    Returns if the provided string is a valid asset ID.
]]
function RbxAssets:IsAsset(asset: string): boolean
    return Rage.Libs.String:StartsWith(asset, "rbxassetid://")
end

export type RbxAssets = Rage.Service & typeof(RbxAssets)
return RbxAssets