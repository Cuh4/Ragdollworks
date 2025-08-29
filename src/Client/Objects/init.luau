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
Objects.SpawnedObjectHistory = {} :: {ObjectTypes.SpawnedObject}
Objects.SelectedObjectParts = {} :: {ObjectTypes.ObjectPart}
Objects.HighlightedPart = nil :: ObjectTypes.ObjectPart

Objects.IsFollowing = false

Objects.IsDragging = false
Objects.DraggingPart = nil :: ObjectTypes.ObjectPart
Objects.DragPosition = Vector2.new(0, 0)

Objects.SelectedObject = nil :: ObjectTypes.Object

Objects.ExistingWires = {} :: {string: ObjectTypes.Wire}
Objects.SelectedWire = nil :: ObjectTypes.Wire
Objects.SpawnedWires = {} :: {ObjectTypes.SpawnedWire}

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
            self:SelectObjectPartUnderMouse(not Rage.Input:IsKeyDown(Enum.KeyCode.LeftShift))
            self:DragPartUnderMouse()
        end

        if input.KeyCode == Enum.KeyCode.F then
            self:ActivatePartUnderMouse()
        end

        if input.KeyCode == Enum.KeyCode.E then
            self:PlayerSpawnObject()
        end

        if input.KeyCode == Enum.KeyCode.Z then
            self:DespawnLastObject()
        end

        if input.KeyCode == Enum.KeyCode.U then
            self:SetFollowing(not self.IsFollowing)
        end

        if input.KeyCode == Enum.KeyCode.Delete then
            self:DespawnSelectedObjects()
        end
    end)

    Rage.Input.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.KeyCode == Enum.KeyCode.T then
            self:PlayerWireParts()
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
    self.DraggingPart:Drag()

    self.IsDragging = true

    Rage.Logging:Info("Objects:DragObjectPart(): Started dragging part.")
end

--[[
    Drags the part under the mouse.
]]
function Objects:DragPartUnderMouse()
    local part = self:GetPartUnderMouse()

    if not part then
        Rage.Logging:Warn("Objects:DragPartUnderMouse(): Attempted to drag part under mouse, but no part was found.")
        return
    end

    self:DragObjectPart(part)
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
    Activates the part under the mouse cursor, if it exists.
]]
function Objects:ActivatePartUnderMouse()
    local part = self:GetPartUnderMouse()

    if not part then
        Rage.Logging:Warn("Objects:ActivatePartUnderMouse(): Attempted to activate part under mouse, but no part was found.")
        return
    end

    Rage.Logging:Info("Objects:ActivatePartUnderMouse(): Activating part "..part.Part:GetFullName())
    part:Activate()
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
    Connects two parts together via wire (player-driven).
]]
function Objects:PlayerWireParts()
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

    if not self:IsAnyObjectPartSelected() then
        Toasts:DisplayToast(
            "Objects",
            "You need to select at least one part to connect the wire(s) from.",
            2
        )

        return
    end

    local part = self:GetPartUnderMouse()

    if not part then
        Toasts:DisplayToast(
            "Objects",
            "Hover your mouse over the part you want to connect a wire to and try again.",
            2
        )

        return
    end

    if self:IsObjectPartSelected(part) then
        Toasts:DisplayToast(
            "Objects",
            "You cannot connect a part to itself.",
            2
        )

        return
    end

    for _, selectedPart in pairs(self.SelectedObjectParts) do
        self:ConnectWireToParts(self.SelectedWire, selectedPart, part)
    end

    Toasts:DisplayToast(
        "Wires",
        "Successfully connected all selected parts to the part under your mouse.",
        2
    )
end

--[[
    Connects a wire to two object parts.
]]
function Objects:ConnectWireToParts(wire: ObjectTypes.Wire, partA: ObjectTypes.ObjectPart, partB: ObjectTypes.ObjectPart)
    if partA == partB then
        Rage.Logging:Warn("Objects:ConnectWireToParts(): Attempted to connect wire to same part twice.")
        return
    end

    local spawnedWire = wire.WireClass.New()
    spawnedWire:Setup(partA, partB)

    table.insert(self.SpawnedWires, spawnedWire)

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
    wire:Remove()
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
        Debug:CreateDebugPart(Vector3.new(position.X, position.Y, 0))
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
    Registers a spawned object.
]]
function Objects:_RegisterSpawnedObject(spawnedObject: ObjectTypes.SpawnedObject)
    self.SpawnedObjects[spawnedObject.ID] = spawnedObject
    table.insert(self.SpawnedObjectHistory, spawnedObject)

    spawnedObject._RemovalRequested:Once(function()
        self:DespawnObject(spawnedObject)
    end)

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
    self:_RemoveSpawnedObjectFromHistory(spawnedObject)

    self.SpawnedObjectCount = self.SpawnedObjectCount - 1

    self.OnDespawn:Fire(spawnedObject)
end

--[[
    Removes a spawned object from history.
]]
function Objects:_RemoveSpawnedObjectFromHistory(spawnedObject: ObjectTypes.SpawnedObject)
    for index, _spawnedObject in pairs(self.SpawnedObjectHistory) do
        if _spawnedObject == spawnedObject then
            table.remove(self.SpawnedObjectHistory, index)
            break
        end
    end
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
    Despawns the most recent spawned object.
]]
function Objects:DespawnLastObject()
    local recent = Rage.Libs.Table:GetLast(self.SpawnedObjectHistory) :: ObjectTypes.SpawnedObject

    if not recent then
        Rage.Logging:Warn("Objects:DespawnLastObject(): No recent spawned object to despawn.")

        Toasts:DisplayToast(
            "Objects",
            "No object to undo.",
            2
        )

        return
    end

    self:DespawnObject(recent)

    Toasts:DisplayToast(
        "Objects",
        "Successfully despawned last object.",
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
    Selects the object part under the mouse.
]]
function Objects:SelectObjectPartUnderMouse(overwrite: boolean)
    local objectPart = self:GetPartUnderMouse()

    if not objectPart then
        Rage.Logging:Warn("Objects:SelectObjectPartUnderMouse(): No object part under mouse. Deselecting all (QOL).")

        self:DeselectObjectParts()
        return
    end

    if self:IsObjectPartSelected(objectPart) then
        Rage.Logging:Warn("Objects:SelectObjectPartUnderMouse(): Attempted to select an object part that was already selected. Deselecting as a QOL (if not overwrite, otherwise ignoring).")

        if not overwrite then
            self:DeselectObjectPart(objectPart)
        end

        return
    end

    self:SelectObjectPart(objectPart, overwrite)
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
    Updates object part selection.
]]
function Objects:UpdateSelection()
    self:SelectObjectPartUnderMouse()
end

--[[
    Updates spawned objects.
]]
function Objects:UpdateSpawnedObjects()
    local mapSize = Maps.CurrentMap.Size
    local mapPos = Maps.MAP_POSITION
    local startBound = Vector2.new(mapPos.X - mapSize.X / 2, mapPos.Y - mapSize.Y / 2)
    local endBound = Vector2.new(mapPos.X + mapSize.X / 2, mapPos.Y + mapSize.Y / 2)

    self.DragPosition = (Camera:CastRayToZ0() or self.DragPosition) or Vector2.new(0, 0)
    -- to explain above: raycasting can return nil. so we default to last raycast position, or if that doesnt exist, we default to 0

    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        task.spawn(function()
            spawnedObject:Update(
                startBound,
                endBound,
                self.DragPosition
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
    if self.IsFollowing and self:IsAnyObjectPartSelected() then
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