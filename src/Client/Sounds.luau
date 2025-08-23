--------------------------------------------------------
-- [Ragdollworks] Sounds
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local Sound = require(Rage.ReplicatedStorage.Classes.Sound)

local CLI = require(script.Parent.CLI)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for playing sounds.
]]
Sounds = Rage:Service("Sounds"):: Sounds

--[[
    Called when the service starts.
]]
function Sounds:OnStart()
    self:_CreateCommands()
end

--[[
    Creates a new sound.
]]
function Sounds:CreateSound(soundID: number, settings: Sound.SoundSettings, parentInstance: Instance?)
    return Sound.New(soundID, settings, parentInstance)
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
            self:CreateSound(soundID, {}):Play()
        end
    })
end

export type Sounds = typeof(Sounds)
return Sounds