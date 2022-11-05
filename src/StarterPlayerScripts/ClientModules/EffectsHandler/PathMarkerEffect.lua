local CollectionService = game:GetService("CollectionService")
local effect = {}
local markers = {}

local A = 0.5
local t = 0
local omega = math.pi

function effect.init()
    markers = CollectionService:GetTagged("path_marker")
    CollectionService:GetInstanceAddedSignal("path_marker"):Connect(function(marker)
        markers[marker] = true
    end)
    CollectionService:GetInstanceRemovedSignal("path_marker"):Connect(function(marker)
        markers[marker] = nil
    end)
end

function effect.heartbeat(dt)
    t += dt
    local v = A*omega*math.cos(omega*t)
    local dx = v * dt
    for marker in markers do
        marker.CFrame *= CFrame.new(0, dx, 0)
    end
end

function effect.renderStepped(dt)
end

return effect