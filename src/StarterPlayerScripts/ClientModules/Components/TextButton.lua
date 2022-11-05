local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local Colours = require(ReplicatedStorage.Constants.Colours)
local TiledBackground = require(script.Parent.TileFrame)

local downSound = Instance.new("Sound") do
    downSound.SoundId = "rbxassetid://6870468008"
    downSound.Volume = 1
    downSound.Parent = SoundService
end
local upSound = Instance.new("Sound") do
    upSound.SoundId = "rbxassetid://11461268953"
    upSound.Volume = 1
    upSound.Parent = SoundService
end


local function TextButton(props)
    local isHovering = State(false)
    local isClicking = State(false)
    
    local dominantAxis = if props.Size and props.Size.X.Scale ~= 0 then Enum.DominantAxis.Width else Enum.DominantAxis.Height
    local color = props.Color or Colours.ORANGE
    local h,s,v = color:ToHSV()

    return New "ImageButton" {
        Size = props.Size or UDim2.fromScale(1, 0),
        Position = props.Position or UDim2.new(),
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,

        [OnEvent "Activated"] = function()
            upSound:Play()
            if props.Callback then 
                props.Callback() 
            end
        end,

        [OnEvent "MouseButton1Down"] = function()
            isClicking:set(true)
            downSound:Play()
        end,

        [OnEvent "MouseButton1Up"] = function()
            isClicking:set(false)
        end,

        [OnEvent "MouseEnter"] = function()
            isHovering:set(true)
        end,

        [OnEvent "MouseLeave"] = function()
            isClicking:set(false)
            isHovering:set(false)
        end,

        [Children] = {
            New "UIAspectRatioConstraint" {
                AspectRatio = 3,
                AspectType = Enum.AspectType.ScaleWithParentSize,
                DominantAxis = dominantAxis
            },

            TiledBackground {
                Type = "STRIPE",
                BackgroundColor3 = Spring(Computed(function()
                    if isHovering:get() then
                        return Color3.fromHSV(h, s, v+0.05)
                    else
                        return color
                    end
                end), 25),
                Size = UDim2.fromScale(1, 0.9),
                Position = Spring(Computed(function()
                    if isClicking:get() then
                        return UDim2.fromScale(0.5, 0.6)
                    else
                        return UDim2.fromScale(0.5, 0.5)
                    end
                end), 35),

                Children = New "TextLabel" {
                    Text = props.Text,
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    TextScaled = true,
                    Font = Enum.Font.FredokaOne,
                    TextColor3 = props.TextColor3 or Color3.new(1,1,1),
                    [Children] = New "UIStroke" {
                        Thickness = 2,
                        Color = color
                    }
                },
            },

            

            TiledBackground {
                Type = "",
                BackgroundColor3 = Color3.fromHSV(h, s, v-0.15),
                Size = UDim2.fromScale(1, 0.9),
                Position = UDim2.fromScale(0.5, 0.6),
                ZIndex = -1
            },
        }
    }
end

return TextButton