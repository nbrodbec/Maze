local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MenuHandler = {}
MenuHandler.dependencies = {
    modules = {"Components"},
    utilities = {},
    dataStructures = {},
    constants = {"Colours"}
}
local modules
local utilities
local dataStructures
local constants
local player = Players.LocalPlayer

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local openMenu = State()
local screenGui = New "ScreenGui" {
    Name = "Menus",
    IgnoreGuiInset = true,
    ResetOnSpawn = false
}

---- Public Functions ----

function MenuHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local sideBar = New "Frame" {
        Size = UDim2.fromScale(0.1, 1),
        BackgroundTransparency = 1,
        [Children] = {
            New "UIListLayout" {
                Padding = UDim.new(0, 8),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            },
            New "UIPadding" {
                PaddingLeft = UDim.new(0, 8)
            },
            modules.Components.new "TileFrame" {
                Filled = false,
                Type = "CHECKER",
                Size = UDim2.fromScale(1, 0),
                Children = {
                    New "UIAspectRatioConstraint" {
                        AspectRatio = 3,
                        DominantAxis = Enum.DominantAxis.Width,
                        AspectType = Enum.AspectType.ScaleWithParentSize
                    },
                    New "Frame" {
                        Size = UDim2.new(1, 6, 1, 6),
                        Position = UDim2.fromScale(0.5, 0.5),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        [Children] = {
                            New "UICorner" {
                                CornerRadius = UDim.new(0, 8)
                            }
                        }
                    }
                }
            },
            modules.Components.new "TextButton" {
                Text = "SHOP",
                Color = constants.Colours.GREEN,
                Size = UDim2.fromScale(1, 0),
                Callback = function()
                    if openMenu:get() == "SHOP" then
                        openMenu:set(nil)
                    else
                        openMenu:set("SHOP")
                    end
                end
            }
        }
    }

    sideBar.Parent = screenGui
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

function MenuHandler.getState()
    return openMenu
end

function MenuHandler.getScreenGui()
    return screenGui
end

return MenuHandler