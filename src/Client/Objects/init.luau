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

local signal = require(Rage.ReplicatedStorage.Packages.signal)

local CLI = require(script.Parent.CLI)
local ID = require(script.Parent.ID)
local Camera = require(script.Parent.Camera)
local Maps = require(script.Parent.Maps)

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

Objects.ExistingObjects = {} :: {ObjectTypes.Object}
Objects.ExistingObjectsByCategory = {} :: {string: {ObjectTypes.Object}}
Objects.SpawnedObjects = {} :: {number: ObjectTypes.SpawnedObject}
Objects.Behaviours = {} :: {string: ObjectTypes.ObjectBehaviour}
Objects.DraggingPart = nil :: ObjectTypes.ObjectPart
Objects.DragPosition = Vector2.new(0, 0)

Objects.OnSpawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>
Objects.OnDespawn = signal.new() :: signal.Signal<ObjectTypes.SpawnedObject>

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
    Handles uUser input.
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
            self:PlayerSpawnObject(self.ExistingObjects[math.random(1, #self.ExistingObjects)])
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
    local result = Camera:CastRay(self.RAY_DISTANCE)

    if not result then
        return
    end

    return self:GetObjectPartFromPart(result.Instance)
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
function Objects:PlayerSpawnObject(object: ObjectTypes.Object): ObjectTypes.SpawnedObject
    if not Maps.IsInMap then
        return
    end

    if not object:CanPlayerSpawn() then
        Rage.Logging:Error("Objects:PlayerSpawnObject(): Object "..object.Name.." cannot be spawned by the player.")
    end

    Rage.Logging:Info("Objects:PlayerSpawnObject(): Player is spawning object "..object.Name)

    local raycastResult = Camera:CastRay(self.RAY_DISTANCE)

    if not raycastResult then
        Rage.Logging:Warn("Objects:PlayerSpawnObject(): Raycast returned nil, couldn't spawn object.")
        return
    end

    return self:SpawnObject(object, raycastResult.Position)
end

--[[
    Spawns an object at the specified position.
]]
function Objects:SpawnObject(object: ObjectTypes.Object, position: Vector2): ObjectTypes.SpawnedObject
    local spawnedObject = SpawnedObject.New(ID:GetID(), object, object:Spawn())
    spawnedObject:Setup()
    spawnedObject:MoveTo(position)

    self.SpawnedObjects[spawnedObject.ID] = spawnedObject

    self.OnSpawn:Fire(spawnedObject)

    spawnedObject._RemovalRequested:Once(function()
        self:DespawnObject(spawnedObject)
    end)

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
    end

    spawnedObject:Despawn()
    self.SpawnedObjects[spawnedObject.ID] = nil

    self.OnDespawn:Fire(spawnedObject)

    Rage.Logging:Info(("Objects:DespawnObject(): Despawned object %s (%s)"):format(spawnedObject.Object.Name, spawnedObject.ID))
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
    Updates all spawned objects. To be called every heartbeat.
]]
function Objects:Update()
    if not Maps.IsInMap then
        return
    end

    local mapSize = Maps.CurrentMap.Size
    local mapPos = Maps.MAP_POSITION
    local startBound = Vector2.new(mapPos.X - mapSize.X / 2, mapPos.Y - mapSize.Y / 2)
    local endBound = Vector2.new(mapPos.X + mapSize.X / 2, mapPos.Y + mapSize.Y / 2)
    local raycastResult = Camera:CastRay(self.RAY_DISTANCE)

    if raycastResult then
        self.DragPosition = raycastResult.Position
    end

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
            return CLI.Conch.args.number("Amount", "The amount of objects to spawn.")
        end,

        callback = function(amount: number)
            for _ = 1, amount do
                self:PlayerSpawnObject(self.ExistingObjects[math.random(1, #self.ExistingObjects)])
            end
        end
    })
end

export type Objects = typeof(Objects)
return Objects