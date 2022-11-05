local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeaderboardHandler = {}
LeaderboardHandler.dependencies = {
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
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local ForPairs = Fusion.ForPairs
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local levels = {}

---- Public Functions ----

function LeaderboardHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    for _, p in CollectionService:GetTagged("leaderboard") do 
        LeaderboardHandler.newLeaderboard(p)
    end
    CollectionService:GetInstanceAddedSignal("leaderboard"):Connect(LeaderboardHandler.newLeaderboard)

    local stats = remotes.GetLeaderboard:InvokeServer()
    for k, v in pairs(stats) do
        if levels[k] then
            levels[k]:set(v)
        end
    end

    remotes.SyncLeaderboard.OnClientEvent:Connect(function(level, data)
        if levels[level] then
            levels[level]:set(data)
        end
    end)
end

function LeaderboardHandler.newLeaderboard(part)
    local level = part:GetAttribute("level")
    levels[level] = State({})

    local gui = New "SurfaceGui" {
        Adornee = part,
        LightInfluence = 0,
        Face = Enum.NormalId.Right,
        ResetOnSpawn = false,
        Parent = player:WaitForChild("PlayerGui"),
        [Children] = {
            New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.fromScale(1, 0.25),
                Position = UDim2.fromOffset(0, 1),
                Text = "Top 10 Today",
                TextColor3 = Color3.new(1,1,1),
                Font = Enum.Font.FredokaOne,
                TextScaled = true,
                BackgroundTransparency = 1,
                [Children] = {
                    New "UIStroke" {
                        Thickness = 4,
                        Color = constants.Colours.BLUE
                    },
                    New "UIGradient" {
                        Color = ColorSequence.new(Color3.new(1,1,0), constants.Colours.ORANGE),
                        Rotation = 90
                    }
                }
            },
            modules.Components.new "TileFrame" {
                Filled = false,
                Position = UDim2.fromScale(0.5, 0.5),
                Type = "CHECKER",
                Size = UDim2.fromScale(1, 1),
                Content = {
                    New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 8)
                    },
                    ForPairs(levels[level], function(i, val)
                        return i, New "Frame" {
                            Size = UDim2.new(1, 0, 0.1, -7.2),
                            BackgroundColor3 = Color3.new(1, 1, 1),

                            [Children] = {
                                New "UICorner" {
                                    CornerRadius = UDim.new(0, 8)
                                },
                                New "TextLabel" {
                                    Text = string.format("%d.", i),
                                    Font = Enum.Font.FredokaOne,
                                    TextColor3 = constants.Colours.BLUE,
                                    FontSize = Enum.FontSize.Size24,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Size = UDim2.new(0.1, -8, 1, 0),
                                    Position = UDim2.fromOffset(8, 0)
                                },
                                New "ImageLabel" {
                                    Size = UDim2.fromScale(0.1, 1),
                                    Position = UDim2.fromScale(0.1, 0),
                                    BackgroundTransparency = 1,
                                    ScaleType = Enum.ScaleType.Fit,
                                    Image = (function()
                                        local success, img = pcall(
                                            Players.GetUserThumbnailAsync, 
                                            Players, 
                                            val.userid, 
                                            Enum.ThumbnailType.HeadShot, 
                                            Enum.ThumbnailSize.Size48x48
                                        )
                                        return if success then img else ""
                                    end)(),
                                },
                                New "TextLabel" {
                                    Text = (function()
                                        local success, name = pcall(
                                            Players.GetNameFromUserIdAsync,
                                            Players,
                                            val.userid
                                        )
                                        return if success then name else ""
                                    end)(),
                                    Font = Enum.Font.FredokaOne,
                                    TextColor3 = constants.Colours.BLUE,
                                    FontSize = Enum.FontSize.Size18,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Size = UDim2.new(0.55, -8, 1, 0),
                                    Position = UDim2.new(0.2, 8, 0, 0)
                                },
                                New "TextLabel" {
                                    Text = string.format(
                                        "%.2d:%.2d:%.2d",
                                        math.floor(val.time/60),
                                        val.time%60,
                                        (val.time%1)*100
                                    ),
                                    Font = Enum.Font.FredokaOne,
                                    TextColor3 = constants.Colours.BLUE,
                                    TextSize = 20,
                                    TextXAlignment = Enum.TextXAlignment.Right,
                                    Size = UDim2.new(0.25, -8, 1, 0),
                                    Position = UDim2.fromScale(0.75, 0)
                                }
                            }
                        }
                    end)
            }
            }
        }
    }
end

return LeaderboardHandler