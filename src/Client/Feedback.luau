--------------------------------------------------------
-- [Ragdollworks] Feedback
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