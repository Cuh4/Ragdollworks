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
    local spawnedObject = setmetatable({}, SpawnedObject) :: types.SpawnedObject
    spawnedObject.ID = ID
    spawnedObject.Object = object
    spawnedObject.Instance = instance
    spawnedObject.Parts = spawnedObject:FindParts()
    spawnedObject.Behaviours = {}

    for _, behaviour in pairs(object.Behaviours) do
        local behaviourInstance = behaviour.New()
        table.insert(spawnedObject.Behaviours, behaviourInstance)
    end

    for _, behaviour in pairs(spawnedObject.Behaviours) do
        behaviour:OnSpawn(spawnedObject)
    end

    for _, part in pairs(spawnedObject.Parts) do
        part.OnActivate:Connect(function()
            for _, behaviour in pairs(spawnedObject.Behaviours) do
                behaviour:OnActivate(spawnedObject, part)
            end
        end)
    end

    return spawnedObject
end

--[[
    Updates the spawned object.
]]
function SpawnedObject:Update(startBound: Vector2, endBound: Vector2)
    for _, part in pairs(self.Parts) do
        part:Update(startBound, endBound)
    end

    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnUpdate(self)
    end
end

--[[
    Sets up the spawned object.
]]
function SpawnedObject:Setup()
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
function SpawnedObject:RemovePart(part: BasePart)
    if not self.Parts[part] then
        return
    end

    self.Parts[part] = nil
    part:Destroy()
end

--[[
    Despawns the spawned object, removing all parts and cleaning up.
]]
function SpawnedObject:Despawn()
    for _, behaviour in pairs(self.Behaviours) do
        behaviour:OnPreDespawn(self)
    end

    self.Instance:Destroy()
end

return SpawnedObject