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
local signal = require(Rage.ReplicatedStorage.Packages.signal)

local types = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a part of a spawned object.
]]
ObjectPart = {} :: types.ObjectPart
ObjectPart.__index = ObjectPart

--[[
    Creates a new ObjectPart class instance.
]]
function ObjectPart.New(part: BasePart, settings: types.ObjectPartSettings): types.ObjectPart
    local objectPart = setmetatable({}, ObjectPart) :: types.ObjectPart
    objectPart.Part = part
    objectPart.Settings = settings
    objectPart.Dragging = false
    objectPart.Frozen = false

    objectPart.OnDragStart = signal.new()
    objectPart.OnDragEnd = signal.new()
    objectPart.OnActivate = signal.new()

    return objectPart
end

--[[
    Creates a new ObjectPart class instance from a part within a spawned object.
]]
function ObjectPart.FromPart(part: BasePart): types.ObjectPart
    return ObjectPart.New(
        part,

        {
            IsDraggable = part:GetAttribute("IsDraggable") or false
        }
    )
end

--[[
    Updates the part.
]]
function ObjectPart:Update(startBound: Vector2, endBound: Vector2)
    self.Part.Anchored = self.Frozen
    self:LockZAxis()
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
    Locks the part on the Z axis.
]]
function ObjectPart:LockZAxis()
    local _, _, rotZ = self.Part.CFrame:ToEulerAnglesXYZ()
    self.Part.CFrame = CFrame.new(self.Part.CFrame.Position.X, self.Part.CFrame.Position.Y, 0) * CFrame.Angles(0, 0, rotZ)
end

--[[
    Activates the part, allowing it to be dragged.
]]
function ObjectPart:Activate()
    self.OnActivate:Fire()
end

return ObjectPart