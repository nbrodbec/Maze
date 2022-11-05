local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WelcomeHandler = {}
WelcomeHandler.dependencies = {
    modules = {"DataHandler", "Components"},
    utilities = {},
    dataStructures = {},
    constants = {"Colours", "UIConstants"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local player = Players.LocalPlayer

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local currentlyViewing = State()
local welcomeScreens = {}
local welcomeFrame

---- Public Functions ----

function WelcomeHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    welcomeFrame = modules.Components.new "TileFrame" {
        Type = "CHECKER",
        Filled = true,
        Size = UDim2.fromScale(0, 0.7),
        Visible = Computed(function()
            return currentlyViewing:get() ~= nil
        end),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),

        Children = {
            New "UIAspectRatioConstraint" {
                DominantAxis = Enum.DominantAxis.Height,
                AspectRatio = 0.75,
                AspectType = Enum.AspectType.ScaleWithParentSize
            },
            New "UISizeConstraint" {
                MaxSize = Vector2.new(constants.UIConstants.MAX_FRAME_HEIGHT*0.75, constants.UIConstants.MAX_FRAME_HEIGHT)
            }
        },
        Content = currentlyViewing
    }

    local welcomeGui = New "ScreenGui" {
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Name = "Welcome",
        [Children] = welcomeFrame
    }
    welcomeGui.Parent = player:WaitForChild("PlayerGui")
    
    welcomeScreens.FTU = New "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        [Children] = {
            New "ImageLabel" {
                Size = UDim2.fromScale(1, 0.2),
                Image = "http://www.roblox.com/asset/?id=11405892781",
                ScaleType = Enum.ScaleType.Fit,
                BackgroundTransparency = 1,
            },
            New "TextLabel" {
                Text = "Welcome!",
                Font = Enum.Font.FredokaOne,
                TextScaled = true,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.1),
                Position = UDim2.fromScale(0, 0.25),
                TextColor3 = constants.Colours.RED_ORANGE,
            },

            New "TextLabel" {
                Text = "▶ Solve mazes to earn coins!\n▶ Spend coins on cool shop items!\n▶ New mazes every day!\n\nClick 'Play' to solve your first maze!",
                TextWrapped = true,
                Font = Enum.Font.FredokaOne,
                TextScaled = true,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.4),
                Position = UDim2.fromScale(0, 0.4),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextColor3 = constants.Colours.BLUE,
                [Children] = New "UITextSizeConstraint" {
                    MaxTextSize = 18
                }
            },

            modules.Components.new "TextButton" {
                Size = UDim2.fromScale(0, 0.15),
                Position = UDim2.fromScale(0.5, 1),
                AnchorPoint = Vector2.new(0.5, 1),
                Text = "Play!",
                Color = constants.Colours.GREEN,
                Callback = function()
                    currentlyViewing:set(nil)
                    remotes.ToLevel:FireServer("lvl_1")
                end
            }
        }
    }

    -- Non-Paying User
    welcomeScreens.NPU = {}

    -- Paying User
    welcomeScreens.PU = {}

    -- Repeat Purchase User
    welcomeScreens.RPU = {}

    local version, isRepeatPurchaseUser, isFirstPurchaseUser = modules.DataHandler.get(
        "version", 
        "is_repeat_purchase_user", 
        "is_first_purchase_user"
    )
    if version >= 1 then
        WelcomeHandler.displayWelcome("FTU")
    elseif isRepeatPurchaseUser then
        WelcomeHandler.displayWelcome("RPU")
    elseif isFirstPurchaseUser then
        WelcomeHandler.displayWelcome("PU")
    else
        WelcomeHandler.displayWelcome("NPU")
    end
end

function WelcomeHandler.displayWelcome(type)
    local screen = welcomeScreens[type]
    if screen then
        currentlyViewing:set(screen)
    end
end

return WelcomeHandler