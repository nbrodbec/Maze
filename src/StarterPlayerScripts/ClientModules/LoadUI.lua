local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadUI = {}
LoadUI.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
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

local isLoading = State(false)

---- Public Functions ----

function LoadUI.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local loadingUi = New "ScreenGui" {
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Name = "Loading",
        [Children] = {
            New "Frame" {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = Spring(Computed(function()
                    return if isLoading:get() then 0 else 1
                end), 20),
                [Children] = {
                    New "TextLabel" {
                        Text = "Loading...",
                        TextColor3 = Color3.new(1,1,1),
                        TextScaled = true,
                        Size = UDim2.fromScale(0.5, 0.2),
                        Position = UDim2.fromScale(0.5, 0.5),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        TextTransparency = Spring(Computed(function()
                            return if isLoading:get() then 0 else 1
                        end), 20),
                    }
                }
            }
        }
    }

    loadingUi.Parent = player:WaitForChild("PlayerGui")
end

function LoadUI.startLoading()
    isLoading:set(true)
end

function LoadUI.stopLoading()
    isLoading:set(false)
end

return LoadUI