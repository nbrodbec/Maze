local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AntiCheatService = {}
AntiCheatService.dependencies = {
    modules = {"PlayerService"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local framePositions = {}
local intervalPositions = {}
local raycastParams = {}
local whitelist = {}

---- Public Functions ----

function AntiCheatService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    modules.PlayerService.addCharacterAddedCallback(function(character)
        local player = Players:GetPlayerFromCharacter(character)
        framePositions[player] = nil

        raycastParams[player] = RaycastParams.new()
        raycastParams[player].FilterDescendantsInstances = {character, workspace.TriggerParts}
        raycastParams[player].FilterType = Enum.RaycastFilterType.Blacklist
        
        local rootPart = character:WaitForChild("HumanoidRootPart")
                         character:WaitForChild("Humanoid")
        rootPart:GetPropertyChangedSignal("CFrame"):Wait()
        framePositions[player] = rootPart.Position
    end)

    PhysicsService:RegisterCollisionGroup("character")
    PhysicsService:CollisionGroupSetCollidable("character", "character", false)
    modules.PlayerService.addCharacterAddedCallback(function(character)
        for _, p in character:GetDescendants() do
            if p:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(p, "character")
            end
        end
        character.DescendantAdded:Connect(function(p)
            if p:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(p, "character")
            end
        end)
    end)

    modules.PlayerService.addPlayerRemovingCallback(function(player)
        framePositions[player] = nil
        raycastParams[player] = nil
        intervalPositions[player] = nil
    end)

    local t = 0
    RunService.Heartbeat:Connect(function(dt)
        t += dt
        for player, oldPos in pairs(framePositions) do
            if not (player.Character and player.Character.Parent) then return end
            local newPos = player.Character.HumanoidRootPart.Position
            local displacement = newPos - oldPos
            local result = workspace:Raycast(oldPos, displacement, raycastParams[player])
            
            if result and not whitelist[player] then
                player.Character.HumanoidRootPart.CFrame -= displacement
            else
                framePositions[player] = newPos
            end

            if t >= 1 then
                if intervalPositions[player] then
                    local avgDisplacement = newPos - intervalPositions[player]
                    local avgXZDisplacement = avgDisplacement - Vector3.new(0, avgDisplacement.Y, 0)
                    if avgXZDisplacement.Magnitude/t > player.Character.Humanoid.WalkSpeed+4 and not whitelist[player] then
                        player.Character.HumanoidRootPart.CFrame -= avgDisplacement
                    else
                        intervalPositions[player] = newPos
                    end
                else
                    intervalPositions[player] = newPos
                end
            end

            if whitelist[player] and time() - whitelist[player] > 3 then
                whitelist[player] = nil
            end
        end
        t = t >= 1 and 0 or t
    end)
end

function AntiCheatService.authorizedTeleport(p, pos)
    local character = p.character
    if character then
        whitelist[p] = time()
        character:MoveTo(pos)
    end
end

return AntiCheatService