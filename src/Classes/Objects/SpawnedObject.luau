--------------------------------------------------------
-- [Ragdollworks] Spawned Object
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

local ObjectPart = require(script.Parent.ObjectPart)
local types = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a spawned object.
]]
SpawnedObject = {} :: types.SpawnedObject
SpawnedObject.__index = SpawnedObject

--[[
    Creates a new SpawnedObject class instance.
]]
function SpawnedObject.New(ID: number, object: Object, instance: Model): types.SpawnedObject
    local self = setmetatable({}, SpawnedObject) :: types.SpawnedObject
    self.ID = ID
    self.Object = object
    self.Instance = instance
    self.Parts = self:FindParts()
    self.Behaviours = {}

    self._RemovalRequested = signal.new()

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
        behaviour:OnUpdate()
    end
end

--[[
    Sets up the spawned object.
]]
function SpawnedObject:Setup()
    for _, behaviour in pairs(self.Object.Behaviours) do
        local behaviourInstance = behaviour.New(self)
        table.insert(self.Behaviours, behaviourInstance)
    end

    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnSpawn()
    end

    for _, part in pairs(self.Parts) do
        part.OnActivate:Connect(function()
            for _, behaviour in pairs(self.Behaviours) do
                behaviour:OnActivate(part)
            end
        end)

        part.OnDespawn:Connect(function()
            self:RemovePart(part)
        end)
    end

    self:CreateNoCollideConstraints()
    self:SetupAttributes()

    for _, part in pairs(self.Parts) do
        part:Setup()
    end

    self.Instance.Parent = game.Workspace
end

--[[
    Moves the spawned object to the specified position.
]]
function SpawnedObject:MoveTo(position: Vector2)
    self.Instance:MoveTo(Vector3.new(position.X, position.Y, 0))
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
function SpawnedObject:FindParts(): {[BasePart]: types.ObjectPart}
    local partsData = {}

    for _, part in pairs(self.Instance:GetDescendants()) do
        if part:IsA("BasePart") then
            partsData[part] = ObjectPart.FromPart(part)
        end
    end

    return partsData
end

--[[
    Returns a ObjectPart instance by the part instance.
]]
function SpawnedObject:GetPart(part: BasePart): types.ObjectPart?
    return self.Parts[part]
end

--[[
    Removes a spawned part from the spawned object.
]]
function SpawnedObject:RemovePart(part: types.ObjectPart)
    self.Parts[part.Part] = nil

    if Rage.Libs.Table:GetLength(self.Parts) == 0 then
        self:Remove()
    end
end

--[[
    Despawns the spawned object, removing all parts and cleaning up.
]]
function SpawnedObject:Despawn()
    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnPreDespawn()
    end

    self.Instance:Destroy()
end

--[[
    Removes the spawned object. Despawns and removes from Objects service.
]]
function SpawnedObject:Remove()
    self:Despawn()
    self._RemovalRequested:Fire()
end

return SpawnedObject