--------------------------------------------------------
-- [Ragdollworks] Feedback
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
    {Volume = 0.4}
) :: Sound.RSound

Feedback.InfoSound = Sounds:CreateSound(
    RbxAssets.INFO_FEEDBACK_SOUND,
    {Volume = 0.2}
) :: Sound.RSound

Feedback.NegativeSound = Sounds:CreateSound(
    RbxAssets.NEGATIVE_FEEDBACK_SOUND,
    {Volume = 0.2}
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