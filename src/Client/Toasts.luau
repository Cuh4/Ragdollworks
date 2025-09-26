--------------------------------------------------------
-- [Ragdollworks] Toasts
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

local UI = require(Rage.Path.UI)
local CLI = require(Rage.Path.CLI)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for displaying toasts/notifications.
]]
Toasts = Rage:Service("Toasts") :: Toasts
Toasts.TOAST_COMPONENT = UI:GetComponent("Toast")
Toasts.TOAST_CONTAINER = UI:GetScreenGUI("Toasts"):FindFirstChild("Container")
Toasts.ANIMATE_TIME = 0.5
Toasts.OUT_POSITION = UDim2.fromScale(-1, 0)
Toasts.IN_POSITION = UDim2.fromScale(0, 0)

--[[
    Called when the service starts.
]]
function Toasts:OnStart()
    self:_CreateCommands()
end

--[[
    Creates and displays a new toast for x seconds.
]]
function Toasts:DisplayToast(title: string, message: string, lifetime: number)
    local toast = self.TOAST_COMPONENT:Clone()
    local container = toast.Container :: Frame
    container.Position = self.OUT_POSITION
    container.TitleContainer.Title.Text = title
    container.Content.Text = message

    toast.Parent = self.TOAST_CONTAINER

    local animateIn = Rage.Tweening:Create(container, TweenInfo.new(
        self.ANIMATE_TIME,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.InOut
    ), {
        Position = self.IN_POSITION
    })

    animateIn:Play()

    local animateOut = Rage.Tweening:Create(container, TweenInfo.new(
        self.ANIMATE_TIME,
        Enum.EasingStyle.Cubic,
        Enum.EasingDirection.InOut
    ), {
        Position = self.OUT_POSITION
    })

    animateIn.Completed:Once(function()
        task.wait(lifetime - self.ANIMATE_TIME)
        animateOut:Play()
    end)

    animateOut.Completed:Once(function()
        toast:Destroy()
    end)
end

--[[
    Creates CLI commands.
]]
function Toasts:_CreateCommands()
    CLI.Conch.register("toast", {
        description = "Displays a toast.",

        arguments = function()
            return CLI.Conch.args.string("Title", "The title of the toast."),
                CLI.Conch.args.string("Message", "The message of the toast."),
                CLI.Conch.args.number("Lifetime", "The lifetime of the toast in seconds.")
        end,

        callback = function(title: string, message: string, lifetime: number)
            self:DisplayToast(title, message, lifetime)
        end
    })
end

export type Toasts = Rage.Service & typeof(Toasts)
return Toasts