--------------------------------------------------------
-- [Ragdollworks] Wheel
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

local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a wheel (tied to a spawned object).
]]
Wheel = {} :: Wheel
Wheel.__index = Wheel

--[[
    Creates a new Wheel class instance.
]]
function Wheel.New(spawnedObject: ObjectTypes.SpawnedObject): Wheel
    local self = setmetatable({}, Wheel) :: Wheel
    self.SpawnedObject = spawnedObject
    self.WheelConnector = self.SpawnedObject:GetPartByName("WheelConnector") or Rage.Logging:Error("Wheel: No `WheelConnector` part found for object "..spawnedObject.Object.Name) :: ObjectTypes.ObjectPart
    self.Motor = self.WheelConnector.Part:FindFirstChild("Motor") or Rage.Logging:Error("Wheel: No `Motor` part found for object "..spawnedObject.Object.Name) :: HingeConstraint
    self.MotorSpeed = self.Motor.AngularVelocity

    self.Enabled = false
    self.Reversed = false

    self:Setup()

    return self
end

--[[
    Setups the wheel. One-time use.
]]
function Wheel:Setup()
    for _, part in pairs(self.SpawnedObject.Parts) do
        self:CreateContextMenuItems(part)
    end
end

--[[
    Creates context menu items.
]]
function Wheel:CreateContextMenuItems(part: ObjectTypes.ObjectPart)
    part.ContextMenu:AddContextMenuItem("Reverse", function(_: ObjectTypes.ContextMenuItem)
        self:Reverse()
    end)
end

--[[
    Toggles the wheel motor.
]]
function Wheel:Toggle()
    self.Enabled = not self.Enabled
end

--[[
    Reverses the wheel motor.
]]
function Wheel:Reverse()
    self.Reversed = not self.Reversed
end

--[[
    Updates this wheel.
]]
function Wheel:Update()
    self.Motor.AngularVelocity = self.Reversed and -self.MotorSpeed or self.MotorSpeed
    self.Motor.ActuatorType = self.Enabled and Enum.ActuatorType.Motor or Enum.ActuatorType.None
end

export type Wheel = typeof(Wheel) & {
    SpawnedObject: ObjectTypes.SpawnedObject,
    WheelConnector: ObjectTypes.ObjectPart,
    Motor: HingeConstraint,
    MotorSpeed: number,

    Enabled: boolean,
    Reversed: boolean
}

return Wheel