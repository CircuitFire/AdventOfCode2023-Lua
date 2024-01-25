require("shared")

local run = {}

run["1"] = function ()
    local total = 0

    ForEachLine(function (line)
        local parts = line:gsub("Card +[%d]+:", ""):gmatch("[^|]+")
        
        local winners = {}
        for value in parts():gmatch("[%d]+") do
            winners[value] = true
        end

        -- print("I")
        local points
        for value in parts():gmatch("[%d]+") do
            if winners[value] then
                points = points and (points * 2) or 1
                -- print("match " .. value .. " p: " .. points)
            end
        end
        
        total = total + (points or 0)
    end)

    return total
end

run["2"] = function ()
    local total = 0
    local doops = {}

    local id = 1
    ForEachLine(function (line)
        doops[id] = doops[id] and doops[id] + 1 or 1
        local parts = line:gsub("Card +[%d]+:", ""):gmatch("[^|]+")
        
        local winners = {}
        for value in parts():gmatch("[%d]+") do
            winners[value] = true
        end

        local points = 0
        for value in parts():gmatch("[%d]+") do
            if winners[value] then
                points = points + 1
                doops[id + points] = doops[id] + (doops[id + points] or 0)
            end
        end
        
        -- print("doops[" .. id .. "] = " .. doops[id])
        total = total + doops[id]
        doops[id] = nil
        id = id + 1
    end)

    return total
end

print("Enter Input:")
print(run[arg[1] or "1"]())