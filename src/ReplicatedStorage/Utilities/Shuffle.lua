-- Fisher-Yates
return function(tbl, seed)
    local generator = if seed then Random.new(seed) else Random.new()
	for i = #tbl, 2, -1 do
		local j = generator:NextInteger(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end