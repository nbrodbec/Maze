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

local clickSound = Instance.new("Sound") do
    clickSound.SoundId = "rbxassetid://11323321319"
    clickSound.Parent = SoundService
end


local function FrameButton(props)
    local isHovering = State(false)
    local isClicking = State(false)
    local bgColor = props.Color or Colours.RED
    local h,s,v = bgColor:ToHSV()

    local button = New "Frame" {
        LayoutOrder = props.LayoutOrder or 0,
        Size = props.Size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = props.Position or UDim2.new(),
        BackgroundTransparency = 1,
        Visible = props.Visible or true,

        [Children] = {
            New "UIAspectRatioConstraint" {
                AspectType = Enum.AspectType.ScaleWithParentSize,
                DominantAxis = if props.Size.X.Scale ~= 0 then Enum.DominantAxis.Width else Enum.DominantAxis.Height
            },
            New "ImageLabel" {
                ZIndex = 0,
                Size = UDim2.fromScale(0, 0.9),
                Position = UDim2.fromScale(0.5, 0.1),
                AnchorPoint = Vector2.new(0.5, 0),
                Image = "http://www.roblox.com/asset/?id=10728367923",
                BackgroundTransparency = 1,
                [Children] = New "UIAspectRatioConstraint" {
                    AspectType = Enum.AspectType.ScaleWithParentSize,
                    DominantAxis = Enum.DominantAxis.Height
                },
            },
            New "ImageLabel" {
                ZIndex = 1,
                Size = UDim2.fromScale(0, 0.9),
                Position = UDim2.fromScale(0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                Image = "http://www.roblox.com/asset/?id=10728510195",
                BackgroundTransparency = 1,
                [Children] = {
                    New "UIAspectRatioConstraint" {
                        AspectType = Enum.AspectType.ScaleWithParentSize,
                        DominantAxis = Enum.DominantAxis.Height
                    },
                    New "ImageButton" {
                        BackgroundTransparency = 1,
                        Image = "",
                        Size = UDim2.fromScale(0.85, 0.85),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
        
                        [OnEvent "Activated"] = function()
                            if props.callback then
                                props.callback()
                            end
                        end,
                
                        [OnEvent "MouseEnter"] = function()
                            isHovering:set(true)
                        end,
                
                        [OnEvent "MouseLeave"] = function()
                            isHovering:set(false)
                            isClicking:set(false)
                        end,
                
                        [OnEvent "MouseButton1Down"] = function()
                            isClicking:set(true)
                            clickSound:Play()
                        end,
                
                        [OnEvent "MouseButton1Up"] = function()
                            isClicking:set(false)
                            clickSound:Play()
                        end,
        
                        [Children] = {
                            New "TextLabel" {
                                ZIndex = 2,
                                Size = UDim2.fromScale(0, 0.9),
                                AnchorPoint = Vector2.new(0.5, 0),
                                BackgroundColor3 = Computed(function()
                                    if isHovering:get() then
                                        return Color3.fromHSV(h, s, v+0.1)
                                    else
                                        return bgColor
                                    end
                                end),
                                Position = Spring(Computed(function()
                                    if isClicking:get() then
                                        return UDim2.fromScale(0.5, 0.1)
                                    else
                                        return UDim2.fromScale(0.5, 0)
                                    end
                                end), 35),
                                Text = props.Text,
                                TextScaled = true,
                                Font = Enum.Font.FredokaOne,
                                TextColor3 = Color3.new(1,1,1),
                                [Children] = {
                                    New "UICorner" {
                                        CornerRadius = UDim.new(1, 0)
                                    },
                                    New "UIPadding" {
                                        PaddingTop = UDim.new(0.15, 0),
                                        PaddingBottom = UDim.new(0.15, 0),
                                        PaddingLeft = UDim.new(0.15, 0),
                                        PaddingRight = UDim.new(0.15, 0),
                                    },
                                    New "UIAspectRatioConstraint" {
                                        AspectType = Enum.AspectType.ScaleWithParentSize,
                                        DominantAxis = Enum.DominantAxis.Height
                                    }
                                }
                            },
                            New "Frame" {
                                ZIndex = 1,
                                AnchorPoint = Vector2.new(0.5, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                Size = Spring(Computed(function()
                                    if isClicking:get() then
                                        return UDim2.new()
                                    else
                                        return UDim2.fromScale(0.9, 0.1)
                                    end
                                end), 35),
                                Position = UDim2.fromScale(0.5, 0.55),
                                BackgroundColor3 = Color3.fromHSV(h, s, v-0.1),
                            },
                            New "Frame" {
                                ZIndex = 0,
                                Size = UDim2.fromScale(0, 0.9),
                                AnchorPoint = Vector2.new(0.5, 0),
                                BackgroundColor3 = Color3.fromHSV(h, s, v-0.1),
                                Position = UDim2.fromScale(0.5, 0.1),
                                [Children] = {
                                    New "UICorner" {
                                        CornerRadius = UDim.new(1, 0)
                                    },
                                    New "UIAspectRatioConstraint" {
                                        AspectType = Enum.AspectType.ScaleWithParentSize,
                                        DominantAxis = Enum.DominantAxis.Height
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

    return button
end

return FrameButton