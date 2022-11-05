local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientData = {}
ClientData.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local data = {}
local events = {}

local Fusion = require(ReplicatedStorage.Fusion)
local State = Fusion.State

---- Public Functions ----

function ClientData.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local rawData = remotes.InitData:InvokeServer()
    for k, v in rawData do
        data[k] = State(v)
    end

    remotes.SyncData.OnClientEvent:Connect(ClientData.set)
end

function ClientData.getState(...)
    local keys = {...}
    local toReturn = {}
    for _, key in ipairs(keys) do
        if data[key] then table.insert(toReturn, data[key]) end
    end
    return unpack(toReturn)
end

function ClientData.get(...)
    local states = { ClientData.getState(...) }
    local values = {}
    for _, state in states do
        table.insert(values, state:get())
    end
    return unpack(values)
end

function ClientData.set(key, value)
    data[key]:set(value)
    if events[key] then events[key]:Fire(value) end 
end

function ClientData.getChanged(keyName)
    local event = events[keyName] or Instance.new("BindableEvent")
    events[keyName] = event
    return event.Event
end

return ClientData