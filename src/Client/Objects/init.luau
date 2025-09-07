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

local Object = require(Rage.ReplicatedStorage.Classes.Objects.Object)
local SpawnedObject = require(Rage.ReplicatedStorage.Classes.Objects.SpawnedObject)
local ObjectTypes = require(Rage.ReplicatedStorage.Classes.Objects.Types)

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
Objects.MAX_ROTATION_SPEED = 6
Objects.ROTATION_SPEED_INCREMENT = 0.06
Objects.DEFAULT_ROTATION_SPEED = 1

Objects.RotationSpeed = 1

Objects.ExistingObjects = {} :: {string: ObjectTypes.Object}
Objects.ExistingObjectsByCategory = {} :: {string: {ObjectTypes.Object}}
Objects.Behaviours = {} :: {string: ObjectTypes.ObjectBehaviour}

Objects.SpawnedObjectCount = 0
Objects.SpawnedObjects = {} :: {number: ObjectTypes.SpawnedObject}
Objects.SelectedObjectParts = {} :: {ObjectTypes.ObjectPart}
Objects.HighlightedPart = nil :: ObjectTypes.ObjectPart

Objects.EntityHistory = {} :: {ObjectTypes.Entity}

Objects.IsFollowing = false

Objects.IsDragging = false
Objects.DraggingPart = nil :: ObjectTypes.ObjectPart

Objects.SelectedObject = nil :: ObjectTypes.Object

Objects.ContextMenuActivePart = nil :: ObjectTypes.ObjectPart

Objects.ExistingWires = {} :: {string: ObjectTypes.Wire}
Objects.SelectedWire = nil :: ObjectTypes.Wire
Objects.SelectedWireSourcePart = nil :: ObjectTypes.ObjectPart
Objects.SelectedWireSourcePartMousePos = nil :: Vector2
Objects.SpawnedWires = {} :: {ObjectTypes.SpawnedWire}

Objects.Paused = false

Objects.OnSpawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnDespawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnObjectSelect = signal.new() :: signal.Signal<ObjectTypes.Object>
Objects.OnWireSelect = signal.new() :: signal.Signal<ObjectTypes.Wire>

--[[
    Called when the service starts.
]]
function Objects:OnStart()
    self:LoadBehaviours()
    self:LoadWires()
    self:LoadObjects()
    self:HandleInput()

    self:_CreateCommands()

    Rage.RunService.Heartbeat:Connect(function()
        self:Update()
    end)

    Maps.OnMapExit:Connect(function()
        self:OnMapExit()
    end)
end

--[[
    Handles user input every tick.
]]
function Objects:HandleInputTick()
    if Rage.Input:IsKeyDown(Enum.KeyCode.A) then
        self:RotateDraggedPart(-self.RotationSpeed)
    elseif Rage.Input:IsKeyDown(Enum.KeyCode.D) then
        self:RotateDraggedPart(self.RotationSpeed)
    else
        self:RotateDraggedPart(0)
    end

    if Rage.Input:IsKeyDown(Enum.KeyCode.LeftShift) then
        self.RotationSpeed = self.RotationSpeed + self.ROTATION_SPEED_INCREMENT
    else
        self.RotationSpeed = self.DEFAULT_ROTATION_SPEED
    end

    local part = self:GetPartUnderMouse()

    if part then
        self:HighlightPart(part)
    else
        self:UnhighlightPart()
    end
end

--[[
    Handles user input.
]]
function Objects:HandleInput()
    Rage.Input.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:SelectHighlightedObjectPart(not Rage.Input:IsKeyDown(Enum.KeyCode.LeftShift))
            self:DragHighlightedPart()

            if not self.HighlightedPart then
                self:HideContextMenu()
            end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            self:SelectHighlightedObjectPart(true)
            self:PlayerHandleContextMenu()
        end

        if input.KeyCode == Enum.KeyCode.F then
            self:ActivateHighlightedPart()
        end

        if input.KeyCode == Enum.KeyCode.E then
            self:PlayerSpawnObject()
        end

        if input.KeyCode == Enum.KeyCode.Z then
            self:Undo()
        end

        if input.KeyCode == Enum.KeyCode.U then
            self:SetFollowing(not self.IsFollowing)
        end

        if input.KeyCode == Enum.KeyCode.Delete then
            self:DespawnSelectedObjects()
        end

        if input.KeyCode == Enum.KeyCode.T then
            self:PlayerBeginWiring()
        end

        if input.KeyCode == Enum.KeyCode.Space then
            self:PlayerTogglePaused()
        end

        if input.KeyCode == Enum.KeyCode.Y then
            self:PlayerPipette()
        end
    end)

    Rage.Input.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.KeyCode == Enum.KeyCode.T then
            self:PlayerStopWiring()
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:StopDragging()
        end
    end)
end

--[[
    Handles when the map is exited.
]]
function Objects:OnMapExit()
    self:DespawnAllObjects()
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
    part.ContextMenu:Show(UDim2.new(0, screenPosition.X, 0, screenPosition.Y))

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

    Toasts:DisplayToast(
        "Objects",
        "All object physics have been paused.",
        2
    )
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

    Toasts:DisplayToast(
        "Objects",
        "All object physics have been unpaused.",
        2
    )
end

--[[
    Rotates the currently-dragged part. -1 = left
]]
function Objects:RotateDraggedPart(direction: number)
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
    Returns the ObjectPart under the mouse, if any.
]]
function Objects:GetPartUnderMouse(): ObjectTypes.ObjectPart?
    local results = Camera:CastRayAll(self.RAY_DISTANCE)
    local parts = {} :: {ObjectTypes.ObjectPart}

    -- Convert raycast results to object parts if possible
    for _, result in pairs(results) do
        local part = self:GetObjectPartFromPart(result.Instance)

        if part then
            table.insert(parts, part)
        end
    end

    -- Return the part with the highest layer
    local highest = nil :: ObjectTypes.ObjectPart?

    for _, part in pairs(parts) do
        if not highest or part.Layer > highest.Layer then
            highest = part
        end
    end

    return highest
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
    Begin wiring two parts (player-driven)
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

    if not self.HighlightedPart then
        Toasts:DisplayToast(
            "Objects",
            "Hover your mouse over the part you want to connect a wire from and try again.",
            2
        )

        return
    end

    self.SelectedWireSourcePart = self.HighlightedPart
    self.SelectedWireSourcePartMousePos = Camera.MouseWorldPosition
end

--[[
    Stops wiring two parts (player-driven)
]]
function Objects:PlayerStopWiring()
    if not Maps.IsInMap then
        return
    end

    if not self.SelectedWireSourcePart then
        Rage.Logging:Warn("Objects:PlayerStopWiring(): Attempted to stop wiring, but no source part was selected.")
        return
    end

    if not self.HighlightedPart then
        Toasts:DisplayToast(
            "Objects",
            "Hover your mouse over the part you want to connect a wire to and try again.",
            2
        )

        return
    end

    if self.SelectedWireSourcePart == self.HighlightedPart then
        Toasts:DisplayToast(
            "Objects",
            "You cannot connect a part to itself.",
            2
        )

        return
    end

    self:ConnectWireToParts(
        self.SelectedWire,
        self.SelectedWireSourcePart,
        self.SelectedWireSourcePartMousePos,
        self.HighlightedPart,
        Camera.MouseWorldPosition
    )

    self.SelectedWireSourcePart = nil
    self.SelectedWireSourcePartMousePos = nil

    Toasts:DisplayToast(
        "Objects",
        "Successfully wired both parts together.",
        2
    )
end

--[[
    Connects a wire to two object parts.
]]
function Objects:ConnectWireToParts(wire: ObjectTypes.Wire, partA: ObjectTypes.ObjectPart, partAMousePos: Vector2, partB: ObjectTypes.ObjectPart, partBMousePos: Vector2)
    if partA == partB then
        Rage.Logging:Warn("Objects:ConnectWireToParts(): Attempted to connect wire to same part twice.")
        return
    end

    local spawnedWire = wire.WireClass.New()

    spawnedWire:Setup(
        partAMousePos,
        partA,
        partBMousePos,
        partB
    )

    table.insert(self.SpawnedWires, spawnedWire)
    self:AddToHistory(spawnedWire)

    Rage.Logging:Info("Objects:ConnectWireToParts(): Connected wire "..wire.Name.." to parts "..partA.Part:GetFullName().." and "..partB.Part:GetFullName())
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
function Objects:RemoveWiresFromPart(part: BasePart)
    if #self.SpawnedWires <= 0 then
        return
    end

    Rage.Libs.Table:IterateReverse(self.SpawnedWires, function(_, wire)
        if wire:IsConnectedToPart(part) then
            self:RemoveWire(wire)
        end
    end)
end

--[[
    Removes all wires.
]]
function Objects:RemoveAllWires()
    Rage.Libs.Table:IterateReverse(self.SpawnedWires, function(_, wire)
        self:RemoveWire(wire)
    end)
end

--[[
    Selects an object to spawn.
]]
function Objects:SelectObject(object: ObjectTypes.Object)
    self.SelectedObject = object
    self.OnObjectSelect:Fire(object)
    Rage.Logging:Info("Objects:SelectObject(): Selected object "..object.Name)

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
function Objects:PlayerSpawnObject(position: Vector3?): ObjectTypes.SpawnedObject
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

    if not position then
        position = Camera:CastRayToZ0()
        Debug:CreateDebugPart(CFrame.new(Vector3.new(position.X, position.Y, 0)))
    end

    Toasts:DisplayToast(
        "Objects",
        "You have spawned "..self.SelectedObject.Name..".",
        2
    )

    Rage.Logging:Info("Objects:PlayerSpawnObject(): Player is spawning object "..self.SelectedObject.Name)

    return self:SpawnObject(self.SelectedObject, position)
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

        -- Create category if it doesn't exist
        if not self.ExistingObjectsByCategory[object.Category] then
            self.ExistingObjectsByCategory[object.Category] = {}
            Rage.Logging:Info("Objects:LoadObjects(): Created new category: "..object.Category)
        end

        -- Register
        self.ExistingObjects[object.Name] = object
        table.insert(self.ExistingObjectsByCategory[object.Category], object)

        Rage.Logging:Info("Objects:LoadObjects(): Loaded object: "..object.Name)
    end
end

--[[
    Updates spawned objects.
]]
function Objects:UpdateSpawnedObjects()
    local mapSize = Maps.CurrentMap.Size
    local mapPos = Maps.MAP_POSITION
    local startBound = Vector2.new(mapPos.X - mapSize.X / 2, mapPos.Y - mapSize.Y / 2)
    local endBound = Vector2.new(mapPos.X + mapSize.X / 2, mapPos.Y + mapSize.Y / 2)

    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        task.spawn(function()
            spawnedObject:Update(
                startBound,
                endBound,
                Camera.MouseWorldPosition
            )
        end)
    end
end

--[[
    Updates all spawned wires.
]]
function Objects:UpdateSpawnedWIres()
    for _, spawnedWire: ObjectTypes.SpawnedWire in pairs(self.SpawnedWires) do
        task.spawn(function()
            spawnedWire:Update()
        end)
    end
end

--[[
    Updates the camera.
]]
function Objects:UpdateCamera()
    if self.IsFollowing then
        if not self:IsAnyObjectPartSelected() then
            self:SetFollowing(false)
            return
        end

        local average = Vector2.new(0, 0)

        for _, objectPart: ObjectTypes.ObjectPart in pairs(self.SelectedObjectParts) do
            average = average + objectPart:GetPosition()
        end

        average = average / #self.SelectedObjectParts

        Camera.Position = average
    end
end

--[[
    Updates everything. To be called every heartbeat.
]]
function Objects:Update()
    if not Maps.IsInMap then
        return
    end

    self:UpdateSpawnedObjects()
    self:UpdateSpawnedWIres()
    self:UpdateCamera()
    self:HandleInputTick()
end

--[[
    Creates commands.
]]
function Objects:_CreateCommands()
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
            local at = Camera:CastRayToZ0()

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

export type Objects = typeof(Objects)
return Objects