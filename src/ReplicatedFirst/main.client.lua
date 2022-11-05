local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local SocialService = game:GetService("SocialService")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

---- Loading screen ----

-- script.Parent:RemoveDefaultLoadingScreen()
-- local loadingUI = script.Parent:WaitForChild("Intro"):Clone()
-- loadingUI.Parent = PlayerGui

-- StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

-- local loadables = {game:GetService("SoundService"), loadingUI}
-- local loaded = false
-- local loadedEvent = Instance.new("BindableEvent")
-- coroutine.wrap(function()
-- 	for i = 1, #loadables do
-- 		ContentProvider:PreloadAsync({loadables[i]})
-- 	end
-- 	loaded = true
--     loadedEvent:Fire()
-- end)()
-- local moduleLoaded = false
-- local moduleLoadedEvent = Instance.new("BindableEvent")
-- coroutine.wrap(function()
     require(ReplicatedStorage:WaitForChild("MainModule")).init(player.PlayerScripts:WaitForChild("ClientModules"))
--     moduleLoaded = true
--     moduleLoadedEvent:Fire()
-- end)()

-- local vueText = loadingUI:WaitForChild("vueText")
-- local sound = loadingUI:WaitForChild("Music")
-- local b1 = loadingUI:WaitForChild("backgroundColourOne")
-- local b2 = loadingUI:WaitForChild("backgroundColourTwo")
-- local b3 = loadingUI:WaitForChild("backgroundColourThree")
-- local b4 = loadingUI:WaitForChild("backgroundColourFour")

-- -- start intro
-- vueText.ImageTransparency = 1
-- repeat wait() until sound.Loaded
-- sound.Playing = true

-- coroutine.wrap(function()
-- 	for i = 1, 0, -0.01 do
-- 		vueText.ImageTransparency = i
-- 		wait()
-- 	end
-- end)()

-- wait(4)

-- b2:TweenPosition(
-- 	UDim2.new(0, 0,-0.125, 0),
-- 	"Out",
-- 	"Quart",
-- 	1
-- )

-- wait(.5)

-- b3:TweenPosition(
-- 	UDim2.new(0, 0,-0.125, 0),
-- 	"Out",
-- 	"Quart",
-- 	1
-- )

-- wait(.5)

-- vueText:TweenSize(UDim2.new(0.35, 0, 0.35, 0),
-- 	"Out",
-- 	"Elastic",
-- 	1
-- )
-- b4:TweenPosition(
-- 	UDim2.new(0, 0,-0.125, 0),
-- 	"Out",
-- 	"Quart",
-- 	1
-- )	 


-- if not loaded then loadedEvent.Event:Wait() end
-- if not moduleLoaded then moduleLoadedEvent.Event:Wait() end

-- -- end intro
-- wait(1)

-- b1.BackgroundTransparency = 1
-- b2.BackgroundTransparency = 1
-- b3.BackgroundTransparency = 1

-- for i = 0, 1, 0.025 do
-- 	b4.BackgroundTransparency = i
-- 	vueText.ImageTransparency = i
-- 	wait()
-- end

-- SocialService:PromptGameInvite(game.Players.LocalPlayer)

-- loadingUI:Destroy()

-- StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)

--------

require(ReplicatedStorage.MainModule).onLoadFinished()


