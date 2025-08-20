--------------------------------------------------------
-- [Ragdollworks] Types
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

local Rage = require(game:GetService("ReplicatedStorage").Rage)
local signal = require(Rage.ReplicatedStorage.Packages.signal)

-------------------------------
-- // Main
-------------------------------

-- this only exists because of a fucking little quirk with the roblox lsp extension (why aren't i using the luau extension? because that has way more fucking annoying quirks)
-- basically, since SpawnedObject.luau requires Object.luau and ObjectPart.luau with their own exported types, the SpawnedObject type in SpawnedObject.luau
-- cannot be fucking accessed by anywhere. so now i have to write all the types here AND manually type the functions in the types, meaning i have to maintain
-- the (almost) same code in two places. this is so fucking stupid and ive been endlessly thinking of alternatives to get around this and the only one ive come to
-- is this shitty fucking file

export type Object = {
    Name: string,
    Description: string,
    Category: string,
    Settings: ObjectSettings,
    Behaviours: {ObjectBehaviour},
    Instance: Model,

    New: (name: string, description: string, category: string, settings: ObjectSettings, behaviours: {ObjectBehaviour}, instance: Model) -> Object,
    FromInstance: (instance: Model) -> Object,

    CanPlayerSpawn: (self: Object) -> boolean,
    Spawn: (self: Object) -> Model
}

export type ObjectSettings = {
    CanPartsCollide: boolean,
    IsSpawnable: boolean
}

export type SpawnedObject = {
    ID: number,
    Object: Object,
    Instance: Model,
    Parts: {[BasePart]: ObjectPart},
    Behaviours: {ObjectBehaviour},

    _RemovalRequested: signal.Signal,

    New: (ID: number, object: Object, instance: Model) -> SpawnedObject,

    Update: (self: SpawnedObject, startBound: Vector2, endBound: Vector2) -> nil,
    Setup: (self: SpawnedObject) -> nil,
    MoveTo: (self: SpawnedObject, position: Vector2) -> nil,
    SetupAttributes: (self: SpawnedObject) -> nil,
    CreateNoCollideConstraints: (self: SpawnedObject) -> nil,
    FindParts: (self: SpawnedObject) -> {[BasePart]: ObjectPart},
    GetPart: (self: SpawnedObject, part: BasePart) -> ObjectPart?,
    RemovePart: (self: SpawnedObject, part: BasePart) -> nil,
    Despawn: (self: SpawnedObject) -> nil,
    Remove: (self: SpawnedObject) -> nil
}

export type ObjectPart = {
    Part: BasePart,
    Settings: ObjectPartSettings,
    Activated: boolean,
    Dragging: boolean,
    Frozen: boolean,
    AlignPositionInstance: AlignPosition,
    AngularVelocityInstance: AngularVelocity,
    AttachmentInstance: Attachment,
    RotationForce: number,

    OnDragStart: signal.Signal,
    OnDragEnd: signal.Signal,
    OnActivate: signal.Signal,
    OnDespawn: signal.Signal,

    New: (part: BasePart, settings: ObjectPartSettings) -> ObjectPart,
    FromPart: (part: BasePart) -> ObjectPart,

    Setup: (self: ObjectPart) -> nil,
    SetupDragging: (self: ObjectPart) -> nil,
    Update: (self: ObjectPart, startBound: Vector2, endBound: Vector2) -> nil,
    KeepWithinBounds: (self: ObjectPart, startBound: Vector2, endBound: Vector2) -> nil,
    LockZAxis: (self: ObjectPart) -> nil,
    Activate: (self: ObjectPart) -> nil,
    SetRotationForce: (self: ObjectPart, force: number) -> nil,
    Drag: (self: ObjectPart) -> nil,
    StopDragging: (self: ObjectPart) -> nil,
    Despawn: (self: ObjectPart) -> nil
}

export type ObjectPartSettings = {
    IsDraggable: boolean
}

export type ObjectBehaviour = {
    SpawnedObject: SpawnedObject,

    New: (spawnedObject: SpawnedObject) -> ObjectBehaviour,

    OnSpawn: (self: ObjectBehaviour) -> nil,
    OnPreDespawn: (self: ObjectBehaviour) -> nil,
    OnActivate: (self: ObjectBehaviour, objectPart: ObjectPart) -> nil,
    OnUpdate: (self: ObjectBehaviour) -> nil
}

return {}