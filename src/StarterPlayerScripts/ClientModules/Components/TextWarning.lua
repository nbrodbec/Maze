local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local Colours = require(ReplicatedStorage.Constants.Colours)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local warningGui = New "ScreenGui" {
    Name = "WarningContainer",
    IgnoreGuiInset = true
}
warningGui.Parent = playerGui

local function TextWarning(props)
    if #warningGui:GetChildren() >= 10 then return end

    local isVisible = State(true)
    local text = New "TextLabel" {
        Text = props.Text,
        TextColor3 = props.TextColor3 or Colours.RED,
        Font = Enum.Font.FredokaOne,
        Size = UDim2.fromScale(1, 0.05),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 1),
        TextScaled = false,
        TextSize = warningGui.AbsoluteSize.Y * 0.05,

        Position = Spring(Computed(function()
            return if isVisible:get() then UDim2.fromScale(0.5, 0.6) else UDim2.fromScale(0.5, 0.55)
        end), 20),
        TextTransparency = Spring(Computed(function()
            return if isVisible:get() then 0 else 1
        end), 20)
    }

    text.Parent = warningGui
    task.delay(props.delayTime or 1, function()
        isVisible:set(false)
        task.wait((props.delayTime or 1) + 1)
        text:Destroy()
    end)
end

return TextWarning