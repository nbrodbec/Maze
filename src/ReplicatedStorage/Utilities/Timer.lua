local RunService = game:GetService("RunService")

-- binary insertion into an array sorted in descending order
local function binaryInsert(list, value)
    local low = 1
    local high = #list
    while low <= high do
        local mid = math.floor((high + low)/2)
        if value > list[mid] then
            high = mid - 1
        elseif value < list[mid] then
            low = mid + 1
        else
            table.insert(list, mid, value)
            return
        end
    end
    table.insert(list, high+1, value)
end

---- Public Class ----
local Timer = {}
Timer.__index = Timer
Timer.__lt = function(t, v)
    return t:timeLeft() < v:timeLeft()
end
Timer.__le = function(t, v)
    return t:timeLeft() <= v:timeLeft()
end
local timers = {}

function Timer.new(t)
    local self = setmetatable({
        length = math.max(0, t),
        started = 0,
        stopped = nil,
        finished = Instance.new("BindableEvent"),
        running = false
    }, Timer)
    
    return self
end

function Timer:start()
    if self.running then self:stop() end
    self.started = time()
    self.stopped = nil
    binaryInsert(timers, self)
    self.running = true
    return self
end

function Timer:stop()
    self.stopped = time()
    self.finished:Fire()
    self.running = false
end

function Timer:yield()
    if not self.stopped then
        self.finished.Event:Wait()
    end
end

function Timer:timeLeft()
    return self.length - (time() - self.started)
end

RunService.Stepped:Connect(function()
    local timer = timers[#timers]
    while timer do
        if timer:timeLeft() <= 0 then
            timer:stop()
            timers[#timers] = nil
            timer = timer[#timers]
        else
            timer = nil
        end
    end
end)

return Timer