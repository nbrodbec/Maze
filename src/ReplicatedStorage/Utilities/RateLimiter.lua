local Players = game:GetService("Players")
local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(cooldown, limit)
    local rateLimiter = setmetatable({
        _cooldown = cooldown or 1,
        _limit = limit or 1,
        _playerTimestamps = {},
        _playerRequestAmounts = {}
    }, RateLimiter)

    Players.PlayerRemoving:Connect(function(player)
        rateLimiter._playerTimestamps[player] = nil
        rateLimiter._playerRequestAmounts[player] = nil
    end)

    return rateLimiter
end

function RateLimiter:check(player)
    if self._playerTimestamps[player] then
        local diff = time() - self._playerTimestamps[player]
        if diff < self._cooldown then
            if self._playerRequestAmounts[player] >= self._limit then
                return false
            else
                self._playerRequestAmounts[player] += 1
                return true
            end
        else
            self._playerTimestamps[player] = time()
            self._playerRequestAmounts[player] = 1
            return true
        end
    else
        self._playerTimestamps[player] = time()
        self._playerRequestAmounts[player] = 1
        return true
    end
end

return RateLimiter