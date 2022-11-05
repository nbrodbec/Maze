local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RewardService = {}
RewardService.dependencies = {
    modules = {"StatService", "DataService", "CurrencyService"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local completionRewards = {
    lvl_1 = 10,
    lvl_2 = 15,
    lvl_3 = 20,
    lvl_4 = 25,
    lvl_5 = 30,
    lvl_6 = 35,
    lvl_7 = 50,
    lvl_8 = 100
}

---- Public Functions ----

function RewardService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    modules.StatService.exhibitionRunCompleted:Connect(function(player)
        remotes.SendReward:FireClient(player, {
            type = "MSG",
            title = "Nice!",
            body = "You completed the maze! However, you've already completed this level today, so we won't count your time.\n\nCome back tomorrow to try to beat your score, and get some coins!",
            confetti = true
        })
    end)

    modules.StatService.levelCompletedFirstTimeToday:Connect(function(player, level)
        if completionRewards[level] then
            modules.CurrencyService.addCoins(player, completionRewards[level], "LevelEnd")
            remotes.SendReward:FireClient(player, {
                type = "COINS",
                title = "Congratulations!",
                body = string.format(
                    "You completed the maze! As a reward, here's %d coins!\n\nCome back tomorrow to try to beat your score, and earn some more coins!",
                    completionRewards[level]
                ),
                amt = completionRewards[level],
                confetti = true
            })
        end
    end)

    modules.StatService.nthLevelCompleted:Connect(function(player, n)
        if n == 2 then
            -- Todo: set promo
            remotes.SendReward:FireClient(player, {
                type = "PROMO",
                title = "Woah!",
                body = "You're on a roll!",
                item = 0, -- Todo: Setup promo offer
                confetti = true
            })
        end
    end)
end

return RewardService