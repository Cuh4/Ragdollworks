--------------------------------------------------------
-- [Ragdollworks] Spawned Wire
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

local Entity = require(script.Parent.Entity)
local ObjectTypes = require(script.Parent.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a wire responsible for connecting two object parts together.
]]
SpawnedWire = {} :: ObjectTypes.SpawnedWire
SpawnedWire.__index = SpawnedWire
setmetatable(SpawnedWire, Entity)

--[[
    Creates a new wire class instance.
]]
function SpawnedWire.New(): ObjectTypes.SpawnedWire
    local self = setmetatable(Entity.New("SpawnedWire"), SpawnedWire) :: ObjectTypes.SpawnedWire
    self.ObjectPartA = nil
    self.ObjectPartB = nil

    return self
end

--[[
    Setups the wire.
]]
function SpawnedWire:Setup(
    partAMousePos: Vector2,
    objectPartA: ObjectTypes.ObjectPart,
    partBMousePos: Vector2,
    objectPartB: ObjectTypes.ObjectPart
)
    self.ObjectPartA = objectPartA
    self.ObjectPartA:MoveWireAttachment(partAMousePos)

    self.ObjectPartB = objectPartB
    self.ObjectPartB:MoveWireAttachment(partBMousePos)

    self:OnConnect()
end

--[[
    Despawns the wire.
]]
function SpawnedWire:Despawn()
    self:OnCleanup()
end

--[[
    Despawns the wire and removes it from the game itself.
]]
function SpawnedWire:Remove()
    require(Rage.Path.Objects):RemoveWire(self)
end

--[[
    Returns if this wire is connected to the provided part.
]]
function SpawnedWire:IsConnectedToPart(part: ObjectTypes.ObjectPart): boolean
    return self.ObjectPartA == part or self.ObjectPartB == part
end

--[[
    Updates this wire.
]]
function SpawnedWire:Update()
    self:OnUpdate()
end

--[[
    Called when the wire needs to be updated.
]]
function SpawnedWire:OnUpdate()
    Rage.Logging:Error(self.Name..": :OnUpdate() not implemented!")
end

--[[
    Called when two object parts need to be connected together with this wire.
]]
function SpawnedWire:OnConnect()
    Rage.Logging:Error(self.Name..": :OnConnect() not implemented!")
end

--[[
    Called when the wire needs to be cleaned up.
]]
function SpawnedWire:OnCleanup()
    Rage.Logging:Error(self.Name..": :OnCleanup() not implemented!")
end

return SpawnedWire