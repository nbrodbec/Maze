local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LevelService = {}
LevelService.dependencies = {
    modules = {"PlayerService", "AntiCheatService", "Maze"},
    utilities = {"RateLimiter"},
    dataStructures = {},
    constants = {}
}

local levelCompleted = Instance.new("BindableEvent")
local levelStarted = Instance.new("BindableEvent")
local levelFailed = Instance.new("BindableEvent")

LevelService.levelCompleted = levelCompleted.Event
LevelService.levelStarted = levelStarted.Event
LevelService.levelFailed = levelFailed.Event

local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local playerLevels = {}
local playerTimes = {}

---- Private Functions ----

local function teleportToLevelStart(player, level)
    local tpPoints = CollectionService:GetTagged(level)
    local tpPoint = tpPoints and tpPoints[1]
    if tpPoint then
        modules.AntiCheatService.authorizedTeleport(player, (tpPoint.CFrame * CFrame.new(-4, 4, 0)).Position)
    end
end

---- Public Functions ----

function LevelService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    modules.PlayerService.addPlayerRemovingCallback(function(player)
        if playerLevels[player] and playerTimes[player] then
            levelFailed:Fire(player, playerLevels[player])
        end
        playerLevels[player] = nil
        playerTimes[player] = nil
    end)

    local function newStartLine(part)
        part.Touched:Connect(function(p)
            local char = p:FindFirstAncestorWhichIsA("Model")
            if char then
                local player = Players:GetPlayerFromCharacter(char) 
                if player and playerLevels[player] and not playerTimes[player] then
                    playerTimes[player] = workspace:GetServerTimeNow()
                    levelStarted:Fire(player, playerLevels[player])
                end
            end
        end)
    end

    local function newFinishLine(part)
        part.Touched:Connect(function(p)
            local char = p:FindFirstAncestorWhichIsA("Model")
            if char then
                local player = Players:GetPlayerFromCharacter(char) 
                if player and playerTimes[player] then
                    local t = workspace:GetServerTimeNow() - playerTimes[player]
                    playerTimes[player] = nil
                    levelCompleted:Fire(player, playerLevels[player], t)
                end
            end
        end)
    end

    for _, p in workspace.TriggerParts:GetChildren() do
        if p.Name == "start" then
            newStartLine(p)
        elseif p.Name == "finish" then
            newFinishLine(p)
        end
    end
    workspace.TriggerParts.ChildAdded:Connect(function(child)
        if child.Name == "start" then
            newStartLine(child)
        elseif child.Name == "finish" then
            newFinishLine(child)
        end
    end)

    local limiter = utilities.RateLimiter.new(1)
    function remotes.StartLevel.OnServerInvoke(player, level)
        if limiter:check(player) then
            return LevelService.startLevel(player, level)
        end
    end

    local exitLimiter = utilities.RateLimiter.new(1)
    remotes.EndLevel.OnServerEvent:Connect(function(player)
        if exitLimiter:check(player) then
            LevelService.endLevel(player)
        end
    end)

    local tpLimiter = utilities.RateLimiter.new(1)
    remotes.ToLevel.OnServerEvent:Connect(function(player, level)
        if tpLimiter:check(player) then
            teleportToLevelStart(player, level)
        end
    end)

    local restartLimiter = utilities.RateLimiter.new(1)
    remotes.RestartLevel.OnServerEvent:Connect(function(player)
        if restartLimiter:check(player) then
            LevelService.restartLevel(player)
        end
    end)
end

function LevelService.startLevel(player, level)
    if playerLevels[player] == nil then
        playerLevels[player] = level
        modules.AntiCheatService.authorizedTeleport(player, workspace:FindFirstChild("start"..level, true).Position)
        return modules.Maze.getInfo(level)
    end
end

function LevelService.endLevel(player)
    local pastLevel = playerLevels[player]
    local pastTime = playerTimes[player]

    playerLevels[player] = nil
    playerTimes[player] = nil
    if pastLevel then
        teleportToLevelStart(player, pastLevel)
    else
        modules.AntiCheatService.authorizedTeleport(player, workspace:FindFirstChildOfClass("SpawnLocation").Position)
    end
    if pastLevel and pastTime then
        levelFailed:Fire(player, pastLevel)
    end
end

function LevelService.restartLevel(player)
    local level = playerLevels[player]
    if level then
        modules.AntiCheatService.authorizedTeleport(player, workspace:FindFirstChild("start"..level, true).Position)
    end
end

return LevelService