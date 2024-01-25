require("shared")

local run = {}

local function in_range(ids, syb, check)
    local i = 1
    local len = #ids
    local total = 0
    while i <= len do
        if check(ids[i], syb) then
            -- print(ids[i].n .. "close")
            total = total + tonumber(ids[i].n)
            table.remove(ids, i)
            len = len - 1
        else
            i = i + 1
        end
    end
    return total
end

local function same_line(id, syb)
    return (syb[id.s] and id.s) or (syb[id.e] and id.e)
end

local function dif_line(id, syb)
    for i = id.s, id.e do
        if syb[i] then return i end
    end
end

run["1"] = function ()
    local symbols = {{}, {}}
    local ids = {{}, {}}
    local total = 0

    ForEachLine(function (line)
        symbols[1] = symbols[2]
        symbols[2] = {}
        ids[1] = ids[2]
        ids[2] = {}

        for value in line:gfind("[^%d%.]") do
            symbols[2][value[1]] = true
        end
        for value in line:gfind("([%d]+)") do
            table.insert(ids[2], {n = value[3], s = value[1] - 1, e = value[2] + 1})
        end
        -- print(serpent.line(ids, {comment = false}))
        -- print(serpent.line(symbols, {comment = false}))

        total = total + in_range(ids[2], symbols[2], same_line)
        total = total + in_range(ids[1], symbols[2], dif_line)
        total = total + in_range(ids[2], symbols[1], dif_line)
    end)
    print(total)
end

local function in_range2(ids, syb, check)
    local i = 1
    local len = #ids
    while i <= len do
        local found = check(ids[i], syb)
        if found then
            table.insert(syb[found], ids[i].n)
        end
        i = i + 1
    end
end

run["2"] = function ()
    local symbols = {{}, {}}
    local ids = {{}, {}}
    local total = 0

    ForEachLine(function (line)
        for value in line:gfind("[*]") do
            symbols[2][value[1]] = {}
        end
        for value in line:gfind("([%d]+)") do
            table.insert(ids[2], {n = value[3], s = value[1] - 1, e = value[2] + 1})
        end

        in_range2(ids[2], symbols[2], same_line)
        in_range2(ids[1], symbols[2], dif_line)
        in_range2(ids[2], symbols[1], dif_line)

        -- print(serpent.line(ids, {comment = false}))
        -- print(serpent.line(symbols, {comment = false}))

        for _, value in pairs(symbols[1]) do
            if #value == 2 then
                total = total + (tonumber(value[1]) * tonumber(value[2]))
            end
        end

        symbols[1] = symbols[2]
        symbols[2] = {}
        ids[1] = ids[2]
        ids[2] = {}
    end)
    for _, value in pairs(symbols[1]) do
        if #value == 2 then
            total = total + (tonumber(value[1]) * tonumber(value[2]))
        end
    end
    print(total)
end

print("Enter Input:")
run[arg[1] or "1"]()