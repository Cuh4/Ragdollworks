--------------------------------------------------------
-- [Rage] Position
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

local Logging = require(script.Parent.Parent.Logging)

-------------------------------
-- // Main
-------------------------------

--[[
    A library providing functionality for joining Vector3s, Vector2s, and CFrames together.
]]
Position = {}

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
    elseif position.IsA and position:IsA("PVInstance") then
        return position:GetPivot().Position
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
    elseif position.IsA and position:IsA("PVInstance") then
        local _position = position:GetPivot().Position
        return Vector2.new(_position.X, _position.Y)
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
    elseif position.IsA and position:IsA("PVInstance") then
        return position:GetPivot().Position
    end

    Logging:Error("Position:ToCFrame(): Invalid position provided.")
end

export type PositionType = Vector3 | Vector2 | CFrame | PVInstance
export type Position = typeof(Position)
return Position