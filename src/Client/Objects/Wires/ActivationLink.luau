--------------------------------------------------------
-- [Ragdollworks] Activation Link
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

local SpawnedWire = require(Rage.ReplicatedStorage.Classes.Objects.SpawnedWire)
local ObjectTypes = require(Rage.ReplicatedStorage.Classes.Objects.Types)

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
    self.Beam.Attachment0 = self.ObjectPartB.WireAttachmentInstance -- texture is flipped lmao
    self.Beam.Attachment1 = self.ObjectPartA.WireAttachmentInstance
    self.Beam.Parent = self.ObjectPartA.Part

    self.OnActivationConnection = self.ObjectPartA.OnActivate:Connect(function()
        if os.clock() - (self.LastActivation or 0) < self.ACTIVATION_DELAY then
            Rage.Logging:Info("ActivationLink: Activation cooldown")
            return
        end

        task.wait(self.ACTIVATION_DELAY)

        self.LastActivation = os.clock()
        self.ObjectPartB:Activate()
    end)
end

--[[
    Called when the wire needs to be cleaned up.
]]
function ActivationLink:OnCleanup()
    self.Beam:Destroy()
    self.OnActivationConnection:Disconnect()
end

export type ActivationLink = {
    ACTIVATION_DELAY: number,
    Beam: Beam,
    OnActivationConnection: signal.Connection
} & typeof(ActivationLink) & ObjectTypes.SpawnedWire

return {
    Name = "Activation Link",
    Description = "A non-physics wire that propagates activation signals from one object part to the other.",
    WireClass = ActivationLink
} :: ObjectTypes.Wire