local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Data = {}
Data.dependencies = {
    modules = {"PlayerService"},
    utilities = {"Reconcile", "Timer"},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local dataStore = DataStoreService:GetDataStore("Data")
local template = {
    soft_currency = 0,
    hard_currency = 0,
    mazes_completed = 0,
    records = {},
    times_today = {
        timestamp = 0,
        times = {}
    },

    is_first_purchase_user = false,
    is_repeat_purchase_user = false,
    version = 1
}

local clientSafeKeys = {
}

local sessions = {}
local timers = {}
local dataLoaded = Instance.new("BindableEvent")

---- Private Functions ----

local function getData(key)
    local success = false
    local data
    local tries = 0
    while not success and tries <= 3 do
        success, data = pcall(dataStore.GetAsync, dataStore, key)
        tries += 1
    end
    if not success then 
        print(data) 
        data = utilities.Reconcile.reconcile({}, template)
        data.corrupted = true
    end
    return data
end

---- Public Functions ----
local debounce = {}
function Data.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    
    modules.PlayerService.addPlayerAddedCallback(function(player)
        debounce[player] = Instance.new("BindableEvent")
        
        local data = getData(player.UserId) or {}
        utilities.Reconcile(data, template)
        sessions[player] = data
        do
            debounce[player]:Fire()
            debounce[player]:Destroy()
            debounce[player] = nil  
            dataLoaded:Fire(player)
        end 
    end)


    modules.PlayerService.addPlayerRemovingCallback(function(player)
        if debounce[player] then
            debounce[player].Event:Wait()
        end
        Data.save(player)
        sessions[player] = nil
    end)

    local closeEvent = Instance.new("BindableEvent")
    game:BindToClose(function()
        for player, session in pairs(sessions) do
            task.spawn(function()
                Data.save(player)
                sessions[player] = nil
                if not next(sessions) then
                    closeEvent:Fire()
                end
            end)
        end
        if next(sessions) then
            closeEvent.Event:Wait()
        end
    end)

    remotes.InitData.OnServerInvoke = Data.get
    remotes.SetData.OnServerEvent:Connect(Data.clientSet)
end

function Data.save(player)
    if timers[player] then
        timers[player]:yield()
    end
    local new = sessions[player]
    if not new then return end

    local success, msg = pcall(dataStore.UpdateAsync, dataStore, player.UserId, function(old)
        if new.corrupted then return end
        if old and old.version ~= new.version then return end
        new.version += 1
        return new
    end)
    if success then
        timers[player] = utilities.Timer.new(6)
        timers[player]:start()
    end
end

function Data.get(player, key, ...)
    if #{ ... } ~= 0 then key = {key, ...} end
    if not sessions[player] then
        local p 
        while p ~= player do
            p = dataLoaded.Event:Wait()
        end
    end
    local data = sessions[player]
    if data then
        if key then
            if typeof(key) == "table" then
                local toReturn = {}
                for _, k in ipairs(key) do
                    table.insert(toReturn, data[k])
                end
                return unpack(toReturn)
            else
                return data[key]
            end
        else
            return data
        end
    end
end

function Data.set(player, key, value)
    local data = sessions[player]
    if data then
        data[key] = value
        remotes.SyncData:FireClient(player, key, value)
    end
end

function Data.clientSet(player, key, value)
    local data = sessions[player]
    if data and key and clientSafeKeys[key] then
        data[key] = value
        utilities.Reconcile.reconcile(data, template)
        remotes.SyncData:FireClient(player, key, value)
    end
end

return Data