--------------------------------------------------------
-- [Ragdollworks] Spawned Object
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Copyright (C) 2025 Cuh4

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

    CREDIT:
        Author(s): @Cuh4 (GitHub)

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local Organization = require(Rage.Path.Organization)

local Entity = require(script.Parent.Entity)
local ObjectPart = require(script.Parent.ObjectPart)
local ObjectTypes = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a spawned object.
]]
SpawnedObject = {} :: ObjectTypes.SpawnedObject
SpawnedObject.__index = SpawnedObject
SpawnedObject._SpawnedObjectFolder = Organization:CreateFolder("SpawnedObjects", Rage.Workspace)

setmetatable(SpawnedObject, Entity)

--[[
    Creates a new SpawnedObject class instance.
]]
function SpawnedObject.New(ID: number, object: Object): ObjectTypes.SpawnedObject
    local self = setmetatable(Entity.New("SpawnedObject"), SpawnedObject) :: ObjectTypes.SpawnedObject
    self.ID = ID
    self.Object = object
    self.Instance = nil
    self.Parts = nil
    self.Behaviours = {}
    self.IsDespawning = false

    return self
end

--[[
    Updates the spawned object.
]]
function SpawnedObject:Update(startBound: Vector2, endBound: Vector2, dragPosition: Vector2)
    for _, part in pairs(self.Parts) do
        part:Update(startBound, endBound, dragPosition)
    end

    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnUpdate(self)
    end
end

--[[
    Sets up the spawned object.
]]
function SpawnedObject:Setup(spawnPos: Vector3)
    self.Instance = self.Object:Spawn()
    self:MoveTo(spawnPos)

    self.Parts = self:FindParts()
    self.Behaviours = self.Object.Behaviours

    self:CreateNoCollideConstraints()
    self:SetupAttributes()

    for _, part in pairs(self.Parts) do
        part:Setup()
    end

    for _, part in pairs(self.Parts) do
        part.OnActivate:Connect(function()
            for _, behaviour in pairs(self.Behaviours) do
                behaviour:OnActivate(self, part)
            end
        end)

        part.OnDespawn:Connect(function()
            self:RemovePart(part)
        end)
    end

    self.Instance.Parent = self._SpawnedObjectFolder
end

--[[
    Starts this spawned object's behaviours.<br>
    This should only ever be called once.
]]
function SpawnedObject:StartBehaviours()
    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnSpawn(self)
    end
end

--[[
    Moves the spawned object to the specified position.
]]
function SpawnedObject:MoveTo(position: Vector2)
    self.Instance:PivotTo(CFrame.new(Vector3.new(position.X, position.Y, 0)) * self.Instance:GetPivot().Rotation)
end

--[[
    Rotates the spawned object.
]]
function SpawnedObject:RotateTo(radians: number)
    self.Instance:PivotTo(self.Instance:GetPivot() * CFrame.Angles(0, 0, math.rad(radians)))
end

--[[
    Rotates the spawned object by the provided radians.
]]
function SpawnedObject:RotateBy(radians: number)
    self:RotateTo(self.Instance:GetPivot().Rotation.Z + radians)
end

--[[
    Returns a part by exact name.
]]
function SpawnedObject:GetPartByName(name: string): ObjectTypes.ObjectPart?
    for _, part in pairs(self.Parts) do
        if part.Part.Name == name then
            return part
        end
    end
end

--[[
    Set up attributes for all parts in this spawned object.
]]
function SpawnedObject:SetupAttributes()
    for _, part in pairs(self.Parts) do
        part.Part:SetAttribute("SpawnedObjectID", self.ID)
    end
end

--[[
    Creates no-collide constraints if allowed.
]]
function SpawnedObject:CreateNoCollideConstraints()
    if self.Object.Settings.CanPartsCollide then
        return
    end

    for _, part in pairs(self.Parts) do
        for _, otherPart in pairs(self.Parts) do
            if part.Part == otherPart.Part then
                continue
            end

            local noCollideConstraint = Instance.new("NoCollisionConstraint")
            noCollideConstraint.Part0 = part.Part
            noCollideConstraint.Part1 = otherPart.Part
            noCollideConstraint.Parent = part.Part
        end
    end
end

--[[
    Finds all parts in the object and constructs data for each part.<br>
    The data is then returned in a table, with indices being the part instances.
]]
function SpawnedObject:FindParts(): {[BasePart]: ObjectTypes.ObjectPart}
    local partsData = {}

    for _, part in pairs(self.Instance:GetDescendants()) do
        if part:IsA("BasePart") then
            partsData[part] = ObjectPart.FromPart(part, self)
        end
    end

    return partsData
end

--[[
    Returns a ObjectPart instance by the part instance.
]]
function SpawnedObject:GetPart(part: BasePart): ObjectTypes.ObjectPart?
    return self.Parts[part]
end

--[[
    Removes a spawned part from the spawned object.
]]
function SpawnedObject:RemovePart(part: ObjectTypes.ObjectPart)
    self.Parts[part.Part] = nil

    if Rage.Libs.Table:GetLength(self.Parts) <= 0 and not self.IsDespawning then
        self:Remove()
    end
end

--[[
    Returns if this spawned object has the provided part.
]]
function SpawnedObject:HasPart(part: ObjectTypes.ObjectPart): boolean
    return self.Parts[part.Part] ~= nil
end

--[[
    Freezes all parts in the spawned object.
]]
function SpawnedObject:Freeze()
    for _, part in pairs(self.Parts) do
        part:Freeze()
    end
end

--[[
    Unfreezes all parts in the spawned object.
]]
function SpawnedObject:Unfreeze()
    for _, part in pairs(self.Parts) do
        part:Unfreeze()
    end
end

--[[
    Pauses all parts in the spawned object.
]]
function SpawnedObject:Pause()
    for _, part in pairs(self.Parts) do
        part:Pause()
    end
end

--[[
    Unpauses all parts in the spawned object.
]]
function SpawnedObject:Unpause()
    for _, part in pairs(self.Parts) do
        part:Unpause()
    end
end

--[[
    Adds a context menu item to all parts within this spawned object.
]]
function SpawnedObject:AddContextMenuItem(name: string, onTrigger: ObjectTypes.ContextMenuItemCallback)
    for _, part in pairs(self.Parts) do
        part.ContextMenu:AddContextMenuItem(name, onTrigger)
    end
end

--[[
    Despawns the spawned object, removing all parts and cleaning up.
]]
function SpawnedObject:Despawn()
    self.IsDespawning = true -- prevent a second despawn due to all parts being removed

    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnPreDespawn(self)
    end

    for _, part in pairs(self.Parts) do
        part:Despawn()
    end

    self.Instance:Destroy()
end

--[[
    Removes the spawned object. Despawns and removes from Objects service.
]]
function SpawnedObject:Remove()
    require(Rage.Path.Objects):DespawnObject(self)
end

return SpawnedObject