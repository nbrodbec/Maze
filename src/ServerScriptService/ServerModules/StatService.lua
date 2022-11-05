local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StatService = {}
StatService.dependencies = {
    modules = {"DataService", "LevelService", "SeedService", "PlayerService"},
    utilities = {},
    dataStructures = {},
    constants = {}
}

local nthLevelCompleted = Instance.new("BindableEvent")
local nthLevelCompletedToday = Instance.new("BindableEvent")
local levelCompletedFirstTime = Instance.new("BindableEvent")
local levelCompletedFirstTimeToday = Instance.new("BindableEvent")
local exhibitionRunCompleted = Instance.new("BindableEvent")
local recordAchieved = Instance.new("BindableEvent")

StatService.nthLevelCompleted = nthLevelCompleted.Event
StatService.nthLevelCompletedToday = nthLevelCompletedToday.Event
StatService.levelCompletedFirstTime = levelCompletedFirstTime.Event
StatService.levelCompletedFirstTimeToday = levelCompletedFirstTimeToday.Event
StatService.exhibitionRunCompleted = exhibitionRunCompleted.Event
StatService.recordAchieved = recordAchieved.Event

local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local REFRESH_INTERVAL = 10 

local records = {}

local levels = {}

---- Public Functions ----

function StatService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    modules.PlayerService.addPlayerAddedCallback(function(player)
        local timesToday = modules.DataService.get(player, "times_today")
        local seed = modules.SeedService.getSeed()
        if timesToday.timestamp ~= seed then
            modules.DataService.set(player, "times_today", {
                timestamp = seed,
                times = {}
            })
        end
    end)

    modules.LevelService.levelCompleted:Connect(function(player, level, t)
        StatService.addStat(player, level, t)
    end)

    for _, p in CollectionService:GetTagged("maze_origin") do
        local level = p:GetAttribute("id")
        table.insert(levels, level)
    end

    local t = REFRESH_INTERVAL
    local curr = 0
    RunService.Heartbeat:Connect(function(dt)
        t += dt
        if t >= REFRESH_INTERVAL then
            t %= REFRESH_INTERVAL
            curr += 1
            local seed = modules.SeedService.getSeed()
            local store = DataStoreService:GetOrderedDataStore(levels[curr], tostring(seed))
            local success, pages = pcall(store.GetSortedAsync, store, true, 10)
            if success then
                local success2, page = pcall(pages.GetCurrentPage, pages)
                if success2 then
                    records[levels[curr]] = records[levels[curr]] or {}
                    local list = records[levels[curr]]
                    for i, obj in ipairs(page) do
                        list[i] = {
                            userid = obj.key,
                            time = obj.value / 100
                        }
                    end
                    records[levels[curr]] = list
                    remotes.SyncLeaderboard:FireAllClients(levels[curr], list)
                end
            end
            curr %= #levels
        end
    end)

    function remotes.GetLeaderboard.OnServerInvoke(player)
        return levels
    end
end

function StatService.addStat(player, level, t)
    local key = modules.SeedService.getSeed()
    local playerRecords, playerTimes = modules.DataService.get(player, "records", "times_today")
    if playerTimes.timestamp ~= key then
        playerTimes = {
            timestamp = key,
            times = {}
        }
    end
    if playerTimes.times[level] == nil then
        -- This is their first completion of this level today
        local n = modules.DataService.get(player, "mazes_completed")
        local isFirstTime = false
        local isFirstTimeToday = true
        local didAchieveRecord = false

        playerTimes.times[level] = t
        modules.DataService.set(player, "times_today", playerTimes)
        modules.DataService.set(player, "mazes_completed", n + 1)

        if not playerRecords[level] or (playerRecords[level] and t < playerRecords[level]) then
            if not playerRecords[level] then
                isFirstTime = true
            else
                didAchieveRecord = true
            end
            playerRecords[level] = t
            modules.DataService.set(player, "records", playerRecords)
        end

        local seed = modules.SeedService.getSeed()
        local store = DataStoreService:GetOrderedDataStore(level, tostring(seed))
        local tries = 0
        local success, msg = false, nil
        while tries <= 3 and not success do
            success, msg = pcall(store.UpdateAsync, store, player.UserId, function(old)
                if old == nil then
                    return math.floor(t * 100)
                end
            end)
            tries += 1
        end
        if not success then 
            warn(
                string.format(
                    "Global leaderboard not updated for player: %d level: %s reason: %s", 
                    player.UserId, 
                    level,
                    msg
                )
            )
        end
        -- Fire Events
        local m = 0 for _ in modules.DataService.get(player, "times_today").times do
            m += 1
        end

        if didAchieveRecord then
            recordAchieved:Fire(player, level)
        end
        if isFirstTime then
            levelCompletedFirstTime:Fire(player, level)
        end
        if isFirstTimeToday then
            levelCompletedFirstTimeToday:Fire(player, level)
        end
        nthLevelCompleted:Fire(player, n+1)
        nthLevelCompletedToday:Fire(player, m)
    else
        exhibitionRunCompleted:Fire(player, level)
    end
end

function StatService.getTopTimes(level)
    return records[level] or {}
end

return StatService