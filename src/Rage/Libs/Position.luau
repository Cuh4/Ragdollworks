--------------------------------------------------------
-- [Rage] Position
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

local Logging = require(script.Parent.Parent.Logging)

-------------------------------
-- // Main
-------------------------------

--[[
    A library providing functionality for joining Vector3s, Vector2s, and CFrames together.
]]
Position = {}

--[[
    Returns if the provided position is a position type.
]]
function Position:IsPosition(position: any): boolean
    return typeof(position) == "Vector3"
        or typeof(position) == "Vector2"
        or typeof(position) == "CFrame"
end

--[[
    Converts the provided position into a Vector3.
]]
function Position:ToVector3(position: PositionType): Vector3
    if typeof(position) == "Vector3" then
        return position
    elseif typeof(position) == "Vector2" then
        return Vector3.new(position.X, position.Y, 0)
    elseif typeof(position) == "CFrame" then
        return position.Position
    end

    Logging:Error("Position:ToVector3(): Invalid position provided.")
end

--[[
    Converts the provided position into a Vector2.
]]
function Position:ToVector2(position: PositionType): Vector2
    if typeof(position) == "Vector3" then
        return Vector2.new(position.X, position.Y)
    elseif typeof(position) == "Vector2" then
        return position
    elseif typeof(position) == "CFrame" then
        return Vector2.new(position.Position.X, position.Position.Y)
    end

    Logging:Error("Position:ToVector2(): Invalid position provided.")
end

--[[
    Converts the provided position into a CFrame.
]]
function Position:ToCFrame(position: PositionType): CFrame
    if typeof(position) == "Vector3" then
        return CFrame.new(position)
    elseif typeof(position) == "Vector2" then
        return CFrame.new(position.X, position.Y, 0)
    elseif typeof(position) == "CFrame" then
        return position
    end

    Logging:Error("Position:ToCFrame(): Invalid position provided.")
end

export type PositionType = Vector3 | Vector2 | CFrame
export type Position = typeof(Position)
return Position