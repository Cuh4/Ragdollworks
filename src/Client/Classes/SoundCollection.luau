--------------------------------------------------------
-- [Ragdollworks] Sound Collection
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

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local Sound = require(script.Parent.Sound)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a collection of sounds.
]]
SoundCollection = {} :: SoundCollection
SoundCollection.__index = SoundCollection

--[[
    Creates a new SoundCollection class instance.
]]
function SoundCollection.New(...: Sound.RSound): SoundCollection
    local self = setmetatable({}, SoundCollection) :: SoundCollection
    self.Sounds = {...}
    self.LastPlayedRandom = nil :: Sound.RSound

    return self
end

--[[
    Plays a random sound.
]]
function SoundCollection:PlayRandom(modifiers: {Instance}, target: Sound.SoundTarget?)
    local sound = Rage.Libs.Table:GetRandom(self.Sounds) :: Sound.RSound

    if not sound then
        Rage.Logging:Error("SoundCollection:Play(): No sound found.")
    end

    if #self.Sounds >= 2 and sound == self.LastPlayedRandom then -- prevent playing same sound twice
        return self:PlayRandom(modifiers, target)
    end

    sound:Play(modifiers, target)
    self.LastPlayedRandom = sound
end

export type SoundCollection = typeof(SoundCollection) & {
    Sounds: {Sound.RSound}
}

return SoundCollection