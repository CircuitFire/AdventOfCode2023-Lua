require("shared")

local run = {}

run["1"] = function ()
    local times = {}
    for value in io.read():gmatch("%d+") do
        table.insert(times, tonumber(value))
    end
    local min = {}
    for value in io.read():gmatch("%d+") do
        table.insert(min, tonumber(value))
    end

    local counts = {}
    for index, time in ipairs(times) do
        local count = 0
        for i = math.ceil(time / 2), 0, -1 do
            local t = i * (time - i)
            -- print(t)
            if t < min[index] then break end
            count = count + 1
        end
        if time % 2 ~= 0 then
            count = count - 1
        else
            count = count - .5
        end
        count = count * 2
        -- print("count: " .. count)
        counts[index] = count
    end
    
    local out = 1
    for _, value in pairs(counts) do
        out = out * value
    end
    return out
end

run["2"] = function ()
    local times = {}
    local t = ""
    for value in io.read():gmatch("%d+") do
        t = t .. value
    end
    times[1] = tonumber(t)

    local min = {}
    t = ""
    for value in io.read():gmatch("%d+") do
        t = t .. value
    end
    min[1] = tonumber(t)

    local counts = {}
    for index, time in ipairs(times) do
        local count = 0
        for i = math.ceil(time / 2), 0, -1 do
            local t = i * (time - i)
            -- print(t)
            if t < min[index] then break end
            count = count + 1
        end
        if time % 2 ~= 0 then
            count = count - 1
        else
            count = count - .5
        end
        count = count * 2
        -- print("count: " .. count)
        counts[index] = count
    end
    
    local out = 1
    for _, value in pairs(counts) do
        out = out * value
    end
    return math.floor(out)
end

print("Enter Input:")
print(run[arg[1] or "1"]())