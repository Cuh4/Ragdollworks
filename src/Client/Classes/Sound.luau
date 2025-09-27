--------------------------------------------------------
-- [Ragdollworks] Sound
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
local Trove = require(Rage.WallyPackages.trove)

local Organization = require(Rage.Path.Organization)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a sound.
]]
Sound = {} :: RSound
Sound.__index = Sound
Sound._SoundFolder = Organization:CreateFolder("Sounds", Rage.Workspace)
Sound._PlayerSoundFolder = Organization:CreateFolder("Sounds", Rage.Player)

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
        part.Parent = self._SoundFolder

        sound.Parent = part
    elseif typeof(target) == "Instance" then
        sound.Parent = target
    else
        sound.Parent = self._PlayerSoundFolder
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
    _SoundFolder: Folder,
    _PlayerSoundFolder: Folder,

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