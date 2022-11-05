local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("MainModule")).init(ServerScriptService:WaitForChild("ServerModules"))