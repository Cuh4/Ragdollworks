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
function Sound.New(soundID: string, settings: SoundSettings): Sound
    local self = setmetatable({}, Sound) :: Sound
    self.SoundID = soundID
    self.Settings = settings
    self.Instances = {}

    return self
end

--[[
    Creates a sound instance.
]]
function Sound:CreateInstance(modifiers: {Instance}?): Sound
    local sound = Instance.new("Sound")

    for key, value in pairs(self.Settings) do
        sound[key] = value
    end

    if modifiers then
        for _, instance in pairs(modifiers) do
            instance:Clone().Parent = sound
        end
    end

    sound.Name = self.SoundID
    sound.SoundId = self.SoundID
    sound.Parent = Rage.Player

    local endedConnection, stoppedConnection

    endedConnection = sound.Ended:Once(function()
        sound:Destroy()
        stoppedConnection:Disconnect()
    end)

    stoppedConnection = sound.Stopped:Once(function()
        sound:Destroy()
        endedConnection:Disconnect()
    end)

    return sound
end

--[[
    Plays the sound.
]]
function Sound:Play(modifiers: {Instance}?): Sound
    local instance = self:CreateInstance(modifiers)
    table.insert(self.Instances, instance)

    instance:Play()

    return instance
end

export type Sound = typeof(Sound) & {
    SoundID: string,
    Settings: SoundSettings,
    Instances: {Sound}
}

export type SoundSettings = {
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