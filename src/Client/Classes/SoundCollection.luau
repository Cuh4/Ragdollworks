--------------------------------------------------------
-- [Ragdollworks] Sound Collection
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