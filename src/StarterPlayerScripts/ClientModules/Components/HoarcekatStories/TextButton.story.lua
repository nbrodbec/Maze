local components = script.Parent.Parent

return function(target)
    local button = require(components.TextButton) {
        Text = "Test",
        Position = UDim2.fromScale(0.2, 0.5),
        Size = UDim2.fromScale(.2, 0)
    }
    button.Parent = target
    return function()
        
    end
end