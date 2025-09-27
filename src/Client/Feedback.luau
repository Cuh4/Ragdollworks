--------------------------------------------------------
-- [Ragdollworks] Feedback
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

local Sounds = require(Rage.Path.Sounds)
local RbxAssets = require(Rage.Path.RbxAssets)

local Sound = require(Rage.Path.Classes.Sound)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for giving the user live feedback.
]]
Feedback = Rage:Service("Feedback") :: Feedback

Feedback.PositiveSound = Sounds:CreateSound(
    RbxAssets.POSITIVE_FEEDBACK_SOUND,
    {Volume = 0.03}
) :: Sound.RSound

Feedback.InfoSound = Sounds:CreateSound(
    RbxAssets.INFO_FEEDBACK_SOUND,
    {Volume = 0.03}
) :: Sound.RSound

Feedback.NegativeSound = Sounds:CreateSound(
    RbxAssets.NEGATIVE_FEEDBACK_SOUND,
    {Volume = 0.03}
) :: Sound.RSound

--[[
    Plays a postiive feedback sound.
]]
function Feedback:GivePositive(pitch: number?)
    self.PositiveSound:Play({
        Sounds:CreateSoundModifier("PitchShiftSoundEffect", {
            Octave = pitch or 1
        })
    })
end

--[[
    Gives an info feedback sound.
]]
function Feedback:GiveInfo(pitch: number?)
    self.InfoSound:Play({
        Sounds:CreateSoundModifier("PitchShiftSoundEffect", {
            Octave = pitch or 1
        })
    })
end

--[[
    Plays a negative feedback sound.
]]
function Feedback:GiveNegative(pitch: number?)
    self.NegativeSound:Play({
        Sounds:CreateSoundModifier("PitchShiftSoundEffect", {
            Octave = pitch or 1
        })
    })
end

export type Feedback = Rage.Service & typeof(Feedback)
return Feedback