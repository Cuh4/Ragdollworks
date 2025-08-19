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
local Maps = require(script.Parent.Maps)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling the player's camera.
]]
Camera = Rage:Service("Camera") :: Camera
Camera.CAMERA_FOV = 2
Camera.ZOOM_Z_MULTIPLIER = 6000
Camera.CAMERA_SPEED = 0.5
Camera.CAMERA_SPEED_ZOOMED_OUT = 7
Camera.SCROLL_ZOOM_SENSITIVITY = 0.05
Camera.CAMERA_Z_OFFSET = -4500 -- due to extremely low camera fov to get a 2d effect, this offset is in place to keep the camera from being too far from the map when zoomed all the way in
Camera.MAX_ZOOM = 2

Camera.Position = Maps.MAP_POSITION
Camera.Zoom = 0
Camera.MoveFaster = false

--[[
    Called when the service starts.
]]
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

    Rage.Lighting.FogEnd = math.huge

    Rage.Camera.FieldOfView = self.CAMERA_FOV
    Rage.Camera.CameraType = Enum.CameraType.Scriptable
    Rage.Camera.CFrame = self:GetCamCFrame()
end

--[[
    Moves the camera by x and y.
]]
function Camera:Move(x: number, y: number)
    if not Maps.IsInMap then
        return
    end

    self.Position = Vector2.new(
        math.clamp(self.Position.X + x, -Maps.CurrentMap.Size.X / 2, Maps.CurrentMap.Size.X / 2),
        math.clamp(self.Position.Y + y, -Maps.CurrentMap.Size.Y / 2, Maps.CurrentMap.Size.Y / 2)
    )
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
    -- lerps from CAMERA_SPEED to CAMERA_SPEED_ZOOMED_OUT based on zoom %
    return (self.CAMERA_SPEED + (self.CAMERA_SPEED_ZOOMED_OUT - self.CAMERA_SPEED) * (self.Zoom / self.MAX_ZOOM)) * (self.MoveFaster and 2 or 1)
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
    Returns the camera's Z position based on zoom level.
]]
function Camera:GetCamZ(): number
    return ((self.Zoom + 1) * self.ZOOM_Z_MULTIPLIER) + self.CAMERA_Z_OFFSET
end

--[[
    Returns the camera's needed CFrame.
]]
function Camera:GetCamCFrame(): CFrame
    if not Maps.IsInMap then
        self.Position = Maps.MAP_POSITION
        self:SetZoom(1)

        return CFrame.new(
            self.Position.X,
            self.Position.Y,
            self:GetCamZ()
        )
    end

    return CFrame.new(
        math.clamp(self.Position.X, -Maps.CurrentMap.Size.X / 2, Maps.CurrentMap.Size.X / 2),
        math.clamp(self.Position.Y, -Maps.CurrentMap.Size.Y / 2, Maps.CurrentMap.Size.Y / 2),
        self:GetCamZ()
    )
end

--[[
    Sets the camera's zoom.
]]
function Camera:SetZoom(zoom: number)
    self.Zoom = math.clamp(zoom, 0, self.MAX_ZOOM)
end

--[[
    Locks and hides the player.
]]
function Camera:HidePlayer()
    local root: BasePart = Rage:Character().HumanoidRootPart
    root.Anchored = true
    root.CFrame = CFrame.new(0, 0, -1000) -- out of the way
end

export type Camera = typeof(Camera)
return Camera