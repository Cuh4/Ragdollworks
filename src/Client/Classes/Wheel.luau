--------------------------------------------------------
-- [Ragdollworks] Wheel
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