local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsHandler = {}
AnalyticsHandler.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

---- Public Functions ----

function AnalyticsHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local GameAnalytics = require(ReplicatedStorage.Packages.GameAnalytics)
    GameAnalytics.initClient()
end

return AnalyticsHandler