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

local function TileFrame(props)
    return New "ImageLabel" {
        Visible = props.Visible or true,
        BackgroundColor3 = props.BackgroundColor3 or Colours.ORANGE,
        Size = props.Size or UDim2.fromScale(1, 1),
        Position = props.Position or UDim2.new(0.5, 0.5),
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        ZIndex = props.ZIndex or 0,
        Image = if props.Type == "CHECKER" then "http://www.roblox.com/asset/?id=11404033705" 
                elseif props.Type == "STRIPE" then "http://www.roblox.com/asset/?id=7723840621"
                else "",
        ResampleMode = Enum.ResamplerMode.Pixelated,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(32, 32),
        ImageTransparency = 0.8,

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0, 16)
            },
            New "UIPadding" {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            },
            if props.Filled then New "Frame" {
                BackgroundColor3 = props.FillColor or Color3.new(1,1,1),
                Size = UDim2.fromScale(1,1),
                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0, 8)
                    },
                    New "UIPadding" {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8)
                    },
                    props.Content
                }
            } else nil,
            props.Children,
            if not props.Filled then props.Content else nil
        }
    }
end

return TileFrame