local CollectionService = game:GetService("CollectionService")
local effect = {}
local rings = {}

local A = 0.75
local t = 0
local omega = math.pi/2

function effect.init()
    rings = CollectionService:GetTagged("glow_ring")
    CollectionService:GetInstanceAddedSignal("glow_ring"):Connect(function(ring)
        table.insert(rings, ring)
    end)
end

function effect.heartbeat(dt)
    t += dt
    local v = A*omega*math.cos(omega*t)
    local dx = v * dt
    for _, ring in ipairs(rings) do
        ring.CFrame *= CFrame.new(0, dx/2, 0)
        ring.Size += Vector3.new(0, dx, 0)
    end
end

function effect.renderStepped(dt)
end

return effect