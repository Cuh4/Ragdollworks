--------------------------------------------------------
-- [Ragdollworks] Activation Link
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