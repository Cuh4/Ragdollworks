--------------------------------------------------------
-- [Ragdollworks] Object Part
--------------------------------------------------------

--[[
    ----------------------------

    Copyright (C) 2025 Cuh4 - All Rights Reserved
        - Unauthorized copying of this file, via any medium is strictly prohibited
        - Proprietary and confidential

    CREDIT:
        Author(s): @Cuh4 (GitHub)

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)
local signal = require(Rage.WallyPackages.signal)

local ObjectTypes = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a part of a spawned object.
]]
ObjectPart = {} :: ObjectTypes.ObjectPart
ObjectPart.__index = ObjectPart

--[[
    Creates a new ObjectPart class instance.
]]
function ObjectPart.New(part: BasePart, spawnedObject: ObjectTypes.SpawnedObject, layer: number, settings: ObjectTypes.ObjectPartSettings): ObjectTypes.ObjectPart
    local self = setmetatable({}, ObjectPart) :: ObjectTypes.ObjectPart
    self.Part = part
    self.SpawnedObject = spawnedObject
    self.Settings = settings
    self.Dragging = false
    self.Frozen = false
    self.AlignPositionInstance = nil :: AlignPosition
    self.AngularVelocityInstance = nil :: AngularVelocity
    self.AttachmentInstance = nil :: Attachment
    self.RotationForce = 0
    self.Layer = layer

    self.OnDragStart = signal.new()
    self.OnDragEnd = signal.new()
    self.OnActivate = signal.new()
    self.OnDespawn = signal.new()

    return self
end

--[[
    Creates a new ObjectPart class instance from a part within a spawned object.
]]
function ObjectPart.FromPart(part: BasePart, spawnedObject: ObjectTypes.SpawnedObject): ObjectTypes.ObjectPart
    return ObjectPart.New(
        part,
        spawnedObject,
        part:GetAttribute("Layer") or 0,

        {
            IsDraggable = part:GetAttribute("IsDraggable") or false
        }
    )
end

--[[
    Setups the part.
]]
function ObjectPart:Setup()
    self:SetupDragging()
end

--[[
    Adds dragging capabilities to the part (constraints, etc).
]]
function ObjectPart:SetupDragging()
    self.AttachmentInstance = Instance.new("Attachment")
    self.AttachmentInstance.Name = "DragAttachment"
    self.AttachmentInstance.Parent = self.Part

    self.AlignPositionInstance = Instance.new("AlignPosition")
    self.AlignPositionInstance.Name = "DragAlignPosition"
    self.AlignPositionInstance.Mode = Enum.PositionAlignmentMode.OneAttachment
    self.AlignPositionInstance.Attachment0 = self.AttachmentInstance
    self.AlignPositionInstance.MaxForce = math.huge
    self.AlignPositionInstance.Responsiveness = 50
    self.AlignPositionInstance.ApplyAtCenterOfMass = true
    self.AlignPositionInstance.Enabled = false
    self.AlignPositionInstance.Parent = self.Part

    self.AngularVelocityInstance = Instance.new("AngularVelocity")
    self.AngularVelocityInstance.Name = "DragAngularVelocity"
    self.AngularVelocityInstance.Attachment0 = self.AttachmentInstance
    self.AngularVelocityInstance.MaxTorque = math.huge
    self.AngularVelocityInstance.AngularVelocity = Vector3.new(0, 0, 0)
    self.AngularVelocityInstance.Enabled = false
    self.AngularVelocityInstance.Parent = self.Part
end

--[[
    Updates the part.
]]
function ObjectPart:Update(startBound: Vector2, endBound: Vector2, dragPosition: Vector2)
    self.Part.Anchored = self.Frozen

    self.AngularVelocityInstance.AngularVelocity = Vector3.new(0, 0, self.RotationForce)
    self.AngularVelocityInstance.Enabled = self.Dragging

    self.AlignPositionInstance.Position = Vector3.new(dragPosition.X, dragPosition.Y, 0)
    self.AlignPositionInstance.Enabled = self.Dragging

    self:Lock()
    self:KeepWithinBounds(startBound, endBound)
end

--[[
    Keeps the part within the provided bounds.
]]
function ObjectPart:KeepWithinBounds(startBound: Vector2, endBound: Vector2)
    local rotation = self.Part.CFrame - self.Part.CFrame.Position -- orientation only
    local position = self.Part.CFrame.Position

    position = Vector3.new(
        math.clamp(position.X, startBound.X, endBound.X),
        math.clamp(position.Y, startBound.Y, endBound.Y),
        position.Z
    )

    self.Part.CFrame = CFrame.new(position) * rotation
end

--[[
    Locks the part on allowed axes.
]]
function ObjectPart:Lock()
    local part = self.Part
    local _, _, rotZ = self.Part.CFrame:ToEulerAnglesXYZ()
    local posX, posY = part.CFrame.Position.X, part.CFrame.Position.Y

    self.Part.CFrame = CFrame.new(
        posX,
        posY,
        self.Layer * 0.01
    ) * CFrame.Angles(
        0,
        0,
        rotZ
    )
end

--[[
    Activates the part.
]]
function ObjectPart:Activate()
    self.OnActivate:Fire()
end

--[[
    Sets the angular velocity of the part (only works if it is being dragged).<br>
    -1 = counterclockwise, 1 = clockwise
]]
function ObjectPart:SetRotationForce(force: number)
    self.RotationForce = -force
end

--[[
    Drag the part.
]]
function ObjectPart:Drag()
    if not self.Settings.IsDraggable then
        return
    end

    if self.Dragging then
        return
    end

    self.Dragging = true
    self.OnDragStart:Fire()
end

--[[
    Stop dragging the part.
]]
function ObjectPart:StopDragging()
    if not self.Dragging then
        return
    end

    self.Dragging = false
    self:SetRotationForce(0)
    self.OnDragEnd:Fire()
end

--[[
    Returns the position of the part (2D).
]]
function ObjectPart:GetPosition(): Vector2
    return Vector2.new(self:GetPosition3D().X, self:GetPosition3D().Y)
end

--[[
    Returns the position of the part (3D).
]]
function ObjectPart:GetPosition3D(): Vector3
    return self.Part.Position
end

--[[
    Returns the velocity of the part (2D).
]]
function ObjectPart:GetVelocity(): Vector2
    return Vector2.new(self:GetVelocity3D().X, self:GetVelocity3D().Y)
end

--[[
    Returns the velocity of the part (3D).
]]
function ObjectPart:GetVelocity3D(): Vector3
    return self.Part.AssemblyLinearVelocity
end

--[[
    Despawns the part.
]]
function ObjectPart:Despawn()
    self.Part:Destroy()
    self.OnDespawn:Fire()
end

return ObjectPart