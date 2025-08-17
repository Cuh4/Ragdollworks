# PRIORITY
FROM v1.14.0 ONWARDS: create a branch for each version. when finished, build then merge to main then publish

# misc
- recreate interstellar miller's planet tsunami with scaled blue wave vehicle
    - use a transparent vehicle below the player to let them walk in the water as if the water is shallow. constantly move the vehicle below the player too

# docs
- document all built-in services and libraries

# noir todo
- V3
    - hoarderservice: allow serialization and deserialization of class instances within instances, and make `Hoardable` class inheritance optional
        - `Hoardable` methods can just be moved into the service
        - new `Hoardable` should just provide shortcut methods to the service methods like `:LoadAll()` and `:Save()` and `:Remove()`
        - remove need for `service` argument. save in hoarderservice itself
        - instead of accepting `tblName`, accept `tbl` instead
        
        ```lua
        Noir.Services.HoarderService:LoadAll(
            "Basket", -- from
            self.Basket, -- to
            { -- class lookup table (HoarderService automatically converts keys of this table to the class names of the classes in this tbl)
                Fruit,
                Addon.Classes.FruitIcon
            }
        )

        Noir.Services.HoarderService:Save(
            fruit, -- class instance to save
            "Basket", -- to
            fruit.ID -- index in table. use nil for `table.insert` method
        )

        Noir.Services.HoarderService:Remove(
            "Basket", -- to remove from
            fruit.ID -- id
        )

        Noir.Services.HoarderService:SaveAll( -- ids are gathered from `self.Basket` index
            self.Basket, -- from
            "Basket", -- to
            { -- class lookup table (HoarderService automatically converts keys of this table to the class names of the classes in this tbl)
                Fruit,
                FruitIcon = Addon.Classes.FruitIcon
            }
        )
        ```

- in table lib, prevent stack overflow by tarcking journey in deep tables. a helper method for deep iteration could handle this to prevent copying code plenty of times (helper method should be used in debugging.lua)

- ObjectService: add `:TrackObject()` and `:UntrackObject()`
    - when an object despawns, automatically untrack
    - add persistence
    - add `.Speed` attribute to `NoirObject`
    - tracked objects will get the speed attribute updated etc
        - to calculate speed: delta of position magnitude in a tick * tps
            - position magnitude = math.sqrt((x ^ 2) + (y ^ 2) + (z ^ 2))

- make logging library oop
    ```lua
    -- just a concept. haven't researched logging much. once i get to working on this, ill research the topic for sure and add/change features based on what i find
    Noir.Libraries.Logging.DefaultLogger
    Noir.Libraries.Logging:Info("Title", "sup") -- uses DefaultLogger's `:Info()` method

    local logger = Noir.Libraries.Logging:CreateLogger("Name")
    logger:Info("Title", "Message")
    logger:SetEnabled(false)
    logger:Error("Title", "Message %s", "g") -- will not do anything. the logger is disabled

    ---@param log NoirLog
    logger.OnLog:Once(function(log)
        log.Title
        log.Message
    end)

    Noir.Libraries.Logging:GetLogger("Name")
    Noir.Libraries.Logging:RemoveLogger(logger)

    Noir.Libraries.Logging:Info("Name", "Title", "Message %s", "g")

    -- for triggering errors:
    Noir.Services.DebuggerService:TriggerError("error") -- different service (not implemented yet)
    ```

- zone library
    - create a zone of different types (circular, rectangular, etc)
    - includes methods for returning whether or not an object is in the zone, a vehicle, etc

    ```lua
    -- behind the scenes
    RectangularZone = Noir.Class("NoirRectangularZone", Noir.Classes.ZoneClass)

    function RectangularZone:Init(pos, size)
        -- set attributes
    end

    function RectangularZone:_Bounds(pos)
        -- logic to determine if a pos is in the zone. will be used for `:IsBodyInZone()`, etc, which comes from `ZoneClass`
        return true
    end
    ```

    ```lua
    local positions = RelPos:At("TileName", 2.5, 3.5, 0) -- tile name, xOffset, yOffset, zOffset. returns a table of matrices representing the position of all tiles of the name with the offset factored in

    for _, pos in pairs(positions) do
        local zone = Noir.Libraries.Zones:CreateCircleZone(pos)
        print(zone:IsPlayerInZone(player))
        print(zone:IsBodyInZone(body))
        print(zone:IsObjectInZone(object))
        print(zone:IsVehicleInZone(vehicle))
    end
    ```

- communication service
    - service to communicate between addons
    - messageservice should use this to synchronize messages (when an addon sends a message, communicate to other addons that it did so the other addons can store the message too)
    ```lua
    Noir.Services.CommunicationService:Send("Hello Addon", function(response) -- string, tables, etc, are supported
        print(response)
    end) -- IF THE FUNCTION IS OMITTED, A RESPONSE SHOULD NOT BE GIVEN BY OTHER ADDONS
    ```