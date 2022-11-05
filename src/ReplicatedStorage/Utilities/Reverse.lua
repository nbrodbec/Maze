return function(tbl)
    local rev = {}
    local j = 1
    for i = #tbl, 1, -1 do
        rev[j] = tbl[i]
        j += 1
    end
    return rev
end