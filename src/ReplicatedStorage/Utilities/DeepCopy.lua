local function deepCopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    else
        local copy = {}
        for k, v in pairs(tbl) do
            copy[k] = deepCopy(v)
        end
        return copy
    end
end

return deepCopy