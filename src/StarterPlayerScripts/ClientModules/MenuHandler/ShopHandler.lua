local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopHandler = {}
ShopHandler.dependencies = {
    modules = {"MenuHandler", "Components"},
    utilities = {},
    dataStructures = {},
    constants = {"Colours", "UIConstants"}
}
local modules
local utilities
local dataStructures
local constants

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

---- Public Functions ----

function ShopHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local state = modules.MenuHandler.getState()
    local shop = New "Frame" {
        Size = UDim2.fromScale(0, 0.7),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = Computed(function()
            return state:get() == "SHOP"
        end),

        [Children] = {
            New "UIAspectRatioConstraint" {
                DominantAxis = Enum.DominantAxis.Height,
                AspectRatio = 1.5,
                AspectType = Enum.AspectType.ScaleWithParentSize
            },
            New "UISizeConstraint" {
                MaxSize = Vector2.new(constants.UIConstants.MAX_FRAME_HEIGHT*1.5, constants.UIConstants.MAX_FRAME_HEIGHT)
            },

            New "Frame" {
                Size = UDim2.new(1, 0, 0.15, -8),
                BackgroundTransparency = 1,
                [Children] = {
                    modules.Components.new "IconButton" {
                        Image = "http://www.roblox.com/asset/?id=11470511930",
                        Size = UDim2.fromScale(0, 1),
                        Position = UDim2.fromScale(1, 0),
                        AnchorPoint = Vector2.new(1, 0),
                        Color = constants.Colours.RED,
                        Callback = function()
                            state:set(nil)
                        end
                    }
                }
            },

            modules.Components.new "TileFrame" {
                Type = "CHECKER",
                Filled = true,
                Size = UDim2.fromScale(1, 0.85),
                Position = UDim2.fromScale(0, 0.15),
                AnchorPoint = Vector2.new(),
                Children = {
                    
                },
                Content = {
        
                }
            }
        }
    }

    shop.Parent = modules.MenuHandler.getScreenGui()
end

return ShopHandler