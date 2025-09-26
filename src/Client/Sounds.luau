--------------------------------------------------------
-- [Ragdollworks] Sounds
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