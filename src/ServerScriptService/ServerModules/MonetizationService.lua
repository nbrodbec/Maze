local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonetizationService = {}
MonetizationService.dependencies = {
    modules = {"DataService", "AnalyticsService"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

---- Public Functions ----

function MonetizationService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local callbacks = {
        [1333472379] = MonetizationService.sellHint
    }

    function MarketplaceService.ProcessReceipt(receipt)
        local playerId, id = receipt.PlayerId, receipt.ProductId
        local success, player = pcall(Players.GetPlayerByUserId, Players, playerId)
        if success and player and callbacks[id] then
            if modules.DataService.get(player, "is_first_purchase_user") then
                modules.DataService.set(player, "is_repeat_purchase_user", true)
            else
                modules.DataService.set(player, "is_first_purchase_user", true)
            end
            callbacks[id](player, id)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        else
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end
end

function MonetizationService.sellHint(player, receipt)
    remotes.SellHint:FireClient(player)
    modules.AnalyticsService.addBusinessEvent(player, {
        amount = receipt.CurrencySpent,
        itemType = "hint",
        itemid = receipt.ProductId,
        cartType = "DuringLevel"
    })
end

return MonetizationService