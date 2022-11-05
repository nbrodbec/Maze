local Stack = {}
Stack.__index = Stack

function Stack.new(list)
    assert(type(list) == "table" or type(list) == "nil", "DataStructure.Stack can only be created with a table or nil value")
    return setmetatable(
        list or {},
        Stack
    )
end

function Stack:push(val)
    table.insert(self, val)
end

function Stack:pop()
    if #self > 0 then
        return table.remove(self)
    end
end

function Stack:peek()
    return self[#self]
end

function Stack:iterate()
    return function()
        return self:pop()
    end
end

return Stack