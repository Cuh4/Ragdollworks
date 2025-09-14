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
local signal = require(Rage.WallyPackages.signal)

local WireTargetType = require(Rage.ReplicatedStorage.Enums.WireTargetType)

-------------------------------
-- // Main
-------------------------------

-- this only exists because of a fucking little quirk with the roblox lsp extension (why aren't i using the luau extension? because that has way more fucking annoying quirks)
-- basically, since SpawnedObject.luau requires Object.luau and ObjectPart.luau with their own exported types, the SpawnedObject type in SpawnedObject.luau
-- cannot be fucking accessed by anywhere. so now i have to write all the types here AND manually type the functions in the types, meaning i have to maintain
-- the (almost) same code in two places. this is so fucking stupid and ive been endlessly thinking of alternatives to get around this and the only one ive come to
-- is this shitty fucking file

export type Entity = {
    Name: string,

    New: (name: string) -> Entity,

    GetName: (self: Entity) -> string,
    Despawn: (self: Entity) -> nil, -- removes instances, etc
    Remove: (self: Entity) -> nil -- despawns and removes data
}

export type Object = {
    Name: string,
    Description: string,
    Category: string,
    Settings: ObjectSettings,
    Behaviours: {ObjectBehaviour},
    Instance: Model,
    IconAssetID: string?,

    New: (name: string, description: string, category: string, settings: ObjectSettings, behaviours: {ObjectBehaviour}, instance: Model, iconAssetID: string) -> Object,
    FromInstance: (instance: Model) -> Object,

    CanPlayerSpawn: (self: Object) -> boolean,
    Spawn: (self: Object) -> Model
}

export type ObjectSettings = {
    CanPartsCollide: boolean,
    IsSpawnable: boolean
}

export type SpawnedObject = Entity & {
    ID: number,
    Object: Object,
    Instance: Model,
    Parts: {[BasePart]: ObjectPart},
    Behaviours: {ObjectBehaviour},
    IsDespawning: boolean,

    New: (ID: number, object: Object) -> SpawnedObject,

    Update: (self: SpawnedObject, startBound: Vector2, endBound: Vector2, dragPosition: Vector2) -> nil,
    Setup: (self: SpawnedObject, spawnPos: Vector3) -> nil,
    MoveTo: (self: SpawnedObject, position: Vector2) -> nil,
    RotateTo: (self: SpawnedObject, radians: number) -> nil,
    RotateBy: (self: SpawnedObject, radians: number) -> nil,
    SetupAttributes: (self: SpawnedObject) -> nil,
    CreateNoCollideConstraints: (self: SpawnedObject) -> nil,
    FindParts: (self: SpawnedObject) -> {[BasePart]: ObjectPart},
    GetPart: (self: SpawnedObject, part: BasePart) -> ObjectPart?,
    RemovePart: (self: SpawnedObject, part: BasePart) -> nil,
    HasPart: (self: SpawnedObject, part: ObjectPart) -> boolean,
    Freeze: (self: SpawnedObject) -> nil,
    Unfreeze: (self: SpawnedObject) -> nil,
    Pause: (self: SpawnedObject) -> nil,
    Unpause: (self: SpawnedObject) -> nil,
    AddContextMenuItem: (self: SpawnedObject, name: string, onTrigger: ContextMenuItemCallback) -> nil,
    Despawn: (self: SpawnedObject) -> nil,
    Remove: (self: SpawnedObject) -> nil
}

export type ObjectPart = {
    SELECTION_COLOR: Color3,
    HIGHLIGHT_COLOR: Color3,
    SELECTION_BOX_THICKNESS: number,
    DRAGGING_RESPONSIVENESS: number,

    Part: BasePart,
    SpawnedObject: SpawnedObject,
    Settings: ObjectPartSettings,
    Activated: boolean,
    Dragging: boolean,
    Frozen: boolean,
    Paused: boolean,
    SlomoLock: boolean,
    Selected: boolean,
    Highlighted: boolean,
    AlignPositionInstance: AlignPosition,
    AngularVelocityInstance: AngularVelocity,
    DraggingAttachmentInstance: Attachment,
    SelectionBoxInstance: SelectionBox,
    RotationForce: number,
    Layer: number,
    ContextMenu: ContextMenu,

    OnDragStart: signal.Signal,
    OnDragEnd: signal.Signal,
    OnActivate: signal.Signal,
    OnDespawn: signal.Signal,

    New: (part: BasePart, spawnedObject: SpawnedObject, layer: number, settings: ObjectPartSettings) -> ObjectPart,
    FromPart: (part: BasePart, spawnedObject: SpawnedObject) -> ObjectPart,

    Setup: (self: ObjectPart) -> nil,
    SetupContextMenu: (self: ObjectPart) -> nil,
    SetupAttachments: (self: ObjectPart) -> nil,
    SetupSelection: (self: ObjectPart) -> nil,
    SetupDragging: (self: ObjectPart) -> nil,
    UpdateDragging: (self: ObjectPart, dragPosition: Vector2) -> nil,
    UpdateSelection: (self: ObjectPart) -> nil,
    UpdatePhysics: (self: ObjectPart, startBound: Vector2, endBound: Vector2) -> nil,
    Update: (self: ObjectPart, startBound: Vector2, endBound: Vector2, dragPosition: Vector2) -> nil,
    KeepWithinBounds: (self: ObjectPart, startBound: Vector2, endBound: Vector2) -> nil,
    Lock: (self: ObjectPart) -> nil,
    Activate: (self: ObjectPart) -> nil,
    SetRotationForce: (self: ObjectPart, force: number) -> nil,
    Drag: (self: ObjectPart, position: Vector2) -> nil,
    StopDragging: (self: ObjectPart) -> nil,
    Freeze: (self: ObjectPart) -> nil,
    Unfreeze: (self: ObjectPart) -> nil,
    SetSlomoLock: (self: ObjectPart) -> nil,
    UnsetSlomoLock: (self: ObjectPart) -> nil,
    Pause: (self: ObjectPart) -> nil,
    Unpause: (self: ObjectPart) -> nil,
    Select: (self: ObjectPart) -> nil,
    Deselect: (self: ObjectPart) -> nil,
    Highlight: (self: ObjectPart) -> nil,
    Unhighlight: (self: ObjectPart) -> nil,
    GetPosition: (self: ObjectPart) -> Vector2,
    GetPosition3D: (self: ObjectPart) -> Vector3,
    GetVelocity: (self: ObjectPart) -> Vector2,
    GetVelocity3D: (self: ObjectPart) -> Vector3,
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

export type Wire = {
    Name: string,
    Description: string,
    WireClass: SpawnedWire,
    IconAssetID: string?
}

export type SpawnedWire = Entity & {
    TargetA: WireTarget,
    TargetB: WireTarget,
    StorageInstance: Instance,

    New: () -> SpawnedWire,

    Setup: (self: SpawnedWire, targetA: WireTarget, mousePosA: Vector2, targetB: WireTarget, mousePosB: Vector2) -> nil,
    Remove: (self: SpawnedWire) -> nil,
    Despawn: (self: SpawnedWire) -> nil,
    IsConnectedToPart: (self: SpawnedWire, part: ObjectPart) -> boolean,
    Update: (self: SpawnedWire) -> nil,

    OnUpdate: (self: SpawnedWire) -> nil,
    OnConnect: (self: SpawnedWire) -> nil,
    OnCleanup: (self: SpawnedWire) -> nil
}

export type WireTarget = {
    Target: WireTargetInstance,
    Part: BasePart,
    Attachment: Attachment,
    Type: WireTargetType.WireTargetType,

    New: (target: WireTargetInstance) -> WireTarget,

    _CreateWorldPart: (self: WireTarget) -> BasePart,
    GetPosition: (self: WireTarget) -> Vector2,
    CreateAttachment: (self: WireTarget, mousePos: Vector2) -> Attachment,
    BelongsTo: (self: WireTarget, objectPart: ObjectPart) -> boolean,
    Cleanup: (self: WireTarget) -> nil
}

-- dunno how to name this
export type WireTargetInstance = ObjectPart | Vector2

export type ContextMenu = {
    ObjectPart: ObjectPart,
    Items: {ContextMenuItem},
    Visible: boolean,

    OnShow: signal.Signal,
    OnHide: signal.Signal,

    ScreenGUI: ScreenGui,
    ContextMenuUI: ScrollingFrame,

    New: (objectPart: ObjectPart) -> ContextMenu,

    AddContextMenuItem: (self: ContextMenu, name: string, onTrigger: ContextMenuItemCallback) -> ContextMenuItem,
    _AddUIItems: (self: ContextMenu) -> nil,
    _RemoveUIItems: (self: ContextMenu) -> nil,
    Show: (self: ContextMenu, position: UDim2) -> nil,
    Hide: (self: ContextMenu) -> nil
}

export type ContextMenuItem = {
    Name: string,
    ContextMenu: ContextMenu,
    OnTrigger: signal.Signal,
    _ContextMenuItemUI: Frame,

    New: (name: string, contextMenu: ContextMenu) -> ContextMenuItem,

    GetUI: (self: ContextMenuItem) -> (Frame, TextButton),
    Trigger: (self: ContextMenuItem) -> nil
}

export type ContextMenuItemCallback = (contextMenuItem: ContextMenuItem) -> nil

return {}