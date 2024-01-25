require("shared")

local run = {}

local T = {
    ["L"] = 1,
    ["R"] = 2
}

local function traverse(directions, map, at)
    local count = 0
    while true do
        for _, v in pairs(directions) do
            count = count + 1
            at = map[at][v]
            if map[at][3] then
                return count
            end
        end
    end
end

run["1"] = function ()
    local directions = {}
    for value in io.read():gmatch(".") do
        table.insert(directions, T[value])
    end

    local map = {}
    ForEachLine(function (line)
        local _, _, n, l, r = line:find("(%w+) = %((%w+), (%w+)%)")
        map[n] = {l, r}
        if n == "ZZZ" then
            map[n][3] = true
        end
    end)

    return traverse(directions, map, "AAA")
end

run["2"] = function ()
    local directions = {}
    for value in io.read():gmatch(".") do
        table.insert(directions, T[value])
    end

    local map = {}
    local ats = {}
    ForEachLine(function (line)
        local _, _, n, l, r = line:find("(%w+) = %((%w+), (%w+)%)")
        map[n] = {l, r}

        local e = n:sub(-1)
        -- print(e .. " " .. n)
        if e == "A" then
            table.insert(ats, n)
        end
        if e == "Z" then
            map[n][3] = true
        end
    end)

    local counts = {}
    for _, v in pairs(ats) do
        table.insert(counts, traverse(directions, map, v))
    end

    print(serpent.line2(counts))
    return math.lcmm(counts)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())