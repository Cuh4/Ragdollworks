--------------------------------------------------------
-- [Ragdollworks] Explosive
--------------------------------------------------------

--[[
    ----------------------------

    License:
        Source-Available No-Redistribution License
        Copyright (c) 2025 Cuh4. All rights reserved.

        IMPORTANT: This source code is NOT Open Source.

        1. PERMISSIONS (Limited):
        * View and read the source code.
        * Modify for private, non-public use only.
        * Contributions back to the project are permitted.

        2. PROHIBITIONS (Strict):
        * You MAY NOT copy, redistribute, publish, or share the code (modified or unmodified).
        * You MAY NOT use this code in ANY public or commercial project or service.

        Any violation automatically terminates your rights.
        Provided "AS IS" without warranty.
        Full terms governed by the laws of England and Wales.

        For the full license, see the `LICENSE` file provided with the source code.

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local ObjectBehaviour = require(Rage.Path.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Explosive = require(Rage.Path.Classes.Explosive)

-------------------------------
-- // Main
-------------------------------

--[[
    An object behaviour that allows objects to explode.
]]
ExplosiveObjectBehaviour = {} :: ExplosiveObjectBehaviour
ExplosiveObjectBehaviour.__index = ExplosiveObjectBehaviour

setmetatable(ExplosiveObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new ExplosiveObjectBehaviour class instance.
]]
function ExplosiveObjectBehaviour.New(...): ExplosiveObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(...), ExplosiveObjectBehaviour) :: ExplosiveObjectBehaviour
    self.Explosives = {} :: {[ObjectTypes.ObjectPart]: Explosive.Explosive}

    return self
end

--[[
    Creates an explosive for a part.
]]
function ExplosiveObjectBehaviour:CreateExplosive(objectPart: ObjectTypes.ObjectPart): Explosive.Explosive
    local explosive = Explosive.New(objectPart)

    explosive.OnCleanup:Once(function()
        self:RemoveExplosive(explosive)
    end)

    self.Explosives[objectPart] = explosive
end

--[[
    Returns an explosive from an object part.
]]
function ExplosiveObjectBehaviour:GetExplosive(objectPart: ObjectTypes.ObjectPart): Explosive.Explosive?
    return self.Explosives[objectPart]
end

--[[
    Removes an explosive.
]]
function ExplosiveObjectBehaviour:RemoveExplosive(explosive: Explosive.Explosive)
    if not self.Explosives[explosive.Part] then
        return
    end

    explosive:Cleanup()
    self.Explosives[explosive.Part] = nil
end

--[[
    Called when an object using this behaviour is spawned.
]]
function ExplosiveObjectBehaviour:OnSpawn(spawnedObject: ObjectTypes.SpawnedObject)
    for _, part in pairs(spawnedObject.Parts) do
        self:CreateExplosive(part)
    end
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function ExplosiveObjectBehaviour:OnPreDespawn(spawnedObject: ObjectTypes.SpawnedObject)
    for _, part in pairs(spawnedObject.Parts) do
        local explosive = self:GetExplosive(part) :: Explosive.Explosive

        if not explosive then
            return
        end

        self:RemoveExplosive(explosive)
    end
end

--[[
    Called when an object using this behaviour is activated.
]]
function ExplosiveObjectBehaviour:OnActivate(spawnedObject: ObjectTypes.SpawnedObject, objectPart: ObjectTypes.ObjectPart)
    local explosive = self:GetExplosive(objectPart) :: Explosive.Explosive

    if not explosive then
        return
    end

    if explosive.ExplodeOnActivation then
        explosive:Explode()
    end
end

--[[
    Called when an object using this behaviour is updated.
]]
function ExplosiveObjectBehaviour:OnUpdate(spawnedObject: ObjectTypes.SpawnedObject) end

export type ExplosiveObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(ExplosiveObjectBehaviour) & {
    Explosives: {[ObjectTypes.ObjectPart]: Explosive.Explosive}
}

return ExplosiveObjectBehaviour