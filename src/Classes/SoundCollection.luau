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

    return self
end

--[[
    Plays a random sound.
]]
function SoundCollection:PlayRandom()
    local sound = Rage.Libs.Table:GetRandom(self.Sounds) :: Sound

    if not sound then
        Rage.Logging:Error("SoundCollection:Play(): No sound found.")
    end

    sound:Play()
end

export type SoundCollection = {
    Sounds: {Sound}
} & typeof(SoundCollection)

return SoundCollection