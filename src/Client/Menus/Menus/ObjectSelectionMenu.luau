--------------------------------------------------------
-- [Ragdollworks] Object Selection Menu
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

local Objects = require(Rage.Path.Objects)
local UI = require(Rage.Path.UI)
local Menus = require(Rage.Path.Menus)

local ObjectTypes = require(Rage.Path.Classes.Objects.Types)
local Menu = require(Rage.Path.Classes.Menu)

local signal = require(Rage.WallyPackages.signal)

-------------------------------
-- // Main
-------------------------------

--[[
    The menu shown for selecting an object to spawn.
]]
ObjectSelectionMenu = {} :: ObjectSelectionMenu
ObjectSelectionMenu.__index = ObjectSelectionMenu
setmetatable(ObjectSelectionMenu, Menu)

--[[
    Creates a new ObjectSelectionMenu class instance.
]]
function ObjectSelectionMenu.New(): ObjectSelectionMenu
    local self = setmetatable(Menu.New(
        "ObjectSelectionMenu",
        {"ObjectSelection"},
        {CanBeForceHidden = true}
    ), ObjectSelectionMenu) :: ObjectSelectionMenu

    self.RootContainer = self.ScreenGUI.Root.Objects
    self.CategoriesContainer = self.RootContainer.Categories
    self.ObjectsContainer = self.RootContainer.Objects

    self.CategoryComponent = UI:GetComponent("ObjectCategory")
    self.ObjectComponent = UI:GetComponent("Object")

    self.ActiveCategory = ""

    return self
end

--[[
    Adds an object to the menu.
]]
function ObjectSelectionMenu:AddObject(object: ObjectTypes.Object)
    local objectButton = self.ObjectComponent:Clone() :: ImageButton
    local objectNameText = objectButton.NameContainer.ObjectName :: TextLabel

    objectButton.Image = object:GetIcon()
    objectNameText.Text = object.Name

    objectButton.MouseButton1Click:Connect(function()
        Objects:SelectObject(object)
        self:HideScene()
    end)

    objectButton.Parent = self.ObjectsContainer
end

--[[
    Removes all object UI.
]]
function ObjectSelectionMenu:ClearObjects()
    for _, objectContainer: GuiObject in pairs(self.ObjectsContainer:GetChildren()) do
        if not objectContainer:IsA(self.ObjectComponent.ClassName) then
            continue
        end

        objectContainer:Destroy()
    end
end

--[[
    Adds all objects to the menu.
]]
function ObjectSelectionMenu:RefreshObjects()
    self:ClearObjects()

    for _, object in pairs(Objects.ExistingObjects) do
        if object.Category == self.ActiveCategory then
            self:AddObject(object)
        end
    end
end

--[[
    Sets the active category.
]]
function ObjectSelectionMenu:SetActiveCategory(category: string)
    self.ActiveCategory = category
    self:RefreshObjects()
end

--[[
    Adds a category to the menu.
]]
function ObjectSelectionMenu:AddCategory(category: string)
    local categoryButton = self.CategoryComponent:Clone() :: TextButton
    categoryButton.Text = category

    categoryButton.MouseButton1Click:Connect(function()
        self:SetActiveCategory(category)
    end)

    self:SetActiveCategory(category)
    categoryButton.Parent = self.CategoriesContainer
end

--[[
    Hides the scene responsible for this menu.
]]
function ObjectSelectionMenu:HideScene()
    Menus:RemoveScene("ObjectSelection")
end

--[[
    Setups the menu.
]]
function ObjectSelectionMenu:OnSetup()
    for category, _ in pairs(Objects.ExistingObjectsByCategory) do
        self:AddCategory(category)
    end

    self.OnCategoryRegister = Objects.OnObjectCategoryRegister:Connect(function(category: string)
        self:AddCategory(category)
    end)
end

export type ObjectSelectionMenu = Menu.Menu & typeof(ObjectSelectionMenu) & {
    RootContainer: Frame,
    CategoriesContainer: Frame,
    ObjectsContainer: Frame,

    CategoryComponent: Frame,
    ObjectComponent: Frame,

    ActiveCategory: string,

    OnCategoryRegister: signal.Connection
}

return ObjectSelectionMenu