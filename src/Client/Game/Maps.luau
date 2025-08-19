--------------------------------------------------------
-- [Ragdollworks] Maps
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

local Map = require(Rage.ReplicatedStorage.Classes.Map)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling maps.
]]
Maps = Rage:Service("Maps")
Maps.MAP_FOLDER = Rage.Assets:GetAsset("Maps")
Maps.MAP_POSITION = Vector2.new(0, 0)
Maps.BOUNDARY_THICKNESS = 5
Maps.BOUNDARY_COLOR = Color3.fromRGB(15, 15, 15)
Maps.BACKGROUND_SIZE = Vector2.new(10000, 10000)
Maps.BACKGROUND_COLOR = Maps.BOUNDARY_COLOR

Maps.ExistingMaps = {} :: {Map.Map}
Maps.CurrentMap = nil :: Map.Map
Maps.MapInstance = nil :: Model
Maps.IsInMap = false

--[[
    Called when the service starts.
]]
function Maps:OnStart()
    self:LoadMaps()
    self:StartMap(self:GetMap("Testing"))
end

--[[
    Starts the provided map.
]]
function Maps:StartMap(map: Map.Map)
    if self.IsInMap then
        Rage.Logging:Error("Maps:StartMap(): Already in a map.")
    end

    Rage.Logging:Info("Maps:StartMap(): Starting map '"..map.Name.."'.")

    self.CurrentMap = map
    self.IsInMap = true
    self:_SetupMapInstance()
    self:_CreateMapBoundaries()
    self:_CreateMapBackground()
end

--[[
    Sets up a new map instance.<br>
    Used internally. Do not use wrongly.
]]
function Maps:_SetupMapInstance()
    if not self.IsInMap then
        Rage.Logging:Error("Maps:_SetupMapInstance(): Not in a map.")
    end

    if self.MapInstance then
        Rage.Logging:Error("Maps:_SetupMapInstance(): Map instance already setup.")
    end

    self.MapInstance = self.CurrentMap:CreateInstance()

    self.MapInstance:PivotTo(CFrame.new(
        self.MAP_POSITION.X,
        0,
        self.MAP_POSITION.Y
    ))

    self.MapInstance.Parent = game.Workspace
end

--[[
    Creates physical map boundaries.
]]
function Maps:_CreateMapBoundaries()
    if not self.IsInMap then
        Rage.Logging:Error("Maps:CreateMapBoundaries(): Not in a map.")
    end

    -- not fun visualizing this in my head while coding it up at the same time

    local top = self:_CreateBoundaryPart(
        Vector2.new(self.CurrentMap.Size.X + (self.BOUNDARY_THICKNESS * 2), self.BOUNDARY_THICKNESS),
        Vector2.new(0, self.CurrentMap.Size.Y / 2 + (self.BOUNDARY_THICKNESS / 2))
    )

    top.Parent = self.MapInstance

    local bottom = self:_CreateBoundaryPart(
        Vector2.new(self.CurrentMap.Size.X + (self.BOUNDARY_THICKNESS * 2), self.BOUNDARY_THICKNESS),
        Vector2.new(0, -self.CurrentMap.Size.Y / 2 - (self.BOUNDARY_THICKNESS / 2))
    )

    bottom.Parent = self.MapInstance

    local left = self:_CreateBoundaryPart(
        Vector2.new(self.BOUNDARY_THICKNESS, self.CurrentMap.Size.Y),
        Vector2.new(-self.CurrentMap.Size.X / 2 - (self.BOUNDARY_THICKNESS / 2), 0)
    )

    left.Parent = self.MapInstance

    local right = self:_CreateBoundaryPart(
        Vector2.new(self.BOUNDARY_THICKNESS, self.CurrentMap.Size.Y),
        Vector2.new(self.CurrentMap.Size.X / 2 + (self.BOUNDARY_THICKNESS / 2), 0)
    )

    right.Parent = self.MapInstance
end

--[[
    Creates a boundary part.
]]
function Maps:_CreateBoundaryPart(size: Vector2, position: Vector2): Part
    local part = Instance.new("Part")
    part.Name = "MapBoundary"
    part.Color = self.BOUNDARY_COLOR
    part.Anchored = true
    part.CanCollide = true
    part.Size = Vector3.new(size.X, size.Y, 5)
    part.Position = Vector3.new(position.X, position.Y, 0)

    return part
end

--[[
    Creates the background for maps.
]]
function Maps:_CreateMapBackground()
    local background = Instance.new("Part")
    background.Name = "MapBackground"
    background.Color = self.BACKGROUND_COLOR
    background.Anchored = true
    background.CanCollide = false
    background.Size = Vector3.new(1, 1, 1)
    background.Position = Vector3.new(self.MAP_POSITION.X, -10, self.MAP_POSITION.Y)

    local mesh = Instance.new("BlockMesh") -- meshes can exceed part size limit
    mesh.Name = "SizeExtenderMesh"
    mesh.Scale = Vector3.new(self.BACKGROUND_SIZE.X, self.BACKGROUND_SIZE.Y, 1)
    mesh.Parent = background

    background.Parent = self.MapInstance
end

--[[
    Exits the current map.
]]
function Maps:ExitMap()
    if not self.IsInMap then
        Rage.Logging:Error("Maps:ExitMap(): Not in a map.")
    end

    Rage.Logging:Info("Maps:ExitMap(): Exiting map '"..self.CurrentMap.Name.."'.")

    self.IsInMap = false
    self.CurrentMap = nil
    self.MapInstance:Destroy()
end

--[[
    Gets a map by its name.
]]
function Maps:GetMap(name: string): Map.Map
    for _, map in pairs(self.ExistingMaps) do
        if map.Name == name then
            return map
        end
    end
end

--[[
    Loads all maps in MAP_FOLDER into this service.
]]
function Maps:LoadMaps()
    for _, map in pairs(self.MAP_FOLDER:GetChildren()) do
        table.insert(self.ExistingMaps, Map.FromInstance(map))
    end
end

return Maps