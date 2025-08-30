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
local Maps = require(Rage.Path.Maps)
local RbxAssets = require(Rage.Path.RbxAssets)

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
Camera.SCROLL_ZOOM_SENSITIVITY = 0.02
Camera.CAMERA_Z_ZOOMED_IN = 430
Camera.CAMERA_Z_ZOOMED_OUT = 9000
Camera.DEFAULT_ZOOM = 0.5

Camera.Position = Maps.MAP_POSITION
Camera.Zoom = 0
Camera.MoveFaster = false
Camera.IsPanning = false
Camera.LastMousePosition = Vector2.new(0, 0)

Camera.MouseWorldPosition = Vector2.new(0, 0)

--[[
    Called when the service starts.
]]
function Camera:OnStart()
    self:HidePlayer()
    self:SetMouseIcon()
    self:HandleInputEvents()

    self.HeartbeatConnection = Rage.RunService.Heartbeat:Connect(function()
        self:Update()
    end)

    Maps.OnMapStart:Connect(function()
        self:SetZoom(self.DEFAULT_ZOOM)
    end)
end

--[[
    Updates the camera.
]]
function Camera:Update()
    self:HandleInputTick()

    Rage.Lighting.FogEnd = math.huge

    Rage.Camera.FieldOfView = self.CAMERA_FOV
    Rage.Camera.CameraType = Enum.CameraType.Scriptable
    Rage.Camera.CFrame = self:GetCamCFrame()

    local mouseWorldPosition = self:CastRayToZ0()

    if mouseWorldPosition then
        self.MouseWorldPosition = mouseWorldPosition
    end
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
    return Rage.Libs.Math:Lerp(self.CAMERA_SPEED, self.CAMERA_SPEED_ZOOMED_OUT, self.Zoom) * (self.MoveFaster and 2 or 1)
end

--[[
    Handles camera movement from input.
]]
function Camera:HandleInputTick()
    if Rage.Input:IsKeyDown(Enum.KeyCode.Up) then
        self:Move(0, self:GetSpeed())
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.Down) then
        self:Move(0, -self:GetSpeed())
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.Left) then
        self:Move(-self:GetSpeed(), 0)
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.Right) then
        self:Move(self:GetSpeed(), 0)
    end

    self:SetMoveFaster(Rage.Input:IsKeyDown(Enum.KeyCode.LeftShift))

    if self.IsPanning then
        local mousePos = Rage.Input:GetMouseLocation()
        local delta = mousePos - self.LastMousePosition
        local multiplier = Rage.Libs.Math:Lerp(self.Zoom, 0.05, 0.6)

        self:Move(-delta.X * multiplier, delta.Y * multiplier)

        self.LastMousePosition = mousePos
    end
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

    Rage.Input.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton3 then
            self:SetPanning(true)
        end
    end)

    Rage.Input.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton3 then
            self:SetPanning(false)
        end
    end)
end

--[[
    Sets the mouse icon.
]]
function Camera:SetMouseIcon()
    Rage.Input.MouseIcon = RbxAssets.CURSOR_ICON
end

--[[
    Sets if the camera is panning.
]]
function Camera:SetPanning(isPanning: boolean)
    self.IsPanning = isPanning

    if isPanning then
        self.LastMousePosition = Rage.Input:GetMouseLocation()
    end

    Rage.Logging:Info("Camera:SetPanning(): Panning is "..tostring(isPanning))
end

--[[
    Returns the camera's Z position based on zoom level.
]]
function Camera:GetCamZ(): number
    return Rage.Libs.Math:Lerp(
        self.CAMERA_Z_ZOOMED_IN,
        self.CAMERA_Z_ZOOMED_OUT,
        self.Zoom
    )
end

--[[
    Returns the camera's needed CFrame.
]]
function Camera:GetCamCFrame(): CFrame
    if not Maps.IsInMap then
        self.Position = Maps.MAP_POSITION

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
    if not Maps.IsInMap then
        return
    end

    self.Zoom = math.clamp(zoom, 0, 1)
    Rage.Logging:Info(("Camera:SetZoom(): Zoom set to %.2f"):format(self.Zoom))
end

--[[
    Locks and hides the player.
]]
function Camera:HidePlayer()
    local root: BasePart = Rage:Character().HumanoidRootPart
    root.Anchored = true
    root.CFrame = CFrame.new(0, 0, -1000) -- out of the way
end

--[[
    Casts a ray from the camera's position to the mouse's position.
]]
function Camera:CastRay(distance: number): RaycastResult?
    local mouseLocation = Rage.Input:GetMouseLocation()
    local viewportRay = Rage.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    return game.Workspace:Raycast(
        viewportRay.Origin,
        viewportRay.Direction * distance
    )
end

--[[
    Casts a ray from the camera's position to the mouse's position, and returning ALL hit instances instead of the first.
]]
function Camera:CastRayAll(distance: number): {RaycastResult}
    local mouseLocation = Rage.Input:GetMouseLocation()
    local viewportRay = Rage.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {}

    local found = {} :: {RaycastResult}
    local _exclude = {} :: {Instance}

    repeat
        local raycastResult = game.Workspace:Raycast(
            viewportRay.Origin,
            viewportRay.Direction * distance,
            raycastParams
        )

        if raycastResult then
            table.insert(found, raycastResult)
            table.insert(_exclude, raycastResult.Instance)

            raycastParams.FilterDescendantsInstances = _exclude
        end
    until not raycastResult

    return found
end

--[[
    Casts a ray to Z 0.
]]
function Camera:CastRayToZ0(): Vector2
    local mouseLocation = Rage.Input:GetMouseLocation()
    local viewportRay = Rage.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    local origin = viewportRay.Origin
    local direction = viewportRay.Direction

    if direction .Z == 0 then
        return nil
    end

    local scalar = -origin.Z / direction.Z

    if scalar < 0 then
        return nil
    end

    local hitPos = origin + direction * scalar
    return Vector2.new(hitPos.X, hitPos.Y)
end

export type Camera = typeof(Camera)
return Camera