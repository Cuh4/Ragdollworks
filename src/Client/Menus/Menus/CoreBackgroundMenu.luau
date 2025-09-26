--------------------------------------------------------
-- [Ragdollworks] Core Background Menu
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

local Menu = require(Rage.Path.Classes.Menu)


-------------------------------
-- // Main
-------------------------------

--[[
    A background menu to provide backgrounds for other screen-covering menus.
]]
CoreBackgroundMenu = {} :: CoreBackgroundMenu
CoreBackgroundMenu.__index = CoreBackgroundMenu
setmetatable(CoreBackgroundMenu, Menu)

--[[
    Creates a new CoreBackgroundMenu class instance.
]]
function CoreBackgroundMenu.New(): CoreBackgroundMenu
    local self = setmetatable(Menu.New(
        "CoreBackgroundMenu",
        {"MainMenu", "MapSelection"},
        {CanBeForceHidden = false}
    ), CoreBackgroundMenu) :: CoreBackgroundMenu

    self.GRADIENT_ROTATION_SPEED = 0.001 -- every update
    self.TILING_POSITION_SPEED = 0.001 -- every update

    self.RootContainer = self.ScreenGUI.Root
    self.RootGradient = self.RootContainer.UIGradient
    self.BackgroundTilingImage = self.RootContainer.BackgroundTiling

    self.GradientRotationAlpha = 0
    self.TilingPositionAlpha = 0

    return self
end

--[[
    Handles background fancy effects.
]]
function CoreBackgroundMenu:HandleFancyEffects(deltaTime: number)
    -- Update alphas
    local dt = deltaTime * 60 -- match results of 60 fps
    self.GradientRotationAlpha += self.GRADIENT_ROTATION_SPEED * dt

    if self.GradientRotationAlpha > 1 then
        self.GradientRotationAlpha = 0
    end

    self.TilingPositionAlpha += self.TILING_POSITION_SPEED * dt

    if self.TilingPositionAlpha > 1 then
        self.TilingPositionAlpha = 0
    end

    -- Lerp
    self.RootGradient.Rotation = Rage.Libs.Math:Lerp(-180, 180, self.GradientRotationAlpha)
    self.BackgroundTilingImage.Position = UDim2.fromScale(0, Rage.Libs.Math:Lerp(-1, 0, self.TilingPositionAlpha))
end

--[[
    Setups the menu.
]]
function CoreBackgroundMenu:OnSetup()
    self.ScreenGUI.DisplayOrder = -100
end

--[[
    Called every heartbeat.
]]
function CoreBackgroundMenu:OnUpdate(deltaTime: number)
    self:HandleFancyEffects(deltaTime)
end

export type CoreBackgroundMenu = Menu.Menu & typeof(CoreBackgroundMenu) & {
    GRADIENT_ROTATION_SPEED: number,
    TILING_POSITION_SPEED: number,

    RootContainer: Frame,
    RootGradient: UIGradient,
    BackgroundTilingImage: ImageLabel,

    GradientRotationAlpha: number,
    TilingPositionAlpha: number
}

return CoreBackgroundMenu