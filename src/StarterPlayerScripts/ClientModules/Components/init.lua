local Components = {}
Components.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local components = {}

---- Public Functions ----

function Components.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    for _, module in ipairs(script:GetChildren()) do
        if module:IsA("ModuleScript") and not module:IsDescendantOf(script.HoarcekatStories) then
            components[module.Name] = require(module)
        end
    end
end

function Components.new(name)
    if components[name] then
        return components[name]
    end
end

return Components