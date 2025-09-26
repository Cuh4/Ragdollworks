--------------------------------------------------------
-- [Ragdollworks] Maps
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
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)

local signal = require(Rage.WallyPackages.signal)

local CLI = require(Rage.Path.CLI)
local Binds = require(Rage.Path.Binds)
local Toasts = require(Rage.Path.Toasts)
local Feedback = require(Rage.Path.Feedback)
local Organization = require(Rage.Path.Organization)
local Menus = require(Rage.Path.Menus)

local Map = require(Rage.Path.Classes.Map)
local Bind, BindCollection = require(Rage.Path.Classes.Bind), require(Rage.Path.Classes.BindCollection)

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

Maps.IsSunlight = true

Maps.OnMapStart = signal.new() :: signal.Signal<Map.Map>
Maps.OnMapExit = signal.new() :: signal.Signal
Maps.OnMapLoad = signal.new() :: signal.Signal<Map.Map>

Maps.ExistingMaps = {} :: {Map.Map}
Maps.CurrentMap = nil :: Map.Map?
Maps.MapInstance = nil :: Model?
Maps.IsInMap = false

Maps.InMapBindCollection = nil :: BindCollection.BindCollection

Maps.StartedMapsFolder = Organization:CreateFolder("Map", Rage.Workspace)

--[[
    Called when the service starts.
]]
function Maps:OnStart()
    self:LoadMaps()

    self:_CreateCommands()
    self:_CreateBinds()
end

--[[
    Called every heartbeat.
]]
function Maps:OnHeartbeat()
    Rage.Lighting.ClockTime = self:GetLightingClockTime()
end

--[[
    Creates binds.
]]
function Maps:_CreateBinds()
    self.InMapBindCollection = Binds:CreateBindCollection(
        "InMap",
        {
            Binds:CreateBind(
                "Pause Menu",
                "Shows the pause menu.",
                {Enum.KeyCode.P},
                {ShowTouchButton = true, ShowBindUI = true},

                function(context: Bind.BindContext)
                    if not context.Bind.IsBeingPressed then
                        return
                    end

                    if not self.IsInMap then
                        return
                    end

                    Menus:ToggleScene("PauseMenu")
                end
            )
        }
    )
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

    self:SetSunlight(true)

    Menus:SetScene("InMap")

    self.InMapBindCollection:Enter()

    self.OnMapStart:Fire(self.CurrentMap)

    Feedback:GivePositive(1.1)

    Toasts:DisplayToast(
        "Map",
        "You have entered "..map.Name..".",
        2
    )
end

--[[
    Returns if a part belongs to the current map.
]]
function Maps:BelongsToMap(part: BasePart): boolean
    return self.IsInMap and part:IsDescendantOf(self.MapInstance)
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

    self.MapInstance.Parent = self.StartedMapsFolder

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

    Menus:SetScene("MainMenu")
    self.InMapBindCollection:Exit()
    self.OnMapExit:Fire()

    Feedback:GivePositive(0.9)

    Toasts:DisplayToast(
        "Map",
        "You have exited the map.",
        2
    )
end

--[[
    Sets if sun is out or not.
]]
function Maps:SetSunlight(sunlight: boolean)
    self.IsSunlight = sunlight
end

--[[
    Returns a clock time based on sunlight boolean.
]]
function Maps:GetLightingClockTime(): number
    return self.IsSunlight and 11 or 0
end

--[[
    Gets a map by its name.
]]
function Maps:GetMap(name: string): Map.Map?
    for _, map in pairs(self:GetMaps()) do
        if map.Name == name then
            return map
        end
    end
end

--[[
    Returns all maps.
]]
function Maps:GetMaps(): {Map.Map}
    return self.ExistingMaps
end

--[[
    Registers a map.
]]
function Maps:RegisterMap(map: Map.Map)
    table.insert(self.ExistingMaps, map)
    self.OnMapLoad:Fire(map)
    Rage.Logging:Info("Maps:RegisterMap(): Registered map: "..map.Name)
end

--[[
    Loads all maps in MAP_FOLDER into this service.
]]
function Maps:LoadMaps()
    for _, map: Model in pairs(self.MAP_FOLDER:GetChildren()) do
        Rage.Logging:Info("Maps:LoadMaps(): Loading map: "..map:GetFullName())
        self:RegisterMap(Map.FromInstance(map))
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
            local map = self:GetMap(name)

            if not map then
                Rage.Logging:Warn("No map found with provided name.")
                return
            end

            if self.IsInMap then
                self:ExitMap()
            end

            self:StartMap(map)
        end
    })

    CLI.Conch.register("list-maps", {
        description = "Lists all available maps.",
        arguments = function() end,

        callback = function()
            if #self:GetMaps() == 0 then
                Rage.Logging:Warn("No maps found. This should not be the case.")
                return
            end

            Rage.Logging:Info("Available maps:")

            for _, map in pairs(self:GetMaps()) do
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

    CLI.Conch.register("sunlight", {
        description = "Toggles sunlight.",
        arguments = function() end,

        callback = function()
            self:SetSunlight(not self.IsSunlight)
        end
    })
end

export type Maps = Rage.Service & typeof(Maps)
return Maps