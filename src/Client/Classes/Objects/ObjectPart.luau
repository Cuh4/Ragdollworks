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
local Trove = require(Rage.WallyPackages.trove)

local ObjectTypes = require(script.Parent.Types)
local ContextMenu = require(script.Parent.ContextMenu)

local Effects = require(Rage.Path.Effects)
local Debug = require(Rage.Path.Debug)
local Maps = require(Rage.Path.Maps)

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
    self.SELECTION_COLOR = Color3.fromRGB(0, 400, 0)
    self.HIGHLIGHT_COLOR = Color3.fromRGB(50, 200, 50)
    self.FROZEN_SELECTION_BOX_COLOR = Color3.fromRGB(40, 95, 183)
    self.SELECTION_BOX_THICKNESS = 0.07
    self.DRAGGING_RESPONSIVENESS = 45
    self.IMPACT_MASS_MULTIPLIER = 0.25

    self.Part = part
    self.SpawnedObject = spawnedObject
    self.Settings = settings
    self.Dragging = false
    self.Frozen = false
    self.Paused = false
    self.SlomoLock = false
    self.Selected = false
    self.Highlighted = false
    self.AlignPositionInstance = nil :: AlignPosition
    self.AngularVelocityInstance = nil :: AngularVelocity
    self.GeneralAttachmentInstance = nil :: Attachment
    self.DraggingAttachmentInstance = nil :: Attachment
    self.SelectionBoxInstance = nil :: SelectionBox
    self.FrozenSelectionBoxInstance = nil :: SelectionBox
    self.RotationForce = 0
    self.Layer = layer
    self.ContextMenu = ContextMenu.New(self)
    self.PreviousCFrame = self.Part.CFrame

    self.Trove = Trove.new()
    self.Trove:Add(self.Part)

    self.OnDragStart = signal.new()
    self.OnDragEnd = signal.new()
    self.OnActivate = signal.new()
    self.OnDespawn = signal.new()
    self.OnCollision = signal.new()

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
    self:SetupCollisionDetection()
    self:SetupContextMenu()
    self:SetupAttachments()
    self:SetupSelectionBoxes()
    self:SetupDragging()
end

--[[
    Setups collision detection.
]]
function ObjectPart:SetupCollisionDetection()
    local connection = self.Part.Touched:Connect(function(part: BasePart)
        local ourVelocity = self:GetVelocity()
        local partVelocity = Vector2.new(part.AssemblyLinearVelocity.X, part.AssemblyLinearVelocity.Y)

        local ourPosition = self:GetPosition()
        local partPosition = Vector2.new(part.Position.X, part.Position.Y)

        local relativeVelocity =  partVelocity - ourVelocity
        local directionVector = partPosition - ourPosition

        -- if limbVelocity:Dot(directionVector) <= 0 or (partVelocity:Dot(-directionVector) <= 0 and not part.Anchored) then
        --     return
        -- end

        local partBelongsToMap = Maps:BelongsToMap(part)
        local mass = Maps:BelongsToMap(part) and 1 or part.Mass

        local impactAmount = relativeVelocity.Magnitude + (mass * self.IMPACT_MASS_MULTIPLIER)

        self.OnCollision:Fire({
            RelativeVelocity = relativeVelocity,
            RelativePosition = directionVector,
            CollidingPart = part,
            CollidingPartVelocity = partVelocity,
            CollidingPartPosition = partPosition,
            PartBelongsToMap = partBelongsToMap,
            ImpactAmount = impactAmount
        } :: ObjectTypes.ObjectPartCollisionContext)

        Debug:CreateDebugText(
            self:GetPosition(),
            ("%s: %.2f (mass: %.2f)"):format(
                self.Part.Name,
                impactAmount,
                mass
            )
        )
    end)

    self.Trove:Add(connection)
end

--[[
    Adds default context menu items.
]]
function ObjectPart:SetupContextMenu()
    self.ContextMenu:AddContextMenuItem("Despawn", function()
        self.SpawnedObject:Remove()
    end)

    self.ContextMenu:AddContextMenuItem("Activate", function()
        self:Activate()
    end)

    self.ContextMenu:AddContextMenuItem("Freeze", function()
        self:Freeze()
    end)

    self.ContextMenu:AddContextMenuItem("Unfreeze", function()
        self:Unfreeze()
    end)

    self.ContextMenu:AddContextMenuItem("Freeze All", function()
        self.SpawnedObject:Freeze()
    end)

    self.ContextMenu:AddContextMenuItem("Unfreeze All", function()
        self.SpawnedObject:Unfreeze()
    end)
end

--[[
    Adds attachments to the part.
]]
function ObjectPart:SetupAttachments()
    self.DraggingAttachmentInstance = Instance.new("Attachment")
    self.DraggingAttachmentInstance.Name = "DraggingAttachment"
    self.DraggingAttachmentInstance.Parent = self.Part
end

--[[
    Adds selection box instances to the object part.
]]
function ObjectPart:SetupSelectionBoxes()
    self.SelectionBoxInstance = Instance.new("SelectionBox")
    self.SelectionBoxInstance.Name = "Selection"
    self.SelectionBoxInstance.Adornee = self.Part
    self.SelectionBoxInstance.SurfaceTransparency = 1
    self.SelectionBoxInstance.Transparency = 0
    self.SelectionBoxInstance.LineThickness = self.SELECTION_BOX_THICKNESS
    self.SelectionBoxInstance.Visible = false
    self.SelectionBoxInstance.Parent = self.Part

    self.FrozenSelectionBoxInstance = Instance.new("SelectionBox")
    self.FrozenSelectionBoxInstance.Name = "FrozenSelection"
    self.FrozenSelectionBoxInstance.Adornee = self.Part
    self.FrozenSelectionBoxInstance.SurfaceTransparency = 1
    self.FrozenSelectionBoxInstance.Transparency = 0
    self.FrozenSelectionBoxInstance.LineThickness = self.SELECTION_BOX_THICKNESS
    self.FrozenSelectionBoxInstance.Visible = false
    self.SelectionBoxInstance.Color3 = self.FROZEN_SELECTION_BOX_COLOR
    self.FrozenSelectionBoxInstance.Parent = self.Part
end

--[[
    Adds dragging capabilities to the part (constraints, etc).
]]
function ObjectPart:SetupDragging()
    self.AlignPositionInstance = Instance.new("AlignPosition")
    self.AlignPositionInstance.Name = "DragAlignPosition"
    self.AlignPositionInstance.Mode = Enum.PositionAlignmentMode.OneAttachment
    self.AlignPositionInstance.Attachment0 = self.DraggingAttachmentInstance
    self.AlignPositionInstance.MaxForce = math.huge
    self.AlignPositionInstance.Responsiveness = self.DRAGGING_RESPONSIVENESS
    self.AlignPositionInstance.MaxVelocity = math.huge
    self.AlignPositionInstance.Enabled = false
    self.AlignPositionInstance.Parent = self.Part

    self.AngularVelocityInstance = Instance.new("AngularVelocity")
    self.AngularVelocityInstance.Name = "DragAngularVelocity"
    self.AngularVelocityInstance.Attachment0 = self.DraggingAttachmentInstance
    self.AngularVelocityInstance.MaxTorque = math.huge
    self.AngularVelocityInstance.AngularVelocity = Vector3.new(0, 0, 0)
    self.AngularVelocityInstance.Enabled = false
    self.AngularVelocityInstance.Parent = self.Part
end


--[[
    Updates dragging.
]]
function ObjectPart:UpdateDragging(dragPosition: Vector2)
    self.AngularVelocityInstance.AngularVelocity = Vector3.new(0, 0, self.RotationForce)
    self.AngularVelocityInstance.Enabled = self.Dragging and not self.Frozen

    self.AlignPositionInstance.Position = Vector3.new(dragPosition.X, dragPosition.Y, 0)
    self.AlignPositionInstance.Enabled = self.Dragging and not self.Frozen

    if self.Dragging and self.Paused then
        self.SpawnedObject:MoveTo(dragPosition)

        if self.RotationForce ~= 0 then
            self.SpawnedObject:RotateBy(self.RotationForce)
        end
    end
end

--[[
    Updates selection boxes.
]]
function ObjectPart:UpdateSelectionBoxes()
    if self.Selected then
        self.SelectionBoxInstance.Color3 = self.SELECTION_COLOR
    elseif self.Highlighted then
        self.SelectionBoxInstance.Color3 = self.HIGHLIGHT_COLOR
    end

    self.SelectionBoxInstance.Visible = self.Selected or self.Highlighted
    self.FrozenSelectionBoxInstance.Visible = self.Frozen
end

--[[
    Updates physics.
]]
function ObjectPart:UpdatePhysics(startBound: Vector2, endBound: Vector2)
    self.PreviousCFrame = self.Part.CFrame
    self.Part.Anchored = self.Frozen or self.Paused or self.SlomoLock

    self:Lock()
    self:KeepWithinBounds(startBound, endBound)
end

--[[
    Updates the part.
]]
function ObjectPart:Update(startBound: Vector2, endBound: Vector2, dragPosition: Vector2)
    self:UpdateDragging(dragPosition)
    self:UpdateSelectionBoxes()
    self:UpdatePhysics(startBound, endBound)
end

--[[
    Keeps the part within the provided bounds.
]]
function ObjectPart:KeepWithinBounds(startBound: Vector2, endBound: Vector2)
    if self.Paused then
        return
    end

    local partCFrame = self:GetCFrame()
    local position = partCFrame.Position
    local rotation = partCFrame.Rotation

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
    local partCFrame = self:GetCFrame()
    local _, _, rotZ = partCFrame:ToEulerAnglesXYZ()
    local posX, posY = partCFrame.Position.X, partCFrame.Position.Y

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
    Interpolates the part from previous CFrame to current.
]]
function ObjectPart:Interpolate(alpha: number)
    self.PreviousCFrame:Lerp(self:GetCFrame(), alpha)
end

--[[
    Activates the part.
]]
function ObjectPart:Activate()
    self.OnActivate:Fire()

    -- FX
    Effects:SpawnEffect(
        "ObjectPartActivation",
        0.07,
        self.Part
    )
end

--[[
    Sets the angular velocity of the part (only works if it is being dragged).<br>
    -1 = counterclockwise, 1 = clockwise
]]
function ObjectPart:SetRotationForce(force: number)
    self.RotationForce = -force
end

--[[
    Drag the part.<br>
    `position` is the mouse position in world space. Used to get relative position for
    dragging attachment.
]]
function ObjectPart:Drag(position: Vector2)
    if not self.Settings.IsDraggable then
        return
    end

    if self.Dragging then
        return
    end

    self.DraggingAttachmentInstance.WorldCFrame = CFrame.new(Vector3.new(
        position.X,
        position.Y,
        self.DraggingAttachmentInstance.WorldCFrame.Position.Z
    ))

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
    Freezes the part.
]]
function ObjectPart:Freeze()
    self.Frozen = true
end

--[[
    Unfreezes the part.
]]
function ObjectPart:Unfreeze()
    self.Frozen = false
end

--[[
    Sets slomo lock.
]]
function ObjectPart:SetSlomoLock()
    self.SlomoLock = true
end

--[[
    Unsets slomo lock.
]]
function ObjectPart:UnsetSlomoLock()
    self.SlomoLock = false
end

--[[
    Pauses the part.
]]
function ObjectPart:Pause()
    self.Paused = true
end

--[[
    Unpauses the part.
]]
function ObjectPart:Unpause()
    self.Paused = false
end

--[[
    Selects the part.
]]
function ObjectPart:Select()
    self.Selected = true
end

--[[
    Deselects the part.
]]
function ObjectPart:Deselect()
    self.Selected = false
end

--[[
    Highlights the part.
]]
function ObjectPart:Highlight()
    self.Highlighted = true
end

--[[
    Unhighlights the part.
]]
function ObjectPart:Unhighlight()
    self.Highlighted = false
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
    Returns the CFrame of the part.
]]
function ObjectPart:GetCFrame(): CFrame
    return self.Part.CFrame
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
    self.Trove:Destroy()
    self.OnDespawn:Fire()
end

return ObjectPart