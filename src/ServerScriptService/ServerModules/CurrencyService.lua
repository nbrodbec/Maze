local CurrencyService = {}
CurrencyService.dependencies = {
    modules = {"AnalyticsService"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

---- Public Functions ----

function CurrencyService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
end

function CurrencyService.addCoins(player, amount, itemId, wasPurchased)
    local coins = modules.DataService.get(player, "soft_currency")
    modules.DataService.set(player, "soft_currency", coins + amount)
    if wasPurchased then
        modules.AnalyticsService.addSoftCurrencyPurchasedEvent(player, {
            amount = amount,
            itemId = itemId
        })
    else
        modules.AnalyticsService.addSoftCurrencyRewardedEvent(player, {
            amount = amount,
            itemId = itemId
        })
    end
end

function CurrencyService.addGems(player, amount, itemId, wasPurchased)
    local coins = modules.DataService.get(player, "hard_currency")
    modules.DataService.set(player, "hard_currency", coins + amount)
    if wasPurchased then
        modules.AnalyticsService.addHardCurrencyPurchasedEvent(player, {
            amount = amount,
            itemId = itemId
        })
    else
        modules.AnalyticsService.addHardCurrencyRewardedEvent(player, {
            amount = amount,
            itemId = itemId
        })
    end
end

return CurrencyService