--------------------------------------------------------
-- [Ragdollworks] Sound Collection
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

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
function SoundCollection.New(...: Sound.Sound): SoundCollection
    local self = setmetatable({}, SoundCollection) :: SoundCollection
    self.Sounds = {...}
    self.LastPlayedRandom = nil :: Sound.Sound

    return self
end

--[[
    Plays a random sound.
]]
function SoundCollection:PlayRandom(modifiers: {Instance}?)
    local sound = Rage.Libs.Table:GetRandom(self.Sounds) :: Sound.Sound

    if not sound then
        Rage.Logging:Error("SoundCollection:Play(): No sound found.")
    end

    if #self.Sounds >= 2 and sound == self.LastPlayedRandom then -- prevent playing same sound twice
        return self:PlayRandom(modifiers)
    end

    sound:Play(modifiers)
    self.LastPlayedRandom = sound
end

export type SoundCollection = {
    Sounds: {Sound.Sound}
} & typeof(SoundCollection)

return SoundCollection