local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local MusicHandler = {}
MusicHandler.dependencies = {
    modules = {"LevelHandler"},
    utilities = {"Shuffle", "DeepCopy"},
    dataStructures = {"Queue"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local soundIds = {
    1836652313,
    1846873443,
    1837645098,
    1840260565,
    1840565314
}
local muted, playerMuted = false, false
local sounds = {}
local queue
local soundGroup

---- Public Functions ----

function MusicHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    soundGroup = Instance.new("SoundGroup")
    for i, id in soundIds do
        local sound = Instance.new("Sound")
        sound.SoundId = string.format("rbxassetid://%d", id)
        sound.Parent = soundGroup
        sound.SoundGroup = soundGroup
        sounds[i] = sound
    end
    soundGroup.Parent = SoundService

    queue = dataStructures.Queue.new(
        utilities.Shuffle(
            utilities.DeepCopy(
                sounds
            )
        )
    )

    modules.LevelHandler.levelEntered:Connect(function()
        MusicHandler.toggleMute(true)
    end)

    modules.LevelHandler.levelExited:Connect(function()
        MusicHandler.toggleMute(false)
    end)

    MusicHandler.start()
end

function MusicHandler.start()
    task.spawn(function()
        while true do
            if queue:isEmpty() then
                queue = dataStructures.Queue.new(
                    utilities.Shuffle(
                        utilities.DeepCopy(
                            sounds
                        )
                    )
                )
            end
            local currentTrack = queue:dequeue()
            currentTrack:Play()
            currentTrack.Ended:Wait()
        end
    end)
end

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)

function MusicHandler.silence()
    TweenService:Create(
        soundGroup,
        tweenInfo,
        {
            Volume = 0
        }
    ):Play()
end

function MusicHandler.desilence()
    TweenService:Create(
        soundGroup,
        tweenInfo,
        {
            Volume = 0.5
        }
    ):Play()  
end

function MusicHandler.toggleMute(bool)
    muted = if bool ~= nil then bool else not muted
    if muted or playerMuted then
        MusicHandler.silence()
    else
        MusicHandler.desilence()
    end
end

function MusicHandler.togglePlayerMute(bool)
    playerMuted = if bool ~= nil then bool else not playerMuted
    if playerMuted or muted then
        MusicHandler.silence()
    else
        MusicHandler.desilence()
    end
end

return MusicHandler