--------------------------------------------------------
-- [Ragdollworks] Sounds
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
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local Sound = require(Rage.Path.Classes.Sound)
local SoundCollection = require(Rage.Path.Classes.SoundCollection)

local CLI = require(Rage.Path.CLI)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for playing sounds.
]]
Sounds = Rage:Service("Sounds") :: Sounds
Sounds.ROLLOFF_OFFSET = 500

--[[
    Called when the service starts.
]]
function Sounds:OnStart()
    self:_CreateCommands()
end

--[[
    Creates a sound modifier and applies the given properties to it.<br>
    The instance can then be passed to `Sound:Play(...)`.
]]
function Sounds:CreateSoundModifier(className: string, properties: {[string]: any}): Instance
    local modifier = Instance.new(className)

    for key, value in pairs(properties) do
        modifier[key] = value
    end

    return modifier
end

--[[
    Creates a new sound collection.
]]
function Sounds:CreateSoundCollection(...: Sound.RSound): SoundCollection.SoundCollection
    return SoundCollection.New(...)
end

--[[
    Creates a new sound.
]]
function Sounds:CreateSound(soundID: number, settings: Sound.SoundSettings): Sound.RSound
    local sound = Sound.New(soundID, settings)
    sound.Settings.RollOffMaxDistance = (sound.Settings.RollOffMaxDistance or 0) + self.ROLLOFF_OFFSET

    return sound
end

--[[
    Creates CLI commands.
]]
function Sounds:_CreateCommands()
    CLI.Conch.register("sound", {
        description = "Plays a sound.",

        arguments = function()
            return CLI.Conch.args.number("SoundID", "The sound ID.")
        end,

        callback = function(soundID: number)
            self:CreateSound(soundID, {}):Play({})
        end
    })
end

export type Sounds = Rage.Service & typeof(Sounds)
return Sounds