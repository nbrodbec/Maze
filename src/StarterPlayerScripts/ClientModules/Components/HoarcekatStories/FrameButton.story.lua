local components = script.Parent.Parent

return function(target)
    local frameButton = require(components.FrameButton) {
        Text = "test",
        Size = UDim2.fromScale(0, 0.5),
        Position = UDim2.fromScale(0.5, 0.5)
    }
    frameButton.Parent = target
    return function()
        
    end
end