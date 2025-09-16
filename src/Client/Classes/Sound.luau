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
local Trove = require(Rage.WallyPackages.trove)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a sound.
]]
Sound = {} :: RSound
Sound.__index = Sound

--[[
    Creates a new Sound class instance.
]]
function Sound.New(soundID: string, settings: SoundSettings): RSound
    local self = setmetatable({}, Sound) :: RSound
    self.SoundID = soundID
    self.Settings = settings
    self.Troves = {}

    return self
end

--[[
    Creates a sound instance.
]]
function Sound:_CreateSoundInstance(trove: Trove.Trove, modifiers: {Instance}, target: SoundTarget?): Sound
    local sound = trove:Add(Instance.new("Sound")) :: Sound
    self.Troves[sound] = trove

    for key, value in pairs(self.Settings) do
        sound[key] = value
    end

    for _, instance in pairs(modifiers) do
        instance:Clone().Parent = sound
    end

    sound.Name = self.SoundID
    sound.SoundId = self.SoundID

    if typeof(target) == "Vector2" then
        local part = trove:Add(Instance.new("Part")) :: Part
        part.Name = "SoundPart"
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.Position = Vector3.new(target.X, target.Y, 0)
        part.Size = Vector3.new(1, 1, 1)
        part.Transparency = 1
        part.Parent = Rage.Workspace

        sound.Parent = part
    elseif typeof(target) == "Instance" then
        sound.Parent = target
    else
        sound.Parent = Rage.Player
    end

    trove:Add(sound.Ended:Once(function()
        self:_CleanupSound(sound)
    end))

    trove:Add(sound.Stopped:Once(function()
        self:_CleanupSound(sound)
    end))

    trove:Add(sound.Destroying:Once(function()
        self:_CleanupSound(sound)
    end))

    return sound
end

--[[
    Cleans up a played sound.
]]
function Sound:_CleanupSound(sound: Sound)
    self.Troves[sound]:Destroy()
    self.Troves[sound] = nil
end

--[[
    Plays the sound.
]]
function Sound:Play(modifiers: {Instance}, target: SoundTarget?): RSound
    local instance = self:_CreateSoundInstance(Trove.new(), modifiers, target)
    instance:Play()

    return instance
end

export type SoundTarget = Instance | Vector2

export type RSound = typeof(Sound) & { -- RSound instead of Sound to prevent conflict with Roblox's Sound type
    SoundID: string,
    Settings: SoundSettings,
    Troves: {[Sound]: Trove.Trove}
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