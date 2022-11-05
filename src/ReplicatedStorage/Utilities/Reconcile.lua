local function deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = deepCopy(value)
    end
    return copy
end

local function reconcile(data, template)
    for key, value in pairs(deepCopy(data)) do
        if type(key) ~= "number" and template[key] == nil then
            data[key] = nil
        end
        if next(template) ~= nil and type(key) == "string" and tonumber(key) then
            data[key] = nil
            data[tonumber(key)] = value
        elseif next(template) == nil then
            data[key] = value
        end
    end
    for key, value in pairs(template) do
        if data[key] == nil then
            data[key] = deepCopy(value)
        elseif type(data[key]) == "table" then
            reconcile(data[key], template[key])
        elseif type(key) == "number" then
            if not table.find(data, value) then
                table.insert(data, value)
            end
        end
    end
    return data
end

return reconcile
