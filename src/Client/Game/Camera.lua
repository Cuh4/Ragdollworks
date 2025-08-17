--------------------------------------------------------
-- [Ragdollworks] Camera
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

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling the player's camera.
]]
Camera = Rage:Service("Camera") :: Camera

function Camera:OnInit()
    self.CAMERA_FOV = 2
    self.ZOOM_Z_MULTIPLIER = 6000
    self.CAMERA_SPEED = 0.5
    self.CAMERA_SPEED_ZOOMED_OUT = 10
    self.SCROLL_ZOOM_SENSITIVITY = 0.05
    self.CAMERA_Z_OFFSET = -5500

    self.Position = Vector2.new(0, 0)
    self.Zoom = 0
    self.MoveFaster = false
end

function Camera:OnStart()
    self:HandleInputEvents()

    self.HeartbeatConnection = Rage.RunService.Heartbeat:Connect(function()
        self:Update()
    end)
end

--[[
    Updates the camera.
]]
function Camera:Update()
    self:HidePlayer()
    self:HandleInputTick()

    Rage.Camera.FieldOfView = self.CAMERA_FOV
    Rage.Camera.CameraType = Enum.CameraType.Scriptable
    Rage.Camera.CFrame = self:GetCamCFrame()
end

--[[
    Moves the camera by x and y.
]]
function Camera:Move(x: number, y: number)
    self.Position = self.Position + Vector2.new(x, y)
end

--[[
    Sets whether or not to move the camera faster.
]]
function Camera:SetMoveFaster(moveFaster: boolean)
    self.MoveFaster = moveFaster
end

--[[
    Calculates the camera speed.
]]
function Camera:GetSpeed(): number
    return (self.CAMERA_SPEED + (self.CAMERA_SPEED_ZOOMED_OUT - self.CAMERA_SPEED) * self.Zoom) * (self.MoveFaster and 2 or 1)
end

--[[
    Handles camera movement from input.
]]
function Camera:HandleInputTick()
    if Rage.Input:IsKeyDown(Enum.KeyCode.W) then
        self:Move(0, self:GetSpeed())
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.S) then
        self:Move(0, -self:GetSpeed())
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.A) then
        self:Move(-self:GetSpeed(), 0)
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.D) then
        self:Move(self:GetSpeed(), 0)
    end

    self:SetMoveFaster(Rage.Input:IsKeyDown(Enum.KeyCode.LeftShift))
end

--[[
    Handles camera movement via events.
]]
function Camera:HandleInputEvents()
    Rage.Input.InputChanged:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseWheel then
            self:SetZoom(self.Zoom + -(input.Position.Z * self.SCROLL_ZOOM_SENSITIVITY))
        end
    end)
end

--[[
    Returns the camera's needed CFrame.
]]
function Camera:GetCamCFrame(): CFrame
    return CFrame.new(self.Position.X, self.Position.Y, ((self.Zoom + 1) * self.ZOOM_Z_MULTIPLIER) + self.CAMERA_Z_OFFSET)
end

--[[
    Sets the camera's zoom.
]]
function Camera:SetZoom(zoom: number)
    self.Zoom = math.clamp(zoom, 0, 1)
end

--[[
    Locks and hides the player.
]]
function Camera:HidePlayer()
    local root: BasePart = Rage:Character().HumanoidRootPart
    root.Anchored = true
    root.CFrame = CFrame.new(0, 0, -1000) -- out of the way
end

export type Camera = {
    CAMERA_FOV: number,
    ZOOM_Z_MULTIPLIER: number,
    CAMERA_SPEED: number,
    CAMERA_SPEED_ZOOM_MULTIPLIER: number,
    SCROLL_ZOOM_SENSITIVITY: number,
    CAMERA_Z_OFFSET: number,
    Position: Vector2,
    Zoom: number,
    MoveFaster: boolean
} & typeof(Camera)

return Camera