local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LevelHandler = {}
LevelHandler.dependencies = {
    modules = {"MazeHandler", "RegionStateManager", "Components", "LoadUI", "DataHandler", "RewardHandler"},
    utilities = {},
    dataStructures = {},
    constants = {"Colours"}
}

local levelEntered = Instance.new("BindableEvent")
local levelExited = Instance.new("BindableEvent")
LevelHandler.levelEntered = levelEntered.Event
LevelHandler.levelExited = levelExited.Event

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

local levelNames = {
    lvl_1 = "1",
    lvl_2 = "2",
    lvl_3 = "3",
    lvl_4 = "4",
    lvl_5 = "5",
    lvl_6 = "6",
    lvl_7 = "7",
    lvl_8 = "8",
    lvl_9 = "9"
}

local currentMaze
local previewingLevel = State()
local selectedLevel = State()
local timer = State()
local startTime

local connections = {}

---- Public Functions ----

function LevelHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    modules.RegionStateManager.getRegionEntered("level_start"):Connect(function(part)
        local level = part:GetAttribute("level") or 0
        previewingLevel:set(level)
    end)

    modules.RegionStateManager.getRegionExited("level_start"):Connect(function()
        previewingLevel:set(nil)
    end)

    modules.RegionStateManager.getRegionEntered("level_exit"):Connect(function(part)
        previewingLevel:set("")
    end)

    modules.RegionStateManager.getRegionExited("level_exit"):Connect(function()
        previewingLevel:set(nil)
    end)

    local levelUI = New "ScreenGui" {
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        [Children] = {
            -- Start level button
            modules.Components.new "FrameButton" {
                Text = Computed(function()
                    local level = previewingLevel:get()
                    if level then
                        if level ~= "" then
                            return string.format("GO LEVEL %s", levelNames[level])
                        else
                            return "RETURN TO LOBBY"
                        end
                    else
                        return "GO LEVEL 0"
                    end
                end),
                Size = UDim2.fromScale(0, 0.3),
                Position = Spring(Computed(function()
                    return if previewingLevel:get() ~= nil then
                        UDim2.fromScale(0.5, 0.8)
                    else
                        UDim2.fromScale(0.5, 1.15)
                end), 30),
                callback = function()
                    local lvl = previewingLevel:get()
                    if lvl then
                        if lvl ~= "" then
                            LevelHandler.startLevel(lvl)
                        else
                            LevelHandler.endLevel()
                        end
                    end
                end
            },

            -- Level options
            New "Frame" {
                Size = UDim2.fromScale(1, 0.15),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),
                BackgroundTransparency = 1,
                [Children] = {

                }
            },

            -- Level topbar
            New "Frame" {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                [Children] = {
                    New "TextLabel" {
                        Size = UDim2.fromScale(1, 1),
                        TextSize = 32,
                        Font = Enum.Font.Arcade,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        TextColor3 = Color3.new(1,1,1),
                        Text = Computed(function()
                            local t = timer:get()
                            if t == nil then
                                return ""
                            else
                                local m = math.floor(t/60)
                                local s = math.floor(t%60)
                                local ms = (t % 60) % 1 * 100
                                return string.format("%.2d:%.2d:%.2d", m, s, ms)
                            end
                        end),
                        [Children] = {
                            New "UIStroke" {
                                Thickness = 2,
                                Color = Color3.new()
                            }
                        }
                    },
                    New "Frame" {
                        Size = UDim2.fromScale(1, 0.5),
                        Position = UDim2.fromScale(0, 1),
                        BackgroundTransparency = 1,

                        [Children] = {
                            New "UIListLayout" {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                Padding = UDim.new(0, 14)
                            },
                            New "TextLabel" {
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 0.5),
                                TextSize = 16,
                                Font = Enum.Font.Arcade,
                                BackgroundTransparency = 1,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                TextYAlignment = Enum.TextYAlignment.Center,
                                TextColor3 = Color3.new(1,1,0),
                                Text = Computed(function()
                                    local level = selectedLevel:get() or previewingLevel:get()
                                    if not level then return "" end

                                    local records = modules.DataHandler.getState("records"):get()
                                    local best = records[level]
                                    if best == nil then
                                        return ""
                                    else
                                        local m = math.floor(best/60)
                                        local s = math.floor(best%60)
                                        local ms = (best % 60) % 1 * 100
                                        return string.format("Best Time: %.2d:%.2d:%.2d", m, s, ms)
                                    end
                                end),
                                [Children] = {
                                    New "UIStroke" {
                                        Thickness = 1.5,
                                        Color = Color3.new()
                                    }
                                }
                            },
                            New "TextLabel" {
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 0.5),
                                FontSize = Enum.FontSize.Size14,
                                Font = Enum.Font.Arcade,
                                BackgroundTransparency = 1,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                TextYAlignment = Enum.TextYAlignment.Center,
                                TextColor3 = Color3.fromRGB(255, 0, 200),
                                Text = Computed(function()
                                    local level = selectedLevel:get() or previewingLevel:get()
                                    if not level then return "" end

                                    local todayTimes = modules.DataHandler.getState("times_today"):get()
                                    local best = todayTimes.times[level]
                                    if best == nil then
                                        return ""
                                    else
                                        local m = math.floor(best/60)
                                        local s = math.floor(best%60)
                                        local ms = (best % 60) % 1 * 100
                                        return string.format("Today's Time: %.2d:%.2d:%.2d", m, s, ms)
                                    end
                                end),
                                [Children] = {
                                    New "UIStroke" {
                                        Thickness = 1.5,
                                        Color = Color3.new()
                                    }
                                }
                            },
                        }
                    }
                },
            },

            -- Controls
            New "Frame" {
                Size = UDim2.fromScale(1, 0.2),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = Spring(Computed(function()
                    return if selectedLevel:get() ~= nil and previewingLevel:get() == nil then
                        UDim2.fromScale(0.5, 0.95)
                    else
                        UDim2.fromScale(0.5, 1.2)
                end), 30),
                [Children] = {
                    New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0.01, 0)
                    },
                    modules.Components.new "FrameButton" {
                        LayoutOrder = -1,
                        Text = "Restart",
                        Size = UDim2.fromScale(0, 0.75),
                        Color = constants.Colours.BLUE,
                        callback = function()
                            LevelHandler.restartLevel()
                        end
                    },
                    modules.Components.new "FrameButton" {
                        LayoutOrder = 0,
                        Text = "Hint",
                        Size = UDim2.fromScale(0, 1),
                        Color = constants.Colours.ORANGE,
                        callback = function()
                            pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, 1333472379)
                        end
                    },
                    modules.Components.new "FrameButton" {
                        LayoutOrder = 1,
                        Text = "Quit",
                        Size = UDim2.fromScale(0, 0.75),
                        Color = constants.Colours.RED,
                        callback = function()
                            LevelHandler.endLevel()
                        end
                    },
                },
                
            }
        }
    }
    levelUI.Parent = player:WaitForChild("PlayerGui")

    local t = 0
    RunService.Heartbeat:Connect(function(dt)
        t += dt
        if t >= 0.05 then
            if startTime then
                timer:set(workspace:GetServerTimeNow() - startTime)
            end
            t = 0
        end
    end)

    remotes.SellHint.OnClientEvent:Connect(LevelHandler.displayHint)
end

function LevelHandler.startLevel(level)
    modules.LoadUI.startLoading()
    local mazeInfo = remotes.StartLevel:InvokeServer(level)
    if mazeInfo then
        previewingLevel:set(nil)
        selectedLevel:set(level)
        if currentMaze then currentMaze:destroy() end
        currentMaze = modules.MazeHandler.new(mazeInfo)

        local connection; connection = mazeInfo.startPart.Touched:Connect(function()
            if connection.Connected then
                connection:Disconnect()
                startTime = workspace:GetServerTimeNow()
                timer:set(0)
            end
        end)
        local connection2; connection2 = mazeInfo.finishPart.Touched:Connect(function()
            if connection2.Connected then
                print("Finished")
                connection2:Disconnect()
                startTime = nil
            end
        end)
        table.insert(connections, connection)
    end
    modules.LoadUI.stopLoading()
    levelEntered:Fire()
end

function LevelHandler.endLevel()
    if currentMaze then
        remotes.EndLevel:FireServer()
        currentMaze:destroy()
        currentMaze = nil
        startTime = nil
        timer:set(nil)
        selectedLevel:set(nil)
        for i, c in connections do 
            c:Disconnect() 
            connections[i] = nil
        end
        levelExited:Fire()
    end
end

function LevelHandler.restartLevel()
    local currentLevel = selectedLevel:get()
    if currentLevel and currentMaze then
        remotes.RestartLevel:FireServer()
    end
end


function LevelHandler.displayHint(duration)
    if currentMaze then
        local walkableNodes = currentMaze:calculatePath()
        local markers = Instance.new("Folder")
        for _, node in walkableNodes do
            local marker = Instance.new("Part")
            marker.Anchored = true
            marker.Material = Enum.Material.SmoothPlastic
            marker.Color = Color3.new(1, 1, 0)
            marker.Size = Vector3.new(1, 1, 1)
            marker.CanCollide = false
            marker.Transparency = 0.5
            marker.CFrame = currentMaze.origin * CFrame.new(
                currentMaze.cellSize/2 + (node.X-1)*currentMaze.cellSize,
                2,
                -currentMaze.cellSize/2 - (node.Y-1)*currentMaze.cellSize
            )
            CollectionService:AddTag(marker, "path_marker")
            marker.Parent = markers
        end
        markers.Parent = workspace
        task.delay(duration or 7, markers.Destroy, markers)
    end
end

return LevelHandler