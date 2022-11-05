local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPack = game:GetService("StarterPack")
local RewardHandler = {}
RewardHandler.dependencies = {
    modules = {"Components"},
    utilities = {},
    dataStructures = {"Queue"},
    constants = {"Colours", "UIConstants"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local rewardView = New "ScreenGui" {
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    Name = "Confetti",
    [Children] = {
        New "Frame" {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Name = "ConfettiFrame"
        }
    }
}

local confettiParticle = New "Frame" {
    Size = UDim2.fromOffset(5, 15)
}

local confettiColours = {
    Color3.new(1, 0, 0),
    Color3.new(0, 1, 0),
    Color3.new(0, 0, 1),
    Color3.new(1, 1, 0),
    Color3.new(0, 1, 1),
    Color3.new(1, 0, 1)
}

local currentlyViewing = State()

---- Private Functions ----

local function confetti()
    local emitter = require(ReplicatedStorage.ParticleEmitter).new(rewardView.ConfettiFrame, confettiParticle)
    emitter.rate = 25
    local omega = 4*math.pi
    local v = 300
    local vpSize = rewardView.AbsoluteSize
    function emitter.onSpawn(particle)
        particle.maxAge = vpSize.Y/v + 0.5
        particle.velocity = Vector2.new(math.random(-vpSize.X/10, vpSize.X/10), v)
        particle.position = Vector2.new(math.random(rewardView.AbsoluteSize.X), 0)
        particle.element.Rotation = math.random(90)
        particle.omega = math.random(2*omega/3, omega) * (-1)^math.random(1,2)
        particle.element.BackgroundColor3 = confettiColours[math.random(#confettiColours)]
    end
    function emitter.onUpdate(particle, dt)
        particle.position = particle.position + particle.velocity*dt
        particle.element.Rotation += math.deg(particle.omega)*dt
        particle.element.Size = UDim2.fromOffset(6 + 4*math.sin(particle.omega*particle.age), 15)
    end

    task.delay(5, emitter.Destroy, emitter)
end

---- Public Functions ----

function RewardHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    

    local frame = modules.Components.new "TileFrame" {
        Type = "CHECKER",
        Filled = true,
        Size = UDim2.fromScale(0, 0.7),
        Visible = Computed(function()
            return currentlyViewing:get() ~= nil
        end),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),

        Children = {
            New "UIAspectRatioConstraint" {
                DominantAxis = Enum.DominantAxis.Height,
                AspectRatio = 0.75,
                AspectType = Enum.AspectType.ScaleWithParentSize
            },
            New "UISizeConstraint" {
                MaxSize = Vector2.new(constants.UIConstants.MAX_FRAME_HEIGHT*0.75, constants.UIConstants.MAX_FRAME_HEIGHT)
            }
        },
        Content = currentlyViewing
    }
    
    frame.Parent = rewardView
    rewardView.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local rewardQueue = dataStructures.Queue.new()
    RunService.Heartbeat:Connect(function(deltaTime)
        if not rewardQueue:isEmpty() and currentlyViewing:get() == nil then
            local details = rewardQueue:dequeue()
            if details.type == "MSG" then
                RewardHandler.rewardMsg(details)
            elseif details.type == "COINS" then
                RewardHandler.rewardCoins(details)
            end
        end
    end)
    remotes.SendReward.OnClientEvent:Connect(function(details)
        rewardQueue:enqueue(details)
    end)
end

function RewardHandler.rewardCoins(details)
    currentlyViewing:set({
        New "TextLabel" {
            Font = Enum.Font.FredokaOne,
            Text = details.title,
            TextScaled = true,
            Size = UDim2.fromScale(1, 0.1),
            BackgroundTransparency = 1,
            TextColor3 = constants.Colours.RED_ORANGE
        },
        New "TextLabel" {
            Text = details.body,
            TextWrapped = true,
            Font = Enum.Font.FredokaOne,
            TextScaled = true,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0.4),
            Position = UDim2.fromScale(0, 0.15),
            TextColor3 = constants.Colours.BLUE,
            [Children] = New "UITextSizeConstraint" {
                MaxTextSize = 18
            }
        },
        New "ImageLabel" {
            Size = UDim2.fromScale(1, 0.3),
            Position = UDim2.fromScale(0, 0.55),
            Image = "http://www.roblox.com/asset/?id=11437780948",
            ScaleType = Enum.ScaleType.Fit,
            BackgroundTransparency = 1,
        },
        modules.Components.new "TextButton" {
            Size = UDim2.fromScale(0, 0.15),
            Position = UDim2.fromScale(0.5, 1),
            AnchorPoint = Vector2.new(0.5, 1),
            Text = "Collect!",
            Color = constants.Colours.GREEN,
            Callback = function()
                currentlyViewing:set(nil)
            end
        }
    })
    if details.confetti then confetti() end
end

function RewardHandler.rewardPromo(details)
    
end

function RewardHandler.rewardItem(details)
    
end

function RewardHandler.rewardMsg(details)
    currentlyViewing:set({
        New "TextLabel" {
            Font = Enum.Font.FredokaOne,
            Text = details.title,
            TextScaled = true,
            Size = UDim2.fromScale(1, 0.1),
            BackgroundTransparency = 1,
            TextColor3 = constants.Colours.RED_ORANGE
        },
        New "TextLabel" {
            Text = details.body,
            TextWrapped = true,
            Font = Enum.Font.FredokaOne,
            TextScaled = true,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0.6),
            Position = UDim2.fromScale(0, 0.15),
            TextColor3 = constants.Colours.BLUE,
            [Children] = New "UITextSizeConstraint" {
                MaxTextSize = 18
            }
        },
        modules.Components.new "TextButton" {
            Size = UDim2.fromScale(0, 0.15),
            Position = UDim2.fromScale(0.5, 1),
            AnchorPoint = Vector2.new(0.5, 1),
            Text = "Ok!",
            Color = constants.Colours.ORANGE,
            Callback = function()
                currentlyViewing:set(nil)
            end
        }
    })
    if details.confetti then confetti() end
end

function RewardHandler.rewardEmpty()
    confetti()
end

return RewardHandler