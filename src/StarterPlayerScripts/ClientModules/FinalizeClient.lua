local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local FinalizeClient = {}
FinalizeClient.dependencies = {
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

local function disableReset()
    local success = false
    while not success do
        success = pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", false)
        wait()
    end
end

---- Public Functions ----

function FinalizeClient.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    print("Finalizing")

    print("Finalized")
end

return FinalizeClient