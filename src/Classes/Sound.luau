--------------------------------------------------------
-- [Ragdollworks] Sound
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

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a sound.
]]
Sound = {} :: Sound
Sound.__index = Sound

--[[
    Creates a new Sound class instance.
]]
function Sound.New(soundID: number, parentInstance: Instance?, settings: SoundSettings): Sound
    local self = setmetatable({}, Sound)
    self.SoundID = soundID
    self.ParentInstance = parentInstance
    self.Settings = settings

    self.Instance = self:CreateInstance()

    return self
end

--[[
    Creates a sound instance.
]]
function Sound:CreateInstance(): Sound
    local sound = Instance.new("Sound")

    for key, value in pairs(self.Settings) do
        sound[key] = value
    end

    sound.SoundId = "rbxassetid://" .. self.SoundID
    sound.Parent = self.ParentInstance or game.Workspace

    sound.Ended:Once(function()
        sound:Destroy()
    end)

    return sound
end

--[[
    Plays the sound.
]]
function Sound:Play()
    self.Instance:Play()
end

--[[
    Stops the sound.
]]
function Sound:Stop()
    self.Instance:Stop()
end

export type Sound = {
    SoundID: number,
    ParentInstance: Instance?,
    Settings: SoundSettings,

    Instance: Sound
} & typeof(Sound)

export type SoundSettings=  {
    RollOffMaxDistance: number,
    RollOffMinDistance: number,
    RollOffMode: Enum.RollOffMode,

    Looped: boolean,
    PlaybackRegionsEnabled: boolean,
    PlaybackSpeed: number,
    TimePosition: number,
    Volume: number,

    LoopRegion: NumberRange,
    PlaybackRegion: NumberRange,

    SoundGroup: SoundGroup
}

return Sound