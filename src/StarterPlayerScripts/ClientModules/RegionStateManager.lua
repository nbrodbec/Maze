local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local RegionStateManager = {}
RegionStateManager.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local player = Players.LocalPlayer

RegionStateManager.state = nil
local regionEnteredEvents = {}
local regionExitedEvents = {}

---- Public Functions ----

function RegionStateManager.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("region") do
        CollectionService:GetInstanceAddedSignal("region"):Connect(function()
            raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("region")
        end)
        CollectionService:GetInstanceRemovedSignal("region"):Connect(function()
            raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("region")
        end)
    end
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

    RunService.Heartbeat:Connect(function(dt)
        local character = player.Character
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            local result = workspace:Raycast(character.HumanoidRootPart.CFrame.Position + Vector3.new(0, 60, 0), Vector3.new(0, -100, 0), raycastParams)
            local newState
            if result then
                newState = result.Instance:GetAttribute("region")
            end
            if newState ~= RegionStateManager.state then
                if regionExitedEvents[RegionStateManager.state] then
                    regionExitedEvents[RegionStateManager.state]:Fire()
                end
                if newState and regionEnteredEvents[newState] then
                    regionEnteredEvents[newState]:Fire(result.Instance)
                end
            end
            RegionStateManager.state = newState
        end
    end)
end

function RegionStateManager.getRegionEntered(tag)
    local event = regionEnteredEvents[tag]
    if not event then
        event = Instance.new("BindableEvent")
        regionEnteredEvents[tag] = event
    end
    return event.Event
end

function RegionStateManager.getRegionExited(tag)
    local event = regionExitedEvents[tag]
    if not event then
        event = Instance.new("BindableEvent")
        regionExitedEvents[tag] = event
    end
    return event.Event
end

return RegionStateManager