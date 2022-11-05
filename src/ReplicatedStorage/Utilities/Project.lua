return function(u, v)
    return u:Dot(v)/v:Dot(v) * v
end