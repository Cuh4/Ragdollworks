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

local CLI = require(script.Parent.CLI)
local ID = require(script.Parent.ID)
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

Objects.ExistingObjects = {} :: {ObjectTypes.Object}
Objects.ExistingObjectsByCategory = {} :: {string: {ObjectTypes.Object}}
Objects.SpawnedObjects = {} :: {number: ObjectTypes.SpawnedObject}

--[[
    Called when the service starts.
]]
function Objects:OnStart()
    self:LoadObjects()
    self:_CreateCommands()

    Rage.RunService.Heartbeat:Connect(function()
        self:Update()
    end)

    Rage.Player:GetMouse().Button1Down:Connect(function()
        self:OnMouseClick()
    end)

    Maps.OnMapExit:Connect(function()
        self:OnMapExit()
    end)
end

--[[
    Handles when the map is exited.
]]
function Objects:OnMapExit()
    self:DespawnAllObjects()
end

--[[
    Handles spawning an object when the user clicks.
]]
function Objects:OnMouseClick()
    if not Maps.IsInMap then
        return
    end

    local mousePosition = Rage.Player:GetMouse().Hit.Position
    local position = Vector2.new(mousePosition.X, mousePosition.Y)

    self:SpawnObject(self.ExistingObjects[math.random(1, #self.ExistingObjects)], position)
end

--[[
    Spawns an object at the specified position.
]]
function Objects:SpawnObject(object: ObjectTypes.Object, position: Vector2): ObjectTypes.SpawnedObject
    local spawnedObject = SpawnedObject.New(ID:GetID(), object, object:Spawn())
    spawnedObject:Setup()
    spawnedObject:MoveTo(position)

    self.SpawnedObjects[spawnedObject.ID] = spawnedObject

    Rage.Logging:Info(("Objects:SpawnObject(): Spawned object %s (%s) at %s"):format(object.Name, spawnedObject.ID, tostring(position)))

    return spawnedObject
end

--[[
    Despawns a spawned object.
]]
function Objects:DespawnObject(spawnedObject: ObjectTypes.SpawnedObject)
    if not self.SpawnedObjects[spawnedObject.ID] then
        Rage.Logging:Error("Objects:DespawnObject(): Spawned object with ID "..spawnedObject.ID.." does not exist.")
    end

    spawnedObject:Despawn()
    self.SpawnedObjects[spawnedObject.ID] = nil

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

    for _, spawnedObject: ObjectTypes.SpawnedObject in pairs(self.SpawnedObjects) do
        local mapSize = Maps.CurrentMap.Size
        local mapPos = Maps.MAP_POSITION

        spawnedObject:Update(
            Vector2.new(mapPos.X - mapSize.X / 2, mapPos.Y - mapSize.Y / 2),
            Vector2.new(mapPos.X + mapSize.X / 2, mapPos.Y + mapSize.Y / 2)
        )
    end
end

--[[
    Loads all objects from the OBJECT_FOLDER.
]]
function Objects:LoadObjects()
    for _, objectInstance: Model in pairs(self.OBJECT_FOLDER:GetChildren()) do
        local object = Object.FromInstance(objectInstance)

        if not self.ExistingObjectsByCategory[object.Category] then
            self.ExistingObjectsByCategory[object.Category] = {}
            Rage.Logging:Info("Objects:LoadObjects(): Created new category: "..object.Category)
        end

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

        callback = function(name: string)
            self:DespawnAllObjects()
        end
    })
end

export type Objects = typeof(Objects)
return Objects