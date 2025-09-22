--------------------------------------------------------
-- [Ragdollworks] Objects
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

local signal = require(Rage.WallyPackages.signal)

local CLI = require(Rage.Path.CLI)
local ID = require(Rage.Path.ID)
local Camera = require(Rage.Path.Camera)
local Maps = require(Rage.Path.Maps)
local Debug = require(Rage.Path.Debug)
local Toasts = require(Rage.Path.Toasts)
local Effects = require(Rage.Path.Effects)
local Binds = require(Rage.Path.Binds)
local Feedback = require(Rage.Path.Feedback)

local Bind = require(Rage.Path.Classes.Bind)
local BindCollection = require(Rage.Path.Classes.BindCollection)
local Object = require(Rage.Path.Classes.Objects.Object)
local SpawnedObject = require(Rage.Path.Classes.Objects.SpawnedObject)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

local ObjectPartSelectionMode = require(Rage.Path.Enums.ObjectPartSelectionMode)
local SlomoMode = require(Rage.Path.Enums.SlomoMode)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling the spawning and management of objects.<br>
    Implements dragging functionality, object spawning, wires, and more.
]]
Objects = Rage:Service("Objects") :: Objects
Objects.OBJECT_FOLDER = Rage.Assets:GetAsset("Objects")
Objects.RAY_DISTANCE = 50000

Objects.MAX_ROTATION_SPEED = 4
Objects.ROTATION_SPEED_INCREMENT = 0.01
Objects.DEFAULT_ROTATION_SPEED = 1
Objects.PAUSED_ROTATION_SPEED_MULTIPLIER = 0.8

Objects.CAMERA_FOLLOW_SMOOTH_TIME = 0.1
Objects.CAMERA_FOLLOW_MAX_SPEED = math.huge

Objects.RotationSpeed = Objects.DEFAULT_ROTATION_SPEED

Objects.DefaultObject = nil :: ObjectTypes.Object?
Objects.ExistingObjects = {} :: {string: ObjectTypes.Object}
Objects.ExistingObjectsByCategory = {} :: {string: {ObjectTypes.Object}}
Objects.Behaviours = {} :: {string: ObjectTypes.ObjectBehaviour}

Objects.SpawnedObjectCount = 0
Objects.SpawnedObjects = {} :: {number: ObjectTypes.SpawnedObject}
Objects.SelectedObjectParts = {} :: {ObjectTypes.ObjectPart}
Objects.HighlightedPart = nil :: ObjectTypes.ObjectPart?

Objects.EntityHistory = {} :: {ObjectTypes.Entity}

Objects.IsFollowing = false
Objects._CameraFollowVelocity = Vector2.zero

Objects.IsDragging = false
Objects.DraggingPart = nil :: ObjectTypes.ObjectPart

Objects.SelectedObject = nil :: ObjectTypes.Object?
Objects.SelectionMode = ObjectPartSelectionMode.SMALLEST :: ObjectPartSelectionMode.ObjectPartSelectionMode

Objects.ContextMenuActivePart = nil :: ObjectTypes.ObjectPart?

Objects.DefaultWire = nil :: ObjectTypes.Wire?
Objects.ExistingWires = {} :: {string: ObjectTypes.Wire}
Objects.SelectedWire = nil :: ObjectTypes.Wire?
Objects.SelectedWireSource = nil :: ObjectTypes.WireTargetInstance?
Objects.SelectedWireSourceMousePos = nil :: Vector2?
Objects.SpawnedWires = {} :: {ObjectTypes.SpawnedWire}

Objects.Paused = false
Objects.DetailView = false
Objects.SlowMotion = false
Objects.SlomoSpeed = 0.5
Objects.SlomoMode = SlomoMode.FREEZING :: SlomoMode.SlomoMode

Objects.BindCollection = nil :: BindCollection.BindCollection
Objects.HighlightRequiredBindCollection = nil :: BindCollection.BindCollection
Objects.SelectionRequiredBindCollection = nil :: BindCollection.BindCollection
Objects.DraggingRequiredBindCollection = nil :: BindCollection.BindCollection

Objects.OnSpawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnDespawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnObjectSelect = signal.new() :: signal.Signal<ObjectTypes.Object>
Objects.OnWireSelect = signal.new() :: signal.Signal<ObjectTypes.Wire>
Objects.OnPauseStateChange = signal.new() :: signal.Signal<boolean>
Objects.OnSlomoStateChange = signal.new() :: signal.Signal<boolean>
Objects.OnDetailViewStateChange = signal.new() :: signal.Signal<boolean>

--[[
    Called when the service starts.
]]
function Objects:OnStart()
    self:CreateBinds()
    self:LoadBehaviours()
    self:LoadWires()
    self:LoadObjects()

    self:_CreateCommands()

    Maps.OnMapStart:Connect(function()
        self:OnMapStart()
    end)

    Maps.OnMapExit:Connect(function()
        self:OnMapExit()
    end)
end

--[[
    Called every heartbeat.
]]
function Objects:OnHeartbeat(deltaTime: number)
    if not Maps.IsInMap then
        return
    end

    self:UpdateSpawnedObjects(deltaTime)
    self:UpdateSpawnedWires()
    self:UpdateCamera(deltaTime)
    self:UpdateObjectPartHighlighting()
end

--[[
    Creates all keybinds.
]]
function Objects:CreateBinds()
    self.BindCollection = Binds:CreateBindCollection(
        "Objects",
        {
            Binds:CreateBind(
                "Select/Drag Part",
                "Selects and drags the part under the mouse.",
                {Enum.UserInputType.MouseButton1},
                {ShowTouchButton = false},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:SelectHighlightedObjectPart(not Rage.Input:IsKeyDown(Enum.KeyCode.LeftShift))
                        self:DragHighlightedPart()

                        if not self.HighlightedPart then
                            self:HideContextMenu()
                        end
                    else
                        self:StopDragging()
                    end
                end
            ),

            Binds:CreateBind(
                "Spawn Object",
                "Spawns an object.",
                {Enum.KeyCode.E},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:PlayerSpawnObject()
                    end
                end
            ),

            Binds:CreateBind(
                "Toggle Slow Motion",
                "Toggles slow motion.",
                {Enum.KeyCode.G},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:PlayerToggleSlowMotion()
                    end
                end
            ),

            Binds:CreateBind(
                "Undo",
                "Undoes the last action.",
                {Enum.KeyCode.Z},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        self:Undo()
                    end
                end
            ),

            Binds:CreateBind(
                "Wire",
                "Wires two things together.",
                {Enum.KeyCode.T},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:PlayerBeginWiring()
                    else
                        self:PlayerStopWiring()
                    end
                end
            ),

            Binds:CreateBind(
                "Toggle Pause",
                "Toggles paused state.",
                {Enum.KeyCode.Space},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:PlayerTogglePaused()
                    end
                end
            ),

            Binds:CreateBind(
                "Detail View",
                "Toggles detail view.",
                {Enum.KeyCode.S},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:PlayerToggleDetailView()
                    end
                end
            )
        }
    ) :: BindCollection.BindCollection

    self.HighlightRequiredBindCollection = Binds:CreateBindCollection(
        "Object Highlight",
        {
            Binds:CreateBind(
                "Show Context Menu",
                "Shows a context menu for the selected part(s).",
                {Enum.UserInputType.MouseButton2},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:SelectHighlightedObjectPart(true)
                        self:PlayerHandleContextMenu()
                    end
                end
            ),

            Binds:CreateBind(
                "Pipette",
                "Pipettes an object.",
                {Enum.KeyCode.Y},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:PlayerPipette()
                    end
                end
            ),

            Binds:CreateBind(
                "Activate Part",
                "Activates the part under the mouse.",
                {Enum.KeyCode.F},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:ActivateHighlightedPart()
                    end
                end
            ),
        }
    ) :: BindCollection.BindCollection

    self.SelectionRequiredBindCollection = Binds:CreateBindCollection(
        "Object Selected",
        {
            Binds:CreateBind(
                "Follow",
                "Toggles whether the camera follows the selected parts.",
                {Enum.KeyCode.U},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:SetFollowing(not self.IsFollowing)
                    end
                end
            ),

            Binds:CreateBind(
                "Delete Object",
                "Deletes the selected objects.",
                {Enum.KeyCode.Delete},
                {ShowTouchButton = true},

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self:DespawnSelectedObjects()
                    end
                end
            )
        }
    ) :: BindCollection.BindCollection

    self.DraggingRequiredBindCollection = Binds:CreateBindCollection(
        "Object Dragging",

        {
            Binds:CreateBind(
                "Rotate Part Left",
                "Rotates the selected part counterclockwise.",
                {Enum.KeyCode.A},
                {ShowTouchButton = true},
                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        return
                    end

                    self:RotateDraggedPart(0)
                end,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:RotateDraggedPart(-1)
                end
            ),

            Binds:CreateBind(
                "Rotate Part Right",
                "Rotates the selected part clockwise.",
                {Enum.KeyCode.D},
                {ShowTouchButton = true},
                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        return
                    end

                    self:RotateDraggedPart(0)
                end,

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    self:RotateDraggedPart(1)
                end
            ),

            Binds:CreateBind(
                "Rotate Faster",
                "Rotates the selected part faster.",
                {Enum.KeyCode.LeftShift},
                {ShowTouchButton = true},
                nil,

                function(context: Bind.BindContext)
                    if context.Bind.IsBeingPressed then
                        self.RotationSpeed = self.RotationSpeed + self.ROTATION_SPEED_INCREMENT
                    else
                        self.RotationSpeed = self.DEFAULT_ROTATION_SPEED
                    end
                end
            )
        }
    ) :: BindCollection.BindCollection
end

--[[
    Handles when the map is entered.
]]
function Objects:OnMapStart()
    self.BindCollection:Enter()

    if self.DefaultObject then
        self:SelectObject(self.DefaultObject)
    end

    if self.DefaultWire then
        self:SelectWire(self.DefaultWire)
    end
end

--[[
    Handles when the map is exited.
]]
function Objects:OnMapExit()
    self.BindCollection:Exit()
    self:DespawnAllObjects()
end

--[[
    Sets slow motion.
]]
function Objects:SetSlowMotion(slowMotion: boolean)
    self.SlowMotion = slowMotion
    self.OnSlomoStateChange:Fire(self.SlowMotion)

    Rage.Logging:Info("Objects:SetSlowMotion(): Slow motion: "..tostring(self.SlowMotion))
end

--[[
    Toggles slow motion (player-driven).
]]
function Objects:PlayerToggleSlowMotion()
    self:SetSlowMotion(not self.SlowMotion)

    Toasts:DisplayToast(
        "Slo-Mo",
        "Slow motion is now "..(self.SlowMotion and "enabled" or "disabled")..".",
        2
    )

    if self.SlowMotion then
        Feedback:GivePositive(0.6)
    else
        Feedback:GivePositive(1.6)
    end
end

--[[
    Sets the slow motion speed.
]]
function Objects:SetSlowMotionSpeed(slowMotionSpeed: number)
    self.SlomoSpeed = math.clamp(slowMotionSpeed, 0, 1)
    Rage.Logging:Info("Objects:SetSlowMotionSpeed(): Slow motion speed: "..tostring(self.SlomoSpeed))
end

--[[
    Handles pipetting (player-driven).
]]
function Objects:PlayerPipette()
    if not self.HighlightedPart then
        Toasts:DisplayToast(
            "Pipette",
            "Hover your mouse over a part to pipette.",
            2
        )

        return
    end

    self:PipetteHighlightedPart()
end

--[[
    Sets the selected object as the object of the provided part.
]]
function Objects:Pipette(objectPart: ObjectTypes.ObjectPart)
    self:SelectObject(objectPart.SpawnedObject.Object)
    Rage.Logging:Info("Objects:Pipette(): Pipetting "..objectPart.SpawnedObject.Object.Name)
end

--[[
    Sets the selected object as the object of the highlighted part.
]]
function Objects:PipetteHighlightedPart()
    if not self.HighlightedPart then
        Rage.Logging:Warn("Objects:PipetteHighlightedPart(): Attempted to pipette highlighted part, but no part is highlighted.")
        return
    end

    self:Pipette(self.HighlightedPart)
end

--[[
    Sets detail view.
]]
function Objects:SetDetailView(detailView: boolean)
    self.DetailView = detailView
    self.OnDetailViewStateChange:Fire(self.DetailView)

    Rage.Logging:Info("Objects:SetDetailView(): Detail view: "..tostring(self.DetailView))
end

--[[
    Toggles detail view (player-driven).
]]
function Objects:PlayerToggleDetailView()
    self:SetDetailView(not self.DetailView)
end

--[[
    Manages context menu showing/hiding (player-driven).
]]
function Objects:PlayerHandleContextMenu()
    if self.ContextMenuActivePart then
        self:HideContextMenu()
    end

    if not self.HighlightedPart then
        return
    end

    self:ShowContextMenu(self.HighlightedPart)
end

--[[
    Shows the context menu for provided part.
]]
function Objects:ShowContextMenu(part: ObjectTypes.ObjectPart)
    if self.ContextMenuActivePart then
        Rage.Logging:Warn("Objects:ShowContextMenu(): Attempted to show context menu, but another part has context menu active.")
        return
    end

    local screenPosition = Rage.Camera:WorldToScreenPoint(part:GetPosition3D())
    part.ContextMenu:Show(UDim2.fromOffset(screenPosition.X, screenPosition.Y))

    part.ContextMenu.OnHide:Once(function()
        self:DeregisterContextMenuActivePart()
    end)

    self.ContextMenuActivePart = part

    Rage.Logging:Info("Objects:ShowContextMenu(): Showing context menu.")
end

--[[
    Returns if the provided part has their context menu active and recognised.
]]
function Objects:HasContextMenuActive(part: ObjectTypes.ObjectPart): boolean
    return self.ContextMenuActivePart == part
end

--[[
    Deregisters the active context menu part.
]]
function Objects:DeregisterContextMenuActivePart()
    if not self.ContextMenuActivePart then
        return
    end

    self.ContextMenuActivePart = nil
end

--[[
    Hides the context menu.
]]
function Objects:HideContextMenu()
    if not self.ContextMenuActivePart then
        Rage.Logging:Warn("Objects:HideContextMenu(): Attempted to hide context menu, but no part has context menu active.")
        return
    end

    self.ContextMenuActivePart.ContextMenu:Hide()
    self.ContextMenuActivePart = nil

    Rage.Logging:Info("Objects:HideContextMenu(): Hiding context menu.")
end

--[[
    Toggles whether the physics of all spawned objects are paused.
]]
function Objects:PlayerTogglePaused()
    if not Maps.IsInMap then
        return
    end

    if self.Paused then
        self:UnpauseAllSpawnedObjects()
    else
        self:PauseAllSpawnedObjects()
    end
end

--[[
    Pauses the physics of all spawned objects.
]]
function Objects:PauseAllSpawnedObjects()
    if self.Paused then
        Rage.Logging:Warn("Objects:PauseAllSpawnedObjects(): Attempted to pause all spawned objects when already paused.")
        return
    end

    self.Paused = true

    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        spawnedObject:Pause()
    end

    self.OnPauseStateChange:Fire(self.Paused)

    Toasts:DisplayToast(
        "Objects",
        "All object physics have been paused.",
        2
    )

    Feedback:GivePositive(0.4)
end

--[[
    Unpauses the physics of all spawned objects.
]]
function Objects:UnpauseAllSpawnedObjects()
    if not self.Paused then
        Rage.Logging:Warn("Objects:UnpauseAllSpawnedObjects(): Attempted to unpause all spawned objects when not paused.")
        return
    end

    self.Paused = false

    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        spawnedObject:Unpause()
    end

    self.OnPauseStateChange:Fire(self.Paused)

    Toasts:DisplayToast(
        "Objects",
        "All object physics have been unpaused.",
        2
    )

    Feedback:GivePositive(1.8)
end

--[[
    Rotates the currently-dragged part. -1 = left, 1 = right, 0 = halt rotation
]]
function Objects:RotateDraggedPart(direction: number)
    direction *= self.RotationSpeed

    if self.Paused then
        direction *= self.PAUSED_ROTATION_SPEED_MULTIPLIER
    end

    for _, part in pairs(self.SelectedObjectParts) do
        part:SetRotationForce(direction)
    end
end

--[[
    Starts dragging the provided part.
]]
function Objects:DragObjectPart(part: ObjectTypes.ObjectPart)
    if self.IsDragging then
        Rage.Logging:Warn("Objects:DragObjectPart(): Already dragging a part.")
        return
    end

    self.DraggingPart = part
    self.DraggingPart:Drag(Camera.MouseWorldPosition)

    self.DraggingRequiredBindCollection:Enter()

    self.IsDragging = true

    Rage.Logging:Info("Objects:DragObjectPart(): Started dragging part.")
end

--[[
    Drags the highlighted part.
]]
function Objects:DragHighlightedPart()
    if not self.HighlightedPart then
        Rage.Logging:Warn("Objects:DragHighlightedPart(): Attempted to drag highlighted part, but no part is highlighted.")
        return
    end

    self:DragObjectPart(self.HighlightedPart)
end

--[[
    Stops dragging the currently-dragged part.
]]
function Objects:StopDragging()
    if not self.IsDragging then
        Rage.Logging:Warn("Objects:StopDragging(): Not dragging a part.")
        return
    end

    self.DraggingPart:StopDragging()
    self.DraggingPart = nil

    self.DraggingRequiredBindCollection:Exit()

    self.IsDragging = false

    Rage.Logging:Info("Objects:StopDragging(): Stopped dragging part.")
end

--[[
    Toggles object part following.
]]
function Objects:SetFollowing(follow: boolean)
    self.IsFollowing = follow and self:IsAnyObjectPartSelected()
end

--[[
    Highlights the provided part.
]]
function Objects:HighlightPart(part: ObjectTypes.ObjectPart)
    if self.HighlightedPart == part then
        return
    end

    if self.HighlightedPart and self.HighlightedPart ~= part then
        self:UnhighlightPart()
    end

    self.HighlightedPart = part
    part:Highlight()

    self.HighlightRequiredBindCollection:Enter()

    Rage.Logging:Info("Objects:HighlightPart(): Highlighted part.")
end

--[[
    Unhighlights the currently-highlighted part.
]]
function Objects:UnhighlightPart()
    if not self.HighlightedPart then
        return
    end

    self.HighlightedPart:Unhighlight()
    self.HighlightedPart = nil

    self.HighlightRequiredBindCollection:Exit()

    Rage.Logging:Info("Objects:UnhighlightPart(): Unhighlighted part.")
end

--[[
    Returns if the provided part is highlighted.
]]
function Objects:IsPartHighlighted(part: ObjectTypes.ObjectPart): boolean
    return self.HighlightedPart == part
end

--[[
    Activates the highlighted part.
]]
function Objects:ActivateHighlightedPart()
    if not self.HighlightedPart then
        Rage.Logging:Warn("Objects:ActivateHighlightedPart(): Attempted to activate highlighted part, but no part is highlighted.")
        return
    end

    Rage.Logging:Info("Objects:ActivateHighlightedPart(): Activating part "..self.HighlightedPart.Part:GetFullName())
    self.HighlightedPart:Activate()
end

--[[
    Sets the selection mode.
]]
function Objects:SetSelectionMode(selectionMode: ObjectPartSelectionMode.ObjectPartSelectionMode)
    self.SelectionMode = selectionMode
end

--[[
    Returns the ObjectPart under the mouse, if any.
]]
function Objects:GetPartUnderMouse(): ObjectTypes.ObjectPart?
    local results = Camera:MouseCastRayAll(self.RAY_DISTANCE)
    local parts = {} :: {ObjectTypes.ObjectPart}

    -- Convert raycast results to object parts if possible
    for _, result in pairs(results) do
        local part = self:GetObjectPartFromPart(result.Instance)

        if part then
            table.insert(parts, part)
        end
    end

    if #parts <= 0 then
        return
    end

    if self.SelectionMode == ObjectPartSelectionMode.CLOSEST_LAYER then
        return Rage.Libs.Table:GetMax(parts, function(current: ObjectTypes.ObjectPart, max: ObjectTypes.ObjectPart)
            return current.Layer > max.Layer
        end)
    elseif self.SelectionMode == ObjectPartSelectionMode.FARTHEST_LAYER then
        return Rage.Libs.Table:GetMax(parts, function(current: ObjectTypes.ObjectPart, max: ObjectTypes.ObjectPart)
            return current.Layer < max.Layer
        end)
    elseif self.SelectionMode == ObjectPartSelectionMode.SMALLEST then
        return Rage.Libs.Table:GetMax(parts, function(current: ObjectTypes.ObjectPart, min: ObjectTypes.ObjectPart)
            return current.Part.Size.Magnitude < min.Part.Size.Magnitude
        end)
    elseif self.SelectionMode == ObjectPartSelectionMode.LARGEST then
        return Rage.Libs.Table:GetMax(parts, function(current: ObjectTypes.ObjectPart, max: ObjectTypes.ObjectPart)
            return current.Part.Size.Magnitude > max.Part.Size.Magnitude
        end)
    end
end

--[[
    Returns an ObjectPart from the provided part, if possible.
]]
function Objects:GetObjectPartFromPart(part: BasePart): ObjectTypes.ObjectPart?
    local spawnedObject = self:GetSpawnedObjectFromPart(part)

    if not spawnedObject then
        return
    end

    return spawnedObject:GetPart(part)
end

--[[
    Returns a SpawnedObject from the provided part, if possible.
]]
function Objects:GetSpawnedObjectFromPart(part: BasePart): ObjectTypes.SpawnedObject?
    local spawnedObjectID = part:GetAttribute("SpawnedObjectID")

    if not spawnedObjectID then
        return
    end

    return self.SpawnedObjects[spawnedObjectID]
end

--[[
    Gets an object by name.
]]
function Objects:GetObject(name: string): ObjectTypes.Object?
    return self.ExistingObjects[name]
end

--[[
    Loads all object behaviours.
]]
function Objects:LoadBehaviours()
    for _, behaviourModuleScript: ModuleScript in pairs(script.ObjectBehaviours:GetChildren()) do
        local behaviourClass = require(behaviourModuleScript)
        self:RegisterBehaviour(behaviourModuleScript.Name, behaviourClass)
    end

    Rage.Logging:Info("Objects:LoadBehaviours(): Loaded all object behaviours.")
end

--[[
    Registers a new object behaviour.
]]
function Objects:RegisterBehaviour(name: string, behaviourClass: ObjectTypes.ObjectBehaviour)
    self.Behaviours[name] = behaviourClass
    Rage.Logging:Info(("Objects:RegisterBehaviour(): Registered behaviour %s."):format(name))
end

--[[
    Begin wiring two targets (player-driven)
]]
function Objects:PlayerBeginWiring()
    if not Maps.IsInMap then
        return
    end

    if not self.SelectedWire then
        Toasts:DisplayToast(
            "Objects",
            "You need to select a wire to connect parts with.",
            2
        )

        return
    end

    self.SelectedWireSource = self.HighlightedPart or Camera.MouseWorldPosition
    self.SelectedWireSourceMousePos = Camera.MouseWorldPosition
end

--[[
    Stops wiring two targets (player-driven)
]]
function Objects:PlayerStopWiring()
    if not Maps.IsInMap then
        return
    end

    if not self.SelectedWireSource then
        Rage.Logging:Warn("Objects:PlayerStopWiring(): Attempted to stop wiring, but no source is selected.")
        return
    end

    if not self.HighlightedPart and typeof(self.SelectedWireSource) == "Vector2" then
        Toasts:DisplayToast(
            "Objects",
            "You must connect a wire to a part.",
            2
        )

        return
    end

    if self.SelectedWireSource == self.HighlightedPart then
        Toasts:DisplayToast(
            "Objects",
            "You cannot connect a part to itself.",
            2
        )

        return
    end

    self:ConnectWire(
        self.SelectedWire,
        self.SelectedWireSource,
        self.SelectedWireSourceMousePos,
        self.HighlightedPart or Camera.MouseWorldPosition,
        Camera.MouseWorldPosition
    )

    self.SelectedWireSource = nil
    self.SelectedWireSourceMousePos = nil

    Toasts:DisplayToast(
        "Objects",
        "Successfully wired up!",
        2
    )

    Feedback:GivePositive(1.1)
end

--[[
    Connects a wire to two targets.
]]
function Objects:ConnectWire(
    wire: ObjectTypes.Wire,
    targetA: ObjectTypes.WireTargetInstance,
    targetAMousePos: Vector2,
    targetB: ObjectTypes.WireTargetInstance,
    targetBMousePos: Vector2
)
    if targetA == targetB then
        Rage.Logging:Error("Objects:ConnectWire(): Attempted to connect wire to same part twice.")
    end

    if typeof(targetA) == "Vector2" and typeof(targetB) == "Vector2" then
        Rage.Logging:Error("Objects:ConnectWire(): Cannot connect a wire between two Vector2s.")
    end

    local spawnedWire = wire.WireClass.New()

    spawnedWire:Setup(
        targetA,
        targetAMousePos,
        targetB,
        targetBMousePos
    )

    table.insert(self.SpawnedWires, spawnedWire)
    self:AddToHistory(spawnedWire)

    Rage.Logging:Info("Objects:ConnectWire(): Created a new wire.")
end

--[[
    Loads all wires.
]]
function Objects:LoadWires()
    for _, wireModuleScript: ModuleScript in pairs(script.Wires:GetChildren()) do
        local wire = require(wireModuleScript) :: ObjectTypes.Wire
        self:RegisterWire(wire)
    end

    Rage.Logging:Info("Objects:LoadWires(): Loaded all wires.")
end

--[[
    Registers a new wire.
]]
function Objects:RegisterWire(wire: ObjectTypes.Wire)
    self.ExistingWires[wire.Name] = wire

    if wire.IsDefault then
        if self.DefaultWire then
            Rage.Logging:Error("Objects:RegisterWire(): Multiple default wires found!")
        end

        self:SetDefaultWire(wire)
    end

    Rage.Logging:Info(("Objects:RegisterWire(): Registered wire %s."):format(wire.Name))
end

--[[
    Retrieves a wire by name.
]]
function Objects:GetWire(name: string): ObjectTypes.Wire?
    return self.ExistingWires[name]
end

--[[
    Selects a wire to connect parts with.
]]
function Objects:SelectWire(wire: ObjectTypes.Wire)
    self.SelectedWire = wire
    self.OnWireSelect:Fire(wire)
    Rage.Logging:Info("Objects:SelectWire(): Selected wire "..wire.Name)

    Toasts:DisplayToast(
        "Wires",
        "You have selected "..wire.Name..".",
        2
    )

    Feedback:GivePositive(0.9)
end

--[[
    Removes a spawned wire.
]]
function Objects:RemoveWire(wire: ObjectTypes.SpawnedWire)
    wire:Despawn()
    Rage.Libs.Table:Remove(self.SpawnedWires, wire)
end

--[[
    Removes all wires connected to a part.
]]
function Objects:RemoveWiresFromPart(part: ObjectTypes.ObjectPart)
    if #self.SpawnedWires <= 0 then
        return
    end

    Rage.Libs.Table:IterateReverse(self.SpawnedWires, function(_, wire: ObjectTypes.SpawnedWire)
        if wire:IsConnectedToPart(part) then
            self:RemoveWire(wire)
        end
    end)
end

--[[
    Removes all wires.
]]
function Objects:RemoveAllWires()
    Rage.Libs.Table:IterateReverse(self.SpawnedWires, function(_, wire: ObjectTypes.SpawnedWire)
        self:RemoveWire(wire)
    end)
end

--[[
    Sets a wire as default.
]]
function Objects:SetDefaultWire(wire: ObjectTypes.Wire)
    if not wire.IsDefault then
        Rage.Logging:Error("Objects:SetDefaultWire(): Attempted to set a non-default wire as default.")
    end

    self.DefaultWire = wire
    Rage.Logging:Info("Objects:SetDefaultWire(): Set default wire to "..wire.Name)
end

--[[
    Sets an object as default.
]]
function Objects:SetDefaultObject(object: ObjectTypes.Object)
    if not object.IsDefault then
        Rage.Logging:Error("Objects:SetDefaultObject(): Attempted to set a non-default object as default.")
    end

    self.DefaultObject = object
    Rage.Logging:Info("Objects:SetDefaultObject(): Set default object to "..object.Name)
end

--[[
    Selects an object to spawn.
]]
function Objects:SelectObject(object: ObjectTypes.Object)
    self.SelectedObject = object
    self.OnObjectSelect:Fire(object)
    Rage.Logging:Info("Objects:SelectObject(): Selected object "..object.Name)

    Feedback:GivePositive(1.2)

    Toasts:DisplayToast(
        "Objects",
        "You have selected "..object.Name..".",
        2
    )
end

--[[
    Adds an entity to the history.
]]
function Objects:AddToHistory(entity: ObjectTypes.Entity)
    table.insert(self.EntityHistory, entity)
    Rage.Logging:Info(("Objects:AddToHistory(): Added %s to history."):format(entity:GetName()))
end

--[[
    Removes an entity from the history.
]]
function Objects:RemoveFromHistory(entity: ObjectTypes.Entity)
    Rage.Libs.Table:Remove(self.EntityHistory, entity)
    Rage.Logging:Info(("Objects:RemoveFromHistory(): Removed %s from history."):format(entity:GetName()))
end

--[[
    Returns the last entity in the history.
]]
function Objects:GetLastEntity(): ObjectTypes.Entity?
    return Rage.Libs.Table:GetLast(self.EntityHistory)
end

--[[
    Spawns an object (player-driven).
]]
function Objects:PlayerSpawnObject(position: Vector2?): ObjectTypes.SpawnedObject
    if not Maps.IsInMap then
        return
    end

    if not self.SelectedObject then
        Toasts:DisplayToast(
            "Objects",
            "You need to select an object to spawn.",
            2
        )

        return
    end

    if not self.SelectedObject:CanPlayerSpawn() then
        Toasts:DisplayToast(
            "Objects",
            "You cannot spawn this object. Not even sure how you managed to get here.",
            2
        )

        return
    end

    Toasts:DisplayToast(
        "Objects",
        "You have spawned "..self.SelectedObject.Name..".",
        2
    )

    Rage.Logging:Info("Objects:PlayerSpawnObject(): Player is spawning object "..self.SelectedObject.Name)

    Feedback:GivePositive(1.4)
    return self:SpawnObject(self.SelectedObject, position or Camera.MouseWorldPosition)
end

--[[
    Spawns an object at the specified position.
]]
function Objects:SpawnObject(object: ObjectTypes.Object, position: Vector2): ObjectTypes.SpawnedObject
    local spawnedObject = SpawnedObject.New(ID:GetID(), object)
    spawnedObject:Setup(position)
    self:_AddContextMenuItems(spawnedObject)

    if self.Paused then
        spawnedObject:Pause()
    end

    self:_RegisterSpawnedObject(spawnedObject)

    spawnedObject:StartBehaviours()

    Effects:SpawnEffect(
        "ObjectSpawn",
        0.07,
        nil,
        Vector3.new(position.X, position.Y, 0)
    )

    Rage.Logging:Info(("Objects:SpawnObject(): Spawned object %s (%s) at %s with %d parts"):format(
        object.Name,
        spawnedObject.ID,
        tostring(position),
        Rage.Libs.Table:GetLength(spawnedObject.Parts)
    ))

    return spawnedObject
end

--[[
    Adds default context menu items to a newly spawned object.
]]
function Objects:_AddContextMenuItems(spawnedObject: ObjectTypes.SpawnedObject)
    spawnedObject:AddContextMenuItem("Remove Wires", function(item)
        self:RemoveWiresFromPart(item.ContextMenu.ObjectPart)
    end)
end

--[[
    Registers a spawned object.
]]
function Objects:_RegisterSpawnedObject(spawnedObject: ObjectTypes.SpawnedObject)
    self.SpawnedObjects[spawnedObject.ID] = spawnedObject
    self:AddToHistory(spawnedObject)

    self.SpawnedObjectCount = self.SpawnedObjectCount + 1

    self.OnSpawn:Fire(spawnedObject)
end

--[[
    Despawns a spawned object.
]]
function Objects:DespawnObject(spawnedObject: ObjectTypes.SpawnedObject)
    if not self.SpawnedObjects[spawnedObject.ID] then
        Rage.Logging:Warn("Objects:DespawnObject(): Attempted to despawn an object that doesn't internally exist.")
        return
    end

    for _, part in pairs(spawnedObject.Parts) do
        if self:IsObjectPartSelected(part) then
            self:DeselectObjectPart(part)
        end

        if self:IsPartHighlighted(part) then
            self:UnhighlightPart()
        end

        if self:HasContextMenuActive(part) then
            self:HideContextMenu()
        end

        self:RemoveWiresFromPart(part)
    end

    spawnedObject:Despawn()
    self:_UnregisterSpawnedObject(spawnedObject)

    Rage.Logging:Info(("Objects:DespawnObject(): Despawned object %s (%s)"):format(spawnedObject.Object.Name, spawnedObject.ID))
end

--[[
    Unregisters a spawned object.
]]
function Objects:_UnregisterSpawnedObject(spawnedObject: ObjectTypes.SpawnedObject)
    self.SpawnedObjects[spawnedObject.ID] = nil
    self:RemoveFromHistory(spawnedObject)

    self.SpawnedObjectCount = self.SpawnedObjectCount - 1

    self.OnDespawn:Fire(spawnedObject)
end

--[[
    Despawns all spawned objects.
]]
function Objects:DespawnAllObjects()
    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        self:DespawnObject(spawnedObject)
    end
end

--[[
    Despawns the most recently spawned entity (objects, wires, etc).
]]
function Objects:Undo()
    local recent = self:GetLastEntity()

    if not recent then
        Rage.Logging:Warn("Objects:Undo(): No recent last entity.")

        Toasts:DisplayToast(
            "Objects",
            "Nothing to undo.",
            2
        )

        return
    end

    recent:Remove()
    self:RemoveFromHistory(recent)

    Toasts:DisplayToast(
        "Objects",
        "Successfully undo'd.",
        2
    )

    Feedback:GivePositive(0.75)
end

--[[
    Despawns the selected objects.
]]
function Objects:DespawnSelectedObjects()
    Rage.Libs.Table:IterateReverse(self.SelectedObjectParts, function(_, selectedPart: ObjectTypes.ObjectPart)
        self:DespawnObject(selectedPart.SpawnedObject)
    end)
end

--[[
    Selects the provided object part.
]]
function Objects:SelectObjectPart(objectPart: ObjectTypes.ObjectPart, overwrite: boolean)
    if self:IsObjectPartSelected(objectPart) then
        Rage.Logging:Warn("Objects:SelectObjectPart(): Attempted to select an object part that was already selected.")
        return
    end

    if overwrite then
        self:DeselectObjectParts()
        self.SelectedObjectParts = {objectPart}
    else
        table.insert(self.SelectedObjectParts, objectPart)
    end

    objectPart:Select()
    self.SelectionRequiredBindCollection:Enter()

    Rage.Logging:Info("Objects:SelectObjectPart(): Selected object part.")
end

--[[
    Selects the highlighted object part.
]]
function Objects:SelectHighlightedObjectPart(overwrite: boolean)
    if not self.HighlightedPart then
        Rage.Logging:Warn("Objects:SelectHighlightedObjectPart(): No highlighted part. Deselecting all (QOL).")

        self:DeselectObjectParts()
        return
    end

    if self:IsObjectPartSelected(self.HighlightedPart) then
        Rage.Logging:Warn("Objects:SelectHighlightedObjectPart(): Attempted to select an object part that was already selected. Deselecting as a QOL (if not overwrite, otherwise ignoring).")

        if not overwrite then
            self:DeselectObjectPart(self.HighlightedPart)
        end

        return
    end

    self:SelectObjectPart(self.HighlightedPart, overwrite)
end

--[[
    Deselects all selected object parts.
]]
function Objects:DeselectObjectParts()
    Rage.Libs.Table:IterateReverse(self.SelectedObjectParts, function(_, objectPart: ObjectTypes.ObjectPart)
        self:DeselectObjectPart(objectPart)
    end)
end

--[[
    Deselects a selected object part.
]]
function Objects:DeselectObjectPart(objectPart: ObjectTypes.ObjectPart)
    if not self:IsObjectPartSelected(objectPart) then
        Rage.Logging:Warn("Objects:DeselectObjectPart(): Attempted to deselect an object part that was not selected.")
        return
    end

    objectPart:Deselect()
    Rage.Libs.Table:Remove(self.SelectedObjectParts, objectPart)

    if not self:IsAnyObjectPartSelected() then
        self.SelectionRequiredBindCollection:Exit()
    end

    Rage.Logging:Info("Objects:DeselectObjectPart(): Deselected object part.")
end

--[[
    Returns if an object part is selected.
]]
function Objects:IsObjectPartSelected(objectPart: ObjectTypes.ObjectPart): boolean
    return Rage.Libs.Table:Find(self.SelectedObjectParts, objectPart) ~= nil
end

--[[
    Returns if any object part is selected.
]]
function Objects:IsAnyObjectPartSelected(): boolean
    return #self.SelectedObjectParts > 0
end

--[[
    Creates an object category if it exists.
]]
function Objects:CreateCategory(category: string): {ObjectTypes.Object}
    if not self.ExistingObjectsByCategory[category] then
        self.ExistingObjectsByCategory[category] = {}
        Rage.Logging:Info("Objects:CreateCategory(): Created new category: "..category)
    end

    return self.ExistingObjectsByCategory[category]
end

--[[
    Registers an object.
]]
function Objects:RegisterObject(object: ObjectTypes.Object)
    local category = self:CreateCategory(object.Category)
    table.insert(category, object)

    self.ExistingObjects[object.Name] = object

    if object.IsDefault then
        if self.DefaultObject ~= nil then
            Rage.Logging:Error("Objects:LoadObjects(): Multiple default objects found!")
        end

        self:SetDefaultObject(object)
    end

    Rage.Logging:Info("Objects:RegisterObject(): Registered object: "..object.Name)
end

--[[
    Loads all objects from the OBJECT_FOLDER.
]]
function Objects:LoadObjects()
    for _, objectInstance: Model in pairs(self.OBJECT_FOLDER:GetChildren()) do
        -- Check for primary part
        if not objectInstance.PrimaryPart then
            Rage.Logging:Error("Objects:LoadObjects(): Object has no primary part: "..objectInstance:GetFullName())
        end

        -- Find object behaviours this object has
        local objectBehaviours: {ObjectTypes.ObjectBehaviour} = {}

        for name: string, behaviour: ObjectTypes.ObjectBehaviour in pairs(self.Behaviours) do
            if objectInstance:GetAttribute(name.."ObjectBehaviour") then
                Rage.Logging:Info("Objects:LoadObjects(): Found behaviour for to-be-loaded object: "..name)
                table.insert(objectBehaviours, behaviour)
            end
        end

        -- Create object instance
        local object = Object.FromInstance(objectInstance, objectBehaviours)
        self:RegisterObject(object)
    end
end

--[[
    Returns if this frame is a slo-mo frame.
]]
function Objects:_IsSlowMotionFrame(): boolean
    return self.SlowMotion and Rage.ElapsedFrames % math.floor((1 / self.SlomoSpeed) + 0.5) ~= 0
end

--[[
    Performs interpolation slomo logic on an object part.
]]
function Objects:InterpolateSlomoForObjectPart(objectPart: ObjectTypes.ObjectPart, deltaTime: number)
    if not self.SlowMotion then
        return
    end

    local physicsFPS = Rage.Workspace:GetRealPhysicsFPS()
    local alpha = self.SlomoSpeed / (deltaTime * physicsFPS)

    objectPart:Interpolate(alpha) -- looks much more smoother, but gets weird with physics at <0.5x slomo scales
                                    -- also fucks up things with some types of constraints like wheels. humans are fine tho
end

--[[
    Performs freezing slomo logic on an object part.
]]
function Objects:FreezeSlomoForObjectPart(objectPart: ObjectTypes.ObjectPart)
    if not self.SlowMotion then
        if objectPart.SlomoLock then
            objectPart:UnsetSlomoLock()
        end

        return
    end

    if self:_IsSlowMotionFrame() then
        objectPart:SetSlomoLock()
    else
        objectPart:UnsetSlomoLock()
    end
end

--[[
    Handles slow motion for an object part.
]]
function Objects:HandleSlowMotionForObjectPart(objectPart: ObjectTypes.ObjectPart, deltaTime: number)
    if self.SlomoMode == SlomoMode.FREEZING then
        self:FreezeSlomoForObjectPart(objectPart)
    elseif self.SlomoMode == SlomoMode.INTERPOLATION then
        self:InterpolateSlomoForObjectPart(objectPart, deltaTime)
    elseif self.SlomoMode == SlomoMode.FREEZING_INTERPOLATION then
        self:FreezeSlomoForObjectPart(objectPart)
        self:InterpolateSlomoForObjectPart(objectPart, deltaTime)
    else
        Rage.Logging:Error("Objects:HandleSlowMotionForObjectPart(): Unknown slomo mode: "..tostring(self.SlomoMode))
    end
end

--[[
    Handles slow motion for all object parts of a spawned object.<br>
    oopsies for the very verbose name
]]
function Objects:HandleSlowMotionForSpawnedObject(spawnedObject: ObjectTypes.SpawnedObject, deltaTime: number)
    for _, objectPart: ObjectTypes.ObjectPart in pairs(spawnedObject.Parts) do
        self:HandleSlowMotionForObjectPart(objectPart, deltaTime)
    end
end

--[[
    Updates spawned objects.
]]
function Objects:UpdateSpawnedObjects(deltaTime: number)
    local mapSize = Maps.CurrentMap.Size
    local mapPos = Maps.MAP_POSITION
    local startBound = Vector2.new(mapPos.X - mapSize.X / 2, mapPos.Y - mapSize.Y / 2)
    local endBound = Vector2.new(mapPos.X + mapSize.X / 2, mapPos.Y + mapSize.Y / 2)

    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        self:HandleSlowMotionForSpawnedObject(spawnedObject, deltaTime)

        spawnedObject:Update(
            startBound,
            endBound,
            Camera.MouseWorldPosition
        )
    end
end

--[[
    Updates all spawned wires.
]]
function Objects:UpdateSpawnedWires()
    for _, spawnedWire: ObjectTypes.SpawnedWire in pairs(self.SpawnedWires) do
        task.spawn(function()
            spawnedWire:Update()
        end)
    end
end

--[[
    Updates the camera.
]]
function Objects:UpdateCamera(deltaTime: number)
    if not self.IsFollowing then
        self._CameraFollowVelocity = 0
        return
    end

    if not self:IsAnyObjectPartSelected() then
        self:SetFollowing(false)
        return
    end

    local average = Vector2.new(0, 0)

    for _, objectPart: ObjectTypes.ObjectPart in pairs(self.SelectedObjectParts) do
        average = average + objectPart:GetPosition()
    end

    average = average / #self.SelectedObjectParts

    Camera.Position, self._CameraFollowVelocity = Rage.Tweening:SmoothDamp(
        Camera.Position,
        average,
        self._CameraFollowVelocity,
        self.CAMERA_FOLLOW_SMOOTH_TIME,
        self.CAMERA_FOLLOW_MAX_SPEED,
        deltaTime
    )
end

--[[
    Updates object part highlighting.
]]
function Objects:UpdateObjectPartHighlighting()
    local part = self:GetPartUnderMouse()

    if part then
        self:HighlightPart(part)
    else
        self:UnhighlightPart()
    end
end

--[[
    Creates commands.
]]
function Objects:_CreateCommands()
    CLI.Conch.register("set-slomo-mode", {
        description = "Sets the slomo mode.",

        arguments = function()
            return CLI.Conch.args.string("Mode", "The mode to use, see `SlomoMode` enum.")
        end,

        callback = function(mode: string)
            self.SlomoMode = SlomoMode[mode]
        end
    })

    CLI.Conch.register("set-selection-mode", {
        description = "Sets the selection mode.",

        arguments = function()
            return CLI.Conch.args.string("Mode", "The mode to set, see `ObjectPartSelectionMode` enum")
        end,

        callback = function(mode: string)
            self.SelectionMode = ObjectPartSelectionMode[mode]
        end
    })

    CLI.Conch.register("set-slomo-speed", {
        description = "Sets the slomo speed.",

        arguments = function()
            return CLI.Conch.args.number("Speed", "The speed, 0 - 1")
        end,

        callback = function(speed: number)
            self:SetSlowMotionSpeed(speed)
        end
    })

    CLI.Conch.register("despawn-all-objects", {
        description = "Despawns all spawned objects.",
        arguments = function() end,

        callback = function()
            self:DespawnAllObjects()
        end
    })

    CLI.Conch.register("remove-all-wires", {
        description = "Removes all wires.",
        arguments = function() end,

        callback = function()
            self:RemoveAllWires()
        end
    })

    CLI.Conch.register("activate-all-object-parts", {
        description = "Activates all parts of all objects.",
        arguments = function() end,

        callback = function()
            for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
                for _, objectPart: ObjectTypes.ObjectPart in pairs(spawnedObject.Parts) do
                    objectPart:Activate()
                end
            end
        end
    })

    CLI.Conch.register("spawn-objects", {
        description = "Spawns x amount of objects at the mouse position.",

        arguments = function()
            return CLI.Conch.args.number("Amount", "The amount of objects to spawn."), CLI.Conch.args.number("Padding", "How many studs should the objects be separated by")
        end,

        callback = function(amount: number, padding: number)
            local at = Camera.MouseWorldPosition

            for _ = 1, amount do
                self:PlayerSpawnObject(at)
                at = at + Vector2.new(padding, 0)
            end
        end
    })

    CLI.Conch.register("select-object", {
        description = "Selects an object to spawn.",

        arguments = function()
            return CLI.Conch.args.string("ObjectName", "The name of the object to select.")
        end,

        callback = function(objectName: string)
            local object = self:GetObject(objectName)

            if not object then
                Rage.Logging:Warn("No object found with provided name.")
                return
            end

            self:SelectObject(object)
        end
    })

    CLI.Conch.register("select-wire", {
        description = "Selects a wire to connect parts with.",

        arguments = function()
            return CLI.Conch.args.string("WireName", "The name of the wire to select.")
        end,

        callback = function(wireName: string)
            local wire = self:GetWire(wireName)

            if not wire then
                Rage.Logging:Warn("No wire found with provided name.")
                return
            end

            self:SelectWire(wire)
        end
    })
end

export type Objects = Rage.Service & typeof(Objects)
return Objects