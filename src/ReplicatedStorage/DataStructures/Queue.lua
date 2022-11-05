local Queue = {}
Queue.__index = Queue

function Queue.new(array)
    return setmetatable({
        list = array or {},
        head = 1,
        tail = if array then #array else 0
    }, Queue)
end

function Queue:enqueue(val)
    self.tail += 1
    self.list[self.tail] = val
end

function Queue:dequeue()
    local val = self.list[self.head]
    if val then
        self.list[self.head] = nil
        self.head += 1
        return val
    end
end

function Queue:peek()
    return self.list[self.head]
end

function Queue:length()
    return (self.tail - self.head) + 1
end

function Queue:isEmpty()
    return self.tail < self.head
end

function Queue:iterate()
    return function()
        return self:dequeue()
    end
end

return Queue