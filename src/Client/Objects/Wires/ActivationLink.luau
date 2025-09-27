--------------------------------------------------------
-- [Ragdollworks] Activation Link
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
        GitHub Repository: https://github.com/Cuh4/RagdollWorks

    ----------------------------
]]

-------------------------------
-- // Variables
-------------------------------

local Rage = require(game:GetService("ReplicatedStorage").Rage)
local signal = require(Rage.WallyPackages.signal)

local Wire = require(Rage.Path.Classes.Objects.Wire)
local SpawnedWire = require(Rage.Path.Classes.Objects.SpawnedWire)
local ObjectTypes = require(Rage.Path.Classes.Objects.Types)

local Toasts = require(Rage.Path.Toasts)
local RbxAssets = require(Rage.Path.RbxAssets)

local WireTargetType = require(Rage.Path.Enums.WireTargetType)

-------------------------------
-- // Main
-------------------------------

--[[
    A non-physics wire that propagates activation signals from one object part
    to the other.
]]
ActivationLink = {} :: ActivationLink
ActivationLink.__index = ActivationLink
setmetatable(ActivationLink, SpawnedWire)

--[[
    Creates a new ActivationLink class instance.
]]
function ActivationLink.New(): ActivationLink
    local self = setmetatable(SpawnedWire.New(), ActivationLink) :: ActivationLink
    self.ACTIVATION_DELAY = 0.1
    self.Beam = nil :: Beam
    self.LastActivation = nil

    return self
end

--[[
    Called every update.
]]
function ActivationLink:OnUpdate() end

--[[
    Called on instantiation.
]]
function ActivationLink:OnConnect()
    self.Beam = Rage.Assets:GetAsset("ActivationLinkWireBeam"):Clone()
    self.Beam.Attachment0 = self.TargetB.Attachment -- texture is flipped lmao
    self.Beam.Attachment1 = self.TargetA.Attachment
    self.Beam.Parent = self.StorageInstance

    if self.TargetA.Type == WireTargetType.WORLD or self.TargetB.Type == WireTargetType.WORLD then
        Toasts:DisplayToast(
            "Activation Link",
            "This wire is only functional when connected to two parts.",
            5
        )

        return
    end

    self.OnActivationConnection = self.TargetA.Target.OnActivate:Connect(function()
        if os.clock() - (self.LastActivation or 0) < self.ACTIVATION_DELAY then
            Rage.Logging:Info("ActivationLink: Activation cooldown")
            return
        end

        task.wait(self.ACTIVATION_DELAY)

        self.LastActivation = os.clock()
        self.TargetB.Target:Activate()
    end)
end

--[[
    Called when the wire needs to be cleaned up.
]]
function ActivationLink:OnCleanup()
    self.Beam:Destroy()

    if self.OnActivationConnection then
        self.OnActivationConnection:Disconnect()
    end
end

export type ActivationLink = ObjectTypes.SpawnedWire & typeof(ActivationLink) &  {
    ACTIVATION_DELAY: number,
    Beam: Beam,
    OnActivationConnection: signal.Connection?
}

return Wire.New(
    2,
    "Activation Link",
    "A non-physics wire that propagates activation signals from one object part to the other.",
    ActivationLink,
    false,
    RbxAssets.ACTIVATION_LINK_WIRE_ICON
)