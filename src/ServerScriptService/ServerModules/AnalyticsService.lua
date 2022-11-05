local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = {}
AnalyticsService.dependencies = {
    modules = {"LevelService", "StatService"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local GameAnalytics = require(ReplicatedStorage.Packages.GameAnalytics)

---- Private Functions ----

local function setupEventTracking()
    modules.LevelService.levelStarted:Connect(function(plr, lvl)
        AnalyticsService.levelStarted(plr, lvl)
    end)
    modules.LevelService.levelCompleted:Connect(function(plr, lvl, t)
        local formattedScore = math.floor(t*100)
        AnalyticsService.levelEnded(plr, lvl, formattedScore)
    end)
    modules.LevelService.levelFailed:Connect(function(plr, lvl)
        AnalyticsService.levelFailed(plr, lvl)
    end)

    modules.StatService.exhibitionRunCompleted:Connect(function(plr, lvl)
        GameAnalytics:addDesignEvent(plr.UserId, {
            eventId = string.format("Replay:%s", lvl)
        })
    end)

    modules.StatService.nthLevelCompleted:Connect(function(plr, n)
        if n == 2 or n == 1 or n == 5 then
            GameAnalytics:addDesignEvent(plr.UserId, {
                eventId = if n == 1 then "completedFirst" elseif n == 2 then "completedSecond" else "completedFifth"
            })
        end
    end)
end

---- Public Functions ----

function AnalyticsService.init(importedModules, importedUtilities, importedDataStructures, importedConstants, VERSION)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    GameAnalytics:configureBuild(VERSION)
    GameAnalytics:configureAvailableResourceCurrencies({"Coins", "Gems"})
    GameAnalytics:configureAvailableResourceItemTypes({"IAP", "Reward", "ShopItem"})
    GameAnalytics:setEnabledAutomaticSendBusinessEvents(false)
    GameAnalytics:initServer(
        "0ad512560b8edcbafb6b4b3806cf4077",
        "8287467dc87f77d4154214db9a16bcc258782db6"
    )

    setupEventTracking()
end

function AnalyticsService.addBusinessEvent(player, options)
    GameAnalytics:addBusinessEvent(player.UserId, {
        amount = options.amount, -- Amount in Robux
        itemType = options.itemType, -- Type/Category of item
        itemId = options.itemId, -- Specific item bought
        cartType = options.cartType -- Game location of purchase. max 10 unique values.
    })
end

---- Resource Adds ----

function AnalyticsService.addHardCurrencyPurchasedEvent(player, options)
    GameAnalytics:addResourceEvent(player.UserId, {
        flowType = GameAnalytics.EGAResourceFlowType.Source,
        currency = "gems",
        amount = options.amount,
        itemType = "IAP",
        itemId = options.productId
    })
end

function AnalyticsService.addHardCurrencyRewardedEvent(player, options)
    GameAnalytics:addResourceEvent(player.UserId, {
        flowType = GameAnalytics.EGAResourceFlowType.Source,
        currency = "Gems",
        amount = options.amount,
        itemType = "Reward",
        itemId = options.itemId -- Milestone or Streak or ChallengeCompleted
    })
end

function AnalyticsService.addSoftCurrencyPurchasedEvent(player, options)
    GameAnalytics:addResourceEvent(player.UserId, {
        flowType = GameAnalytics.EGAResourceFlowType.Source,
        currency = "Coins",
        amount = options.amount,
        itemType = "IAP",
        itemId = options.productId
    })
end

function AnalyticsService.addSoftCurrencyRewardedEvent(player, options)
    GameAnalytics:addResourceEvent(player.UserId, {
        flowType = GameAnalytics.EGAResourceFlowType.Source,
        currency = "Coins",
        amount = options.amount,
        itemType = "Reward",
        itemId = options.itemId -- Milestone or Streak or ChallengeCompleted or LevelEnd
    })
end

---- Resource Sinks ----

function AnalyticsService.shopPurchaseEvent(player, options)
    GameAnalytics:addResourceEvent(player.UserId, {
        flowType = GameAnalytics.EGAResourceFlowType.Sink,
        currency = options.currency,
        amount = options.amount,
        itemType = "ShopItem",
        itemId = options.itemId 
    })
end

---- Progression ----

function AnalyticsService.levelStarted(player, level)
    GameAnalytics:addProgressionEvent(player.UserId, {
        progressionStatus = GameAnalytics.EGAProgressionStatus.Start,
        progression01 = level
    })
end

function AnalyticsService.levelEnded(player, level, score)
    GameAnalytics:addProgressionEvent(player.UserId, {
        progressionStatus = GameAnalytics.EGAProgressionStatus.Complete,
        progression01 = level,
        score = score
    })   
end

-- When a player quits early
function AnalyticsService.levelFailed(player, level)
    GameAnalytics:addProgressionEvent(player.UserId, {
        progressionStatus = GameAnalytics.EGAProgressionStatus.Fail,
        progression01 = level
    })   
end

return AnalyticsService