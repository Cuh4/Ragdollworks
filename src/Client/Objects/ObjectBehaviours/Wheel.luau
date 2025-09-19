--------------------------------------------------------
-- [Ragdollworks] Wheel
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

local ObjectBehaviour = require(Rage.Path.Classes.Objects.ObjectBehaviour)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    An object behaviour for handling wheel objects.
]]
WheelObjectBehaviour = {} :: WheelObjectBehaviour
WheelObjectBehaviour.__index = WheelObjectBehaviour
setmetatable(WheelObjectBehaviour, ObjectBehaviour)

--[[
    Creates a new WheelObjectBehaviour class instance.
]]
function WheelObjectBehaviour.New(spawnedObject: ObjectTypes.SpawnedObject): WheelObjectBehaviour
    local self = setmetatable(ObjectBehaviour.New(spawnedObject), WheelObjectBehaviour) :: WheelObjectBehaviour
    self.WheelConnector = nil
    self.Motor = nil
    self.Enabled = false

    return self
end

--[[
    Called when an object using this behaviour is spawned.
]]
function WheelObjectBehaviour:OnSpawn()
    self.WheelConnector = self.SpawnedObject:GetPartByName("WheelConnector") or Rage.Logging:Error("WheelObjectBehaviour: No `WheelConnector` part found for object "..self.SpawnedObject.Object.Name) :: ObjectTypes.ObjectPart
    self.Motor = self.WheelConnector.Part:FindFirstChild("Motor") or Rage.Logging:Error("WheelObjectBehaviour: No `Motor` part found for object "..self.SpawnedObject.Object.Name) :: HingeConstraint
end

--[[
    Called when an object using this behaviour is about to be despawned.
]]
function WheelObjectBehaviour:OnPreDespawn() end

--[[
    Called when an object using this behaviour is activated.
]]
function WheelObjectBehaviour:OnActivate(_: ObjectTypes.ObjectPart)
    self.Enabled = not self.Enabled
end

--[[
    Called when an object using this behaviour is updated.
]]
function WheelObjectBehaviour:OnUpdate()
    self.Motor.ActuatorType = self.Enabled and Enum.ActuatorType.Motor or Enum.ActuatorType.None
end

export type WheelObjectBehaviour = ObjectTypes.ObjectBehaviour & typeof(WheelObjectBehaviour) & {
    WheelConnector: ObjectTypes.ObjectPart,
    Motor: HingeConstraint,
    Enabled: boolean
}

return WheelObjectBehaviour