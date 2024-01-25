
local run = {}

local function foreachline(func)
    local line = io.read()
    while line do
        if line ~= "" then
            func(line)
        end
        line = io.read()
    end
end

run["1"] = function ()
    local total = 0

    foreachline(function (line)
        local _, _, game = line:find("Game (%d+):")
        
        local counts = {red = 0, green = 0, blue = 0}
        for num, name in line:gmatch(" (%d+) (%a+)") do
            num = tonumber(num)
            if counts[name] < num then
                counts[name] = num
            end
        end

        if counts["red"] <= 12 and counts["green"] <= 13 and counts["blue"] <= 14 then
            total = total + game
        end
    end)

    print(total)
end

run["2"] = function ()
    local total = 0

    foreachline(function (line)
        local counts = {red = 0, green = 0, blue = 0}
        for num, name in line:gmatch(" (%d+) (%a+)") do
            num = tonumber(num)
            if counts[name] < num then
                counts[name] = num
            end
        end

        total = total + (counts["red"] * counts["green"] * counts["blue"])
    end)

    print(total)
end

print("Enter Input:")
run[arg[1] or "1"]()