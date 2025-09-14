--------------------------------------------------------
-- [Ragdollworks] Wire Target
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

local ObjectPart = require(script.Parent.ObjectPart)
local ObjectTypes = require(script.Parent.Types)

local WireTargetType = require(Rage.ReplicatedStorage.Enums.WireTargetType)

local Debug = require(Rage.Path.Debug)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a target for a wire (part, position, etc).
]]
WireTarget = {} :: ObjectTypes.WireTarget
WireTarget.__index = WireTarget

--[[
    Creates a new WireTarget class instance.
]]
function WireTarget.New(target: ObjectTypes.WireTargetInstance): ObjectTypes.WireTarget
    local self = setmetatable({}, WireTarget) :: ObjectTypes.WireTarget
    self.Target = target
    self.Part = nil
    self.Attachment = nil

    if typeof(target) == "Vector2" then
        self.Part = self:_CreateWorldPart()
        self.Type = WireTargetType.WORLD
    elseif Rage.Libs.Classes:IsClassInstance(target, ObjectPart) then
        self.Part = target.Part
        self.Type = WireTargetType.OBJECT_PART
    else
        Rage.Logging:Error("WireTarget.New(): Invalid target type.")
    end

    return self
end

--[[
    Creates a part for world positions.<br>
    Useful for wires that require parts instead of attachments.
]]
function WireTarget:_CreateWorldPart(): BasePart
    local part = Instance.new("Part")
    part.Name = "WireWorldPart"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Transparency = 1
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Parent = Rage.Workspace

    return part
end

--[[
    Returns the position of this wire target.
]]
function WireTarget:GetPosition(): Vector2
    local position = self.Attachment.WorldCFrame.Position
    return Vector2.new(position.X, position.Y, 0)
end

--[[
    Creates an attachment for this wire target.
]]
function WireTarget:CreateAttachment(mousePos: Vector2): Attachment
    self.Attachment = Instance.new("Attachment")
    self.Attachment.Name = "WireAttachment"

    if self.Type == WireTargetType.WORLD then
        self.Attachment.WorldCFrame = CFrame.new(Vector3.new(self.Target.X, self.Target.Y, 0))
        self.Attachment.Parent = Rage.Workspace.Terrain
    elseif self.Type == WireTargetType.OBJECT_PART then
        self.Attachment.Parent = self.Target.Part -- important parent is set first!
        self.Attachment.WorldCFrame = CFrame.new(Vector3.new(mousePos.X, mousePos.Y, self.Attachment.WorldCFrame.Z))
    end

    Debug:CreateDebugPart(self.Attachment.WorldCFrame)

    return self.Attachment
end

--[[
    Returns if this target belongs to the provided object part.
]]
function WireTarget:BelongsTo(objectPart: ObjectTypes.ObjectPart): boolean
    return self.Type == WireTargetType.OBJECT_PART and self.Target == objectPart
end

--[[
    Cleans up this wire target.
]]
function WireTarget:Cleanup()
    if self.Attachment then
        self.Attachment:Destroy()
    end

    if self.Type == WireTargetType.WORLD then
        self.Part:Destroy()
    end
end

return WireTarget