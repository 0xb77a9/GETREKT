-- Delayed Call [Library]
-- Made By BETA

-- Locals
local DelayCall = {}

-- Functions
DelayedCall = function(time, func)
    table.insert(DelayCall, {
        ReqTime = client.time_since_inject() + (time * 1000),
        thread = coroutine.create(func)
    })
end

-- Callbacks
callbacks.register("paint", function()
    local Time = client.time_since_inject()
    for i, v in ipairs(DelayCall) do
        if Time >= v.ReqTime then
            coroutine.resume(v.thread)
            table.remove(DelayCall, i)
        end
    end
end)
return DelayedCall