require("shared")

local run = {}

local PV = {
    [5] = 6, --Five of a kind
    [4] = 5, --Four of a kind
    [3] = 3, --Three of a kind/Full house
    [2] = 1, --One pair/Two pair
    [1] = 0, --High card
}

local CV = {
    ["A"] = 13,
    ["K"] = 12,
    ["Q"] = 11,
    ["J"] = 10,
    ["T"] = 9,
    ["9"] = 8,
    ["8"] = 7,
    ["7"] = 6,
    ["6"] = 5,
    ["5"] = 4,
    ["4"] = 3,
    ["3"] = 2,
    ["2"] = 1,
}

local function sort(x, y)
    if x.p == y.p then
        for i, _ in pairs(x.c) do
            if x.c[i] ~= y.c[i] then
                return x.c[i] < y.c[i]
            end
        end
    end

    return x.p < y.p
end

local function base(func)
    local hands = {}
    ForEachLine(function (line)
        local x = func(line)
        -- print(serpent.line2(x))
        table.insert(hands, x)
    end)

    table.sort(hands, sort)

    local total = 0
    for i, x in ipairs(hands) do
        total = total + (x.b * i)
        print(i .. ": ".. serpent.line2(x))
    end

    return total
end

local function hand_data(line)
    local _, _, c1, c2, c3, c4, c5, b = line:find("(.)(.)(.)(.)(.) (%d+)")
    local cards = {CV[c1], CV[c2], CV[c3], CV[c4], CV[c5]}
    local count = {}
    for _, value in pairs(cards) do
        count[value] = count[value] and (count[value] + 1) or 1
    end
    return cards, tonumber(b), count
end

run["1"] = function ()
    return base(function (line)
        local cards, b, count = hand_data(line)
    
        local temp = {}
        for _, value in pairs(count) do
            table.insert(temp, value)
        end
        table.sort(temp, function (x, y)
            return x > y
        end)
    
        local p = PV[temp[1]]
        if (p == 1 or p == 3) and temp[2] == 2 then p = p + 1 end
    
        return {p=p, c=cards, b=b}
    end)
end

run["2"] = function ()
    return base(function (line)
        local cards, b, count = hand_data(line)

        for i, c in ipairs(cards) do
            if c == 10 then cards[i] = 0 end
        end
        count[0] = count[10] or 0
        count[10] = nil

        local temp = {}
        local j = 0
        for i, v in pairs(count) do
            if i == 0 then
                j = v
            else
                table.insert(temp, v)
            end
        end
        table.sort(temp, function (x, y)
            return x > y
        end)

        local p = PV[j + (temp[1] or 0)]
        if (p == 1 or p == 3) then
            local x = temp[2] or 0
            if x == 2 then p = p + 1 end
        end

        return {p=p, c=cards, b=b}
    end)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())