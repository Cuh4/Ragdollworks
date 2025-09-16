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

local signal = require(Rage.WallyPackages.signal)

local CLI = require(Rage.Path.CLI)
local Toasts = require(Rage.Path.Toasts)

local Map = require(Rage.Path.Classes.Map)

-------------------------------
-- // Main
-------------------------------

--[[
    A service for handling maps.
]]
Maps = Rage:Service("Maps") :: Maps
Maps.MAP_FOLDER = Rage.Assets:GetAsset("Maps")
Maps.MAP_POSITION = Vector2.new(0, 0)
Maps.BOUNDARY_THICKNESS = 100
Maps.BOUNDARY_Z_SIZE = 15
Maps.BOUNDARY_COLOR = Color3.fromRGB(15, 15, 15)
Maps.BACKGROUND_SIZE = Vector2.new(10000, 10000)
Maps.BACKGROUND_COLOR = Maps.BOUNDARY_COLOR

Maps.ZPosition = 0

Maps.OnMapStart = signal.new() :: signal.Signal<Map.Map>
Maps.OnMapExit = signal.new() :: signal.Signal

Maps.ExistingMaps = {} :: {Map.Map}
Maps.CurrentMap = nil :: Map.Map?
Maps.MapInstance = nil :: Model?
Maps.IsInMap = false

--[[
    Called when the service starts.
]]
function Maps:OnStart()
    self:LoadMaps()

    self:_CreateCommands()
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

    self.OnMapStart:Fire(self.CurrentMap)

    Toasts:DisplayToast(
        "Map",
        "You have entered "..map.Name..".",
        2
    )
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

    local background: BasePart = self.MapInstance:FindFirstChild("MapBackground")

    if not background then
        Rage.Logging:Error("Maps:_SetupMapInstance(): Map instance does not have a background part.")
    end

    if self.MapInstance.PrimaryPart ~= background then
        self.MapInstance.PrimaryPart = background
    end

    background.CanCollide = false
    background.CanTouch = false
    background.CanQuery = true

    self.MapInstance.Parent = Rage.Workspace

    self.MapInstance:MoveTo(Vector3.new(
        self.MAP_POSITION.X,
        self.MAP_POSITION.Y,
        0
    ))

    self.ZPosition = background.Position.Z
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
        Vector2.new(self.MAP_POSITION.X, self.MAP_POSITION.Y + (self.CurrentMap.Size.Y / 2 + (self.BOUNDARY_THICKNESS / 2)))
    )

    top.Parent = self.MapInstance

    local bottom = self:_CreateBoundaryPart(
        Vector2.new(self.CurrentMap.Size.X + (self.BOUNDARY_THICKNESS * 2), self.BOUNDARY_THICKNESS),
        Vector2.new(self.MAP_POSITION.X, self.MAP_POSITION.Y + (-self.CurrentMap.Size.Y / 2 - (self.BOUNDARY_THICKNESS / 2)))
    )

    bottom.Parent = self.MapInstance

    local left = self:_CreateBoundaryPart(
        Vector2.new(self.BOUNDARY_THICKNESS, self.CurrentMap.Size.Y),
        Vector2.new(self.MAP_POSITION.X + (-self.CurrentMap.Size.X / 2 - (self.BOUNDARY_THICKNESS / 2)), self.MAP_POSITION.Y)
    )

    left.Parent = self.MapInstance

    local right = self:_CreateBoundaryPart(
        Vector2.new(self.BOUNDARY_THICKNESS, self.CurrentMap.Size.Y),
        Vector2.new(self.MAP_POSITION.X + (self.CurrentMap.Size.X / 2 + (self.BOUNDARY_THICKNESS / 2)), self.MAP_POSITION.Y)
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
    part.Size = Vector3.new(size.X, size.Y, math.abs(self.BOUNDARY_Z_SIZE) * 2)
    part.Position = Vector3.new(position.X, position.Y, self.BOUNDARY_Z_SIZE / 2)

    return part
end

--[[
    Creates the background for maps.
]]
function Maps:_CreateMapBackground()
    local backgroundZSize = 1

    local background = Instance.new("Part")
    background.Name = "ScaledMapBackground"
    background.Color = self.BACKGROUND_COLOR
    background.Anchored = true
    background.CanCollide = false
    background.Size = Vector3.new(1, 1, backgroundZSize)
    background.Position = Vector3.new(self.MAP_POSITION.X, self.MAP_POSITION.Y, self.ZPosition - backgroundZSize)

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
    self.MapInstance = nil

    self.OnMapExit:Fire()

    Toasts:DisplayToast(
        "Map",
        "You have exited the map.",
        2
    )
end

--[[
    Gets a map by its name.
]]
function Maps:GetMap(name: string): Map.Map?
    for _, map in pairs(self.ExistingMaps) do
        if map.Name == name then
            return map
        end
    end

    return nil
end

--[[
    Loads all maps in MAP_FOLDER into this service.
]]
function Maps:LoadMaps()
    for _, map in pairs(self.MAP_FOLDER:GetChildren()) do
        Rage.Logging:Info("Maps:LoadMaps(): Loaded map '"..map.Name.."'.")
        table.insert(self.ExistingMaps, Map.FromInstance(map))
    end
end

--[[
    Creates commands.
]]
function Maps:_CreateCommands()
    CLI.Conch.register("start-map", {
        description = "Starts a map by its name.",

        arguments = function()
            return CLI.Conch.args.string("MapName", "The name of the map to start.")
        end,

        callback = function(name: string)
            if self.IsInMap then
                Rage.Logging:Warn("Already in a map. Exit the current map before starting a new one.")
                return
            end

            local map = self:GetMap(name)

            if not map then
                Rage.Logging:Warn("No map found with provided name.")
                return
            end

            self:StartMap(map)
        end
    })

    CLI.Conch.register("list-maps", {
        description = "Lists all available maps.",
        arguments = function() end,

        callback = function()
            if #self.ExistingMaps == 0 then
                Rage.Logging:Warn("No maps found. This should not be the case.")
                return
            end

            Rage.Logging:Info("Available maps:")

            for _, map in pairs(self.ExistingMaps) do
                Rage.Logging:Info("- " .. map.Name)
            end
        end
    })

    CLI.Conch.register("exit-map", {
        description = "Exits the current map.",
        arguments = function() end,

        callback = function()
            if not self.IsInMap then
                Rage.Logging:Warn("Can't exit map, not in a map.")
                return
            end

            self:ExitMap()
        end
    })
end

export type Maps = Rage.Service & typeof(Maps)
return Maps