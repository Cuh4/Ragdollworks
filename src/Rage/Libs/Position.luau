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
    end
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
end

export type PositionType = Vector3 | Vector2 | CFrame
export type Position = typeof(Position)
return Position