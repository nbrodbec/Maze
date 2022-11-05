local RunService = game:GetService("RunService")
local EffectsHandler = {}
EffectsHandler.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

---- Public Functions ----

function EffectsHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local effects = {}
    for _, module in ipairs(script:GetChildren()) do
        if module:IsA("ModuleScript") then
            local effect = require(module)
            effect.init()
            table.insert(effects, effect)
        end
    end
    RunService.RenderStepped:Connect(function(dt)
        for _, effect in ipairs(effects) do
            task.spawn(effect.renderStepped, dt)
        end
    end)
    RunService.Heartbeat:Connect(function(dt)
        for _, effect in ipairs(effects) do
            task.spawn(effect.heartbeat, dt)
        end
    end)
end

return EffectsHandler