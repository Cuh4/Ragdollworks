--------------------------------------------------------
-- [Ragdollworks] Camera
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

local Maps = require(Rage.Path.Maps)
local RbxAssets = require(Rage.Path.RbxAssets)
local CLI = require(Rage.Path.CLI)
local Binds = require(Rage.Path.Binds)

local Bind = require(Rage.Path.Classes.Bind)
local BindCollection = require(Rage.Path.Classes.BindCollection)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling the player's camera.
]]
Camera = Rage:Service("Camera") :: Camera
Camera.CAMERA_FOV = 30
Camera.CAMERA_SPEED = 0.2
Camera.CAMERA_SPEED_ZOOMED_OUT = 7
Camera.SCROLL_ZOOM_SENSITIVITY = 0.06
Camera.CAMERA_Z_ZOOMED_IN = 15
Camera.CAMERA_Z_ZOOMED_OUT = 500
Camera.DEFAULT_ZOOM = 0.5

Camera.Position = Maps.MAP_POSITION
Camera.Zoom = 0
Camera.MoveFaster = false
Camera.IsPanning = false

Camera.MousePosition = Vector2.new(0, 0)
Camera.MouseDelta = Vector2.new(0, 0)
Camera.MouseWorldPosition = Vector2.new(0, 0)

Camera.BindCollection = nil :: BindCollection.BindCollection

--[[
    Called when the service starts.
]]
function Camera:OnStart()
    self:_CreateCommands()
    self:HidePlayer()
    self:SetMouseIcon()
    self:CreateBinds()

    Maps.OnMapStart:Connect(function()
        self:SetZoom(self.DEFAULT_ZOOM)
    end)
end

--[[
    Called every heartbeat.
]]
function Camera:OnHeartbeat()
    Rage.Lighting.FogEnd = math.huge

    Rage.Camera.FieldOfView = self.CAMERA_FOV
    Rage.Camera.CameraType = Enum.CameraType.Scriptable
    Rage.Camera.CFrame = self:GetCamCFrame()

    self:_UpdateMousePosition(Rage.Input:GetMouseLocation())
end

--[[
    Creates camera binds.
]]
function Camera:CreateBinds()
    self.BindCollection = Binds:CreateBindCollection(
        "Camera",
        {
            Binds:CreateBind(
                "Zoom Camera",
                "Zooms the camera.",
                {Enum.UserInputType.MouseWheel},
                {ShowTouchButton = true, ShowBindUI = false},

                function(context: Bind.BindContext)
                    if context.State ~= Enum.UserInputState.Change then
                        return
                    end

                    self:SetZoom(self.Zoom + -(context.InputObject.Position.Z * self.SCROLL_ZOOM_SENSITIVITY))
                end
            ),

            Binds:CreateBind(
                "Zoom In",
                "Zooms the camera in.",
                {Enum.KeyCode.LeftBracket},
                {ShowTouchButton = true, ShowBindUI = false},
                nil,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:SetZoom(self.Zoom - self.SCROLL_ZOOM_SENSITIVITY)
                end
            ),

            Binds:CreateBind(
                "Zoom Out",
                "Zooms the camera out.",
                {Enum.KeyCode.RightBracket},
                {ShowTouchButton = true, ShowBindUI = false},
                nil,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:SetZoom(self.Zoom + self.SCROLL_ZOOM_SENSITIVITY)
                end
            ),

            Binds:CreateBind(
                "Pan Camera",
                "Pans the camera.",
                {Enum.UserInputType.MouseButton3},
                {ShowTouchButton = true, ShowBindUI = false},

                function(context: Bind.BindContext)
                    self.IsPanning = context.Bind.IsBeingPressed
                end,

                nil,

                {
                    Binds:CreateBind(
                        "Move Camera",
                        "Moves the camera when panning.",
                        {Enum.UserInputType.MouseMovement},
                        {ShowTouchButton = true, ShowBindUI = false},

                        function(context: Bind.BindContext)
                            if context.State ~= Enum.UserInputState.Change then
                                return
                            end

                            if not self.IsPanning then
                                Rage.Logging:Error("Camera: Move camera bind active when panning is false. This shouldn't be the case. FIXME!")
                            end

                            local multiplier = Rage.Libs.Math:Lerp(self.Zoom, 0.05, 0.6)
                            self:Move(-self.MouseDelta.X * multiplier, self.MouseDelta.Y * multiplier)
                        end
                    ),
                }
            ),

            Binds:CreateBind(
                "Move Camera Faster",
                "Moves the camera faster.",
                {Enum.KeyCode.LeftShift},
                {ShowTouchButton = true, ShowBindUI = false},

                function(context: Bind.BindContext)
                    self.MoveFaster = context.Bind.IsBeingPressed
                end
            ),

            Binds:CreateBind(
                "Move Left",
                "Moves the camera left.",
                {Enum.KeyCode.Left},
                {ShowTouchButton = true, ShowBindUI = false},
                nil,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:Move(-self:GetSpeed(), 0)
                end
            ),

            Binds:CreateBind(
                "Move Right",
                "Moves the camera right.",
                {Enum.KeyCode.Right},
                {ShowTouchButton = true, ShowBindUI = false},
                nil,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:Move(self:GetSpeed(), 0)
                end
            ),

            Binds:CreateBind(
                "Move Up",
                "Moves the camera up.",
                {Enum.KeyCode.Up},
                {ShowTouchButton = true, ShowBindUI = false},
                nil,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:Move(0, self:GetSpeed())
                end
            ),

            Binds:CreateBind(
                "Move Down",
                "Moves the camera down.",
                {Enum.KeyCode.Down},
                {ShowTouchButton = true, ShowBindUI = false},
                nil,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:Move(0, -self:GetSpeed())
                end
            )
        }
    )

    self.BindCollection:Enter()
end

--[[
    Updates where the mouse is.
]]
function Camera:_UpdateMousePosition(position: Vector2)
    self.MouseDelta = position - self.MousePosition
    self.MousePosition = position
    self.MouseWorldPosition = self:MouseCastRayToZ0()
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
    local root: BasePart = Rage:Character().PrimaryPart
    root.Anchored = true
    root.CFrame = CFrame.new(0, 0, -1000) -- out of the way
end

--[[
    Casts a ray from the camera's position to the mouse's position.
]]
function Camera:MouseCastRay(distance: number): RaycastResult?
    local mouseLocation = self.MousePosition
    local viewportRay = Rage.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    if viewportRay.Direction.Z == 0 then
        return nil
    end

    local direction = viewportRay.Direction * distance

    local raycastResult = Rage.Workspace:Raycast(
        viewportRay.Origin,
        direction
    )

    return raycastResult
end

--[[
    Casts a ray from the camera's position to the mouse's position, and returning ALL hit instances instead of the first.
]]
function Camera:MouseCastRayAll(distance: number): {RaycastResult}
    local mouseLocation = self.MousePosition
    local viewportRay = Rage.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    if viewportRay.Direction.Z == 0 then
        return nil
    end

    local direction = viewportRay.Direction * distance

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {}

    local found = {} :: {RaycastResult}
    local _exclude = {} :: {Instance}

    repeat
        local raycastResult = Rage.Workspace:Raycast(
            viewportRay.Origin,
            direction,
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
function Camera:MouseCastRayToZ0(): Vector2?
    local mouseLocation = self.MousePosition
    local viewportRay = Rage.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    local origin = viewportRay.Origin
    local direction = viewportRay.Direction

    if direction.Z == 0 then
        return nil
    end

    local scalar = -origin.Z / direction.Z

    if scalar < 0 then
        return nil
    end

    local hitPos = origin + direction * scalar
    return Vector2.new(hitPos.X, hitPos.Y)
end

--[[
    Creates CLI commands.
]]
function Camera:_CreateCommands()
    CLI.Conch.register("set-cam-fov", {
        description = "Sets camera FOV.",

        arguments = function()
            return CLI.Conch.args.number("FOV", "The new FOV.")
        end,

        callback = function(FOV: number)
            self.CAMERA_FOV = FOV
        end
    })

    CLI.Conch.register("set-cam-zoomed-in-z", {
        description = "Sets camera Z when all the way zoomed in.",

        arguments = function()
            return CLI.Conch.args.number("CameraZZoomedIn", "The camera Z when fully zoomed in.")
        end,

        callback = function(cameraZZoomedIn: number)
            self.CAMERA_Z_ZOOMED_IN = cameraZZoomedIn
        end
    })

    CLI.Conch.register("set-cam-zoomed-out-z", {
        description = "Sets camera Z when all the way zoomed out.",

        arguments = function()
            return CLI.Conch.args.number("CameraZZoomedOut", "The camera Z when fully zoomed out.")
        end,

        callback = function(cameraZZoomedOut: number)
            self.CAMERA_Z_ZOOMED_OUT = cameraZZoomedOut
        end
    })

    CLI.Conch.register("get-cam-values", {
        description = "Shows camera values.",
        arguments = function() end,

        callback = function()
            Rage.Logging:Info("FOV: "..self.CAMERA_FOV)
            Rage.Logging:Info("Z Zoomed In: "..self.CAMERA_Z_ZOOMED_IN)
            Rage.Logging:Info("Z Zoomed Out: "..self.CAMERA_Z_ZOOMED_OUT)
        end
    })
end

export type Camera = Rage.Service & typeof(Camera)
return Camera