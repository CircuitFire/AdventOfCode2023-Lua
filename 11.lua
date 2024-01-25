require("shared")

local run = {}

local function get_map()
    local map = {}
    ForEachLine(function (line)
        local row = {}
        for value in line:gfind("#") do
            row[value[1]] = true
        end
        table.insert(map, row)
    end)

    return map
end

local function check_column()
    
end

local function add_space(map, mul)
    -- x
    local shifts = {}
    local max = 0
    for y, row in pairs(map) do
        for x, _ in pairs(row) do
            shifts[x] = true
            if x > max then max = x end
        end
    end

    local shift = 0
    for i = 1, max do
        if not shifts[i] then shift = shift + mul - 1 end
        shifts[i] = shift
    end

    for y, row in pairs(map) do
        local new = {}
        for x, v in pairs(row) do
            new[x + shifts[x]] = v
        end
        map[y] = new
    end
    -- y
    local shifts = {}
    local max = #map
    for y, row in pairs(map) do
        if next(row) then
            shifts[y] = true
        end
    end
    -- print(serpent.line2(shifts))

    local shift = 0
    for i = 1, max do
        if not shifts[i] then shift = shift + mul - 1 end
        shifts[i] = shift
    end
    -- print(serpent.line2(shifts))

    for y = max, 1, -1 do
        if next(map[y]) then
            -- print(y .. ": " .. serpent.line2(map[y]) .."->" .. y + shifts[y])
            map[y + shifts[y]] = map[y]
        end
        if shifts[y] ~= 0 then
            map[y] = nil
        end
    end
end

local function flatten(map)
    local n = {}
    for y, row in pairs(map) do
        for x, _ in pairs(row) do
            table.insert(n, {x=x, y=y})
        end
    end
    return n
end

local function measure(gal)
    local total = 0
    for i = 1, #gal - 1 do
        for j = i + 1, #gal do
            total = total + (math.abs(gal[i].x - gal[j].x) + math.abs(gal[i].y - gal[j].y))
        end
    end
    return total
end

run["1"] = function ()
    local map = get_map()
    -- print(serpent.block2(map))
    add_space(map, 2)
    -- print(serpent.block2(map))
    local galaxies = flatten(map)
    -- print(serpent.line2(galaxies))

    return measure(galaxies)
end

run["2"] = function ()
    local map = get_map()
    add_space(map, 1000000)
    -- print(serpent.block2(map))
    local galaxies = flatten(map)

    return measure(galaxies)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())