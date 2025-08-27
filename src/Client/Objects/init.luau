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
Objects.ExistingObjects = {} :: {ObjectTypes.Object}
Objects.ExistingObjectsByCategory = {} :: {string: {ObjectTypes.Object}}
Objects.SpawnedObjectCount = 0
Objects.SpawnedObjects = {} :: {number: ObjectTypes.SpawnedObject}
Objects.SpawnedObjectHistory = {} :: {ObjectTypes.SpawnedObject}
Objects.Behaviours = {} :: {string: ObjectTypes.ObjectBehaviour}
Objects.FollowingPart = nil :: ObjectTypes.ObjectPart
Objects.DraggingPart = nil :: ObjectTypes.ObjectPart
Objects.DragPosition = Vector2.new(0, 0)
Objects.SelectedObjectToSpawn = nil :: ObjectTypes.Object

Objects.OnSpawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnDespawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnSelect = signal.new() :: signal.Signal<ObjectTypes.Object>

--[[
    Called when the service starts.
]]
function Objects:OnStart()
    self:LoadBehaviours()
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
            if not self:GetPartUnderMouse() then
                self:StopFollowingPart()
                return
            end

            self:FollowPartUnderMouse()
        end
    end)

    Rage.Input.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:StopDraggingPart()
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
    if not self.DraggingPart then
        return
    end

    self.DraggingPart:SetRotationForce(direction)
end

--[[
    Drags the part under the mouse.
]]
function Objects:DragPartUnderMouse()
    if self.DraggingPart then
        self:StopDraggingPart()
    end

    local part = self:GetPartUnderMouse()

    if not part then
        Rage.Logging:Warn("Objects:DragPartUnderMouse(): Attempted to drag part under mouse, but no part was found.")
        return
    end

    if not part.Settings.IsDraggable then
        Rage.Logging:Warn("Objects:DragPartUnderMouse(): Attempted to drag part "..part.Part:GetFullName()..", but it is not draggable.")
        return
    end

    part:Drag()
    self.DraggingPart = part

    Rage.Logging:Info("Objects:DragPartUnderMouse(): Started dragging part "..part.Part:GetFullName())
end

function Objects:StopDraggingPart()
    if not self.DraggingPart then
        Rage.Logging:Warn("Objects:StopDraggingPart(): Attempted to stop dragging part, but no part is being dragged.")
        return
    end

    self.DraggingPart:StopDragging()
    self.DraggingPart = nil

    Rage.Logging:Info("Objects:StopDraggingPart(): Stopped dragging part.")
end

--[[
    Makes the camera follow the part under the mouse.
]]
function Objects:FollowPartUnderMouse()
    local part = self:GetPartUnderMouse()

    if not part then
        Rage.Logging:Warn("Objects:FollowPartUnderMouse(): Attempted to follow part under mouse, but no part was found.")
        return
    end

    self.FollowingPart = part
end

--[[
    Stops following the part under the mouse.
]]
function Objects:StopFollowingPart()
    if not self.FollowingPart then
        Rage.Logging:Warn("Objects:StopFollowingPart(): Attempted to stop following part, but no part is being followed.")
        return
    end

    self.FollowingPart = nil
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
    for _, object in pairs(self.ExistingObjects) do
        if object.Name == name then
            return object
        end
    end
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
    Spawns an object (player-driven).
]]
function Objects:PlayerSpawnObject(position: Vector3?): ObjectTypes.SpawnedObject
    if not Maps.IsInMap then
        return
    end

    if not self.SelectedObjectToSpawn then
        Rage.Logging:Warn("Objects:PlayerSpawnObject(): No object selected to spawn.")

        Toasts:DisplayToast(
            "Objects",
            "You need to select an object to spawn.",
            2
        )

        return
    end

    if not self.SelectedObjectToSpawn:CanPlayerSpawn() then
        Rage.Logging:Error("Objects:PlayerSpawnObject(): Object "..self.SelectedObjectToSpawn.Name.." cannot be spawned by the player.")
    end

    if not position then
        position = Camera:CastRayToZ0()
        Debug:CreateDebugPart(Vector3.new(position.X, position.Y, 0))
    end

    Toasts:DisplayToast(
        "Objects",
        "You have spawned "..self.SelectedObjectToSpawn.Name..".",
        2
    )

    Rage.Logging:Info("Objects:PlayerSpawnObject(): Player is spawning object "..self.SelectedObjectToSpawn.Name)

    return self:SpawnObject(self.SelectedObjectToSpawn, position)
end

--[[
    Selects an object to spawn.
]]
function Objects:SelectObjectToSpawn(object: ObjectTypes.Object)
    self.SelectedObjectToSpawn = object
    self.OnSelect:Fire(object)
    Rage.Logging:Info("Objects:SelectObjectToSpawn(): Selected object "..object.Name)

    Toasts:DisplayToast(
        "Objects",
        "You have selected "..object.Name..".",
        2
    )
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
    Spawns an object at the specified position.
]]
function Objects:SpawnObject(object: ObjectTypes.Object, position: Vector2): ObjectTypes.SpawnedObject
    local spawnedObject = SpawnedObject.New(ID:GetID(), object)
    spawnedObject:Setup(position)

    self.SpawnedObjects[spawnedObject.ID] = spawnedObject
    table.insert(self.SpawnedObjectHistory, spawnedObject)

    spawnedObject._RemovalRequested:Once(function()
        self:DespawnObject(spawnedObject)
    end)

    self.SpawnedObjectCount = self.SpawnedObjectCount + 1

    self.OnSpawn:Fire(spawnedObject)

    Rage.Logging:Info(("Objects:SpawnObject(): Spawned object %s (%s) at %s with %d parts"):format(
        object.Name,
        spawnedObject.ID,
        tostring(position),
        Rage.Libs.Table:GetLength(spawnedObject.Parts)
    ))

    return spawnedObject
end

--[[
    Despawns a spawned object.
]]
function Objects:DespawnObject(spawnedObject: ObjectTypes.SpawnedObject)
    if not self.SpawnedObjects[spawnedObject.ID] then
        Rage.Logging:Error("Objects:DespawnObject(): Spawned object with ID "..spawnedObject.ID.." does not exist.")
    end

    for _, part in pairs(spawnedObject.Parts) do
        if part == self.DraggingPart then
            self:StopDraggingPart()
            break
        end

        if part == self.FollowingPart then
            self:StopFollowingPart()
            break
        end
    end

    spawnedObject:Despawn()
    self.SpawnedObjects[spawnedObject.ID] = nil
    self:_RemoveSpawnedObjectFromHistory(spawnedObject)

    self.SpawnedObjectCount = self.SpawnedObjectCount - 1

    self.OnDespawn:Fire(spawnedObject)

    Rage.Logging:Info(("Objects:DespawnObject(): Despawned object %s (%s)"):format(spawnedObject.Object.Name, spawnedObject.ID))
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
    Updates everything. To be called every heartbeat.
]]
function Objects:Update()
    if not Maps.IsInMap then
        return
    end

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

    if self.FollowingPart then
        Camera.Position = self.FollowingPart:GetPosition()
    end

    self:HandleInputTick()
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
        table.insert(self.ExistingObjects, object)
        table.insert(self.ExistingObjectsByCategory[object.Category], object)

        Rage.Logging:Info("Objects:LoadObjects(): Loaded object: "..object.Name)
    end
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

            self:SelectObjectToSpawn(object)
        end
    })
end

export type Objects = typeof(Objects)
return Objects