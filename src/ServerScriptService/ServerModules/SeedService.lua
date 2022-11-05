local SeedService = {}
SeedService.dependencies = {
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

function SeedService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
end

function SeedService.getSeed()
    local now = DateTime.now()
    local timestampUTC = now.UnixTimestamp
    local timestampEST = timestampUTC - 3600*4
    local daysSinceEpochInEST = math.floor(timestampEST / 86400)

    return daysSinceEpochInEST
end

function SeedService.getTimeUntilNextSeed()
    local now = DateTime.now()
    local timestampUTC = now.UnixTimestamp
    local timestampEST = timestampUTC - 3600*4
    local daysSinceEpochInEST = math.floor(timestampEST / 86400)
    local nextSeed = daysSinceEpochInEST + 1
    
    return nextSeed * 86400 - timestampEST
end

return SeedService