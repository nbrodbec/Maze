local Players = game:GetService("Players")
local PlayerService = {}
PlayerService.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local onPlayerAddedCallbacks = {}
local onPlayerRemovingCallbacks = {}
local onCharacterAddedCallbacks = {}

local characterAddedConnections = {}

---- Public Functions ----

function PlayerService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function onCharacterAdded(character)
        for _, f in ipairs(onCharacterAddedCallbacks) do
            task.spawn(f, character)
        end
    end

    local function onPlayerAdded(player)
        for _, f in ipairs(onPlayerAddedCallbacks) do
            task.spawn(f, player)
        end
        if player.Character then onCharacterAdded(player.Character) end
        characterAddedConnections[player] = player.CharacterAdded:Connect(onCharacterAdded)
    end

    local function onPlayerRemoving(player)
        for _, f in ipairs(onPlayerRemovingCallbacks) do
            task.spawn(f, player)
        end

        if characterAddedConnections[player] then
            characterAddedConnections[player]:Disconnect()
            characterAddedConnections[player] = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded(p)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function PlayerService.addPlayerAddedCallback(f)
    table.insert(onPlayerAddedCallbacks, f)
    for _, p in ipairs(Players:GetPlayers()) do
        f(p)
    end
end

function PlayerService.addPlayerRemovingCallback(f)
    table.insert(onPlayerRemovingCallbacks, f)
end

function PlayerService.addCharacterAddedCallback(f)
    table.insert(onCharacterAddedCallbacks, f)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then f(p.Character) end
    end
end

return PlayerService