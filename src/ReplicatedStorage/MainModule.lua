--[[
    Main Client Module
    First module to run, every other client module will be loaded from this one
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local dependencies = {
    modules = {},
    dataStructures = {},
    utilities = {},
    constants = {}
}

local Main = {}
local VERSION = "1.0.0"
print(VERSION)

---- Private Members ----

local clientModuleNames = {
    "DataHandler",
    "MazeHandler",
    "RegionStateManager",
    "Components",
    "LevelHandler",
    "EffectsHandler",
    "LoadUI",
    "LeaderboardHandler",
    "RewardHandler",
    "MenuHandler",
    "ShopHandler",
    "WelcomeHandler",
    "MusicHandler",
    "AnalyticsHandler",
    "FinalizeClient" -- Last module
}
local serverModuleNames = {
    "DataService",
    "CurrencyService",
    "PlayerService",
    "AntiCheatService",
    "SeedService",
    "Maze",
    "LevelService",
    "StatService",
    "RewardService",
    "MonetizationService",
    "AnalyticsService"
}
local modules = {}

---- Private Functions ----

local function loadModule(moduleName, folder)
    local module = folder:FindFirstChild(moduleName, true)
    if module then
        module = require(module)
        table.insert(modules, module)
        dependencies.modules[moduleName] = module
    end
end

local function initModule(module)
    if module.init then
        local info = {
            utilities = {},
            modules = {},
            dataStructures = {},
            constants = {}
        }
        for className, class in pairs(module.dependencies) do
            if type(class) == "table" then
                for _, dependency in ipairs(class) do
                    info[className][dependency] = dependencies[className][dependency]
                end
            end
        end
        module.init(info.modules, info.utilities, info.dataStructures, info.constants, VERSION)
    end
end

---- Public Functions ----

function Main.init(folder)
    for _, utility in ipairs(ReplicatedStorage:WaitForChild("Utilities"):GetChildren()) do
        dependencies.utilities[utility.Name] = require(utility)
    end    
    for _, dataStructure in ipairs(ReplicatedStorage:WaitForChild("DataStructures"):GetChildren()) do
        dependencies.dataStructures[dataStructure.Name] = require(dataStructure)
    end    
    for _, constant in ipairs(ReplicatedStorage:WaitForChild("Constants"):GetChildren()) do
        dependencies.constants[constant.Name] = require(constant)
    end 
    local moduleNames = RunService:IsServer() and serverModuleNames or clientModuleNames
    for _, moduleName in ipairs(moduleNames) do
        loadModule(moduleName, folder)
    end
    for _, module in ipairs(modules) do
        initModule(module)
    end
end

function Main.onLoadFinished()
    for _, module in ipairs(modules) do
        if module.onLoadFinished then
            module.onLoadFinished()
        end
    end
end

return Main