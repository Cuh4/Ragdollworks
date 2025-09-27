--------------------------------------------------------
-- [Ragdollworks] Toasts
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