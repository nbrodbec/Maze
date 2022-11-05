local DisjointSet = {}

function DisjointSet.new(v)
    local set = setmetatable({
        parent = nil,
        rank = 0,
        value = v
    }, {__index = DisjointSet})

    set.parent = set

    return set
end

function DisjointSet:find()
    local root = self
    while root.parent ~= root do
        root = root.parent
    end

    local x = self
    while x ~= root do
        local parent = x.parent
        x.parent = root
        x = parent
    end

    return root
end

function DisjointSet:union(b)
    local a = self:find()
    b = b:find()

    if a.rank > b.rank then
        b.parent = a
    elseif b.rank > a.rank then
        a.parent = b
    else
        b.parent = a
        a.rank += 1
    end
end

return DisjointSet