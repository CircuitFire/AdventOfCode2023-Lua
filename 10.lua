require("shared")

local run = {}


-- | is a vertical pipe connecting north and south.
-- - is a horizontal pipe connecting east and west.
-- L is a 90-degree bend connecting north and east.
-- J is a 90-degree bend connecting north and west.
-- 7 is a 90-degree bend connecting south and west.
-- F is a 90-degree bend connecting south and east.
-- . is ground; there is no pipe in this tile.
-- S is the starting position of the animal;
--   there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.

--n, s, e, w
local Key = {
    ["|"] = {n = "s", s = "n"},
    ["-"] = {e = "w", w = "e"},
    ["L"] = {n = "e", e = "n"},
    ["J"] = {n = "w", w = "n"},
    ["7"] = {s = "w", w = "s"},
    ["F"] = {s = "e", e = "s"},
    ["."] = {},
    ["S"] = {ns = "|", ew = "-", ne = "L", nw = "J", sw = "7", se = "F"},
}

local Op = {
    n = "s",
    s = "n",
    e = "w",
    w = "e"
}

local Dir = {
    n = {y =-1, x = 0},
    s = {y = 1, x = 0},
    e = {y = 0, x = 1},
    w = {y = 0, x =-1},
    ne = {y =-1, x = 1},
    nw = {y =-1, x =-1},
    se = {y = 1, x = 1},
    sw = {y = 1, x =-1},
}

local function get_pos(map, pos)
    return map[pos.y] and map[pos.y][pos.x]
end

local function set_pos(map, pos, new)
    map[pos.y][pos.x] = new
end

local function add_coord(x, y)
    return {x=x.x+y.x, y=x.y+y.y}
end

local function eq_coord(x, y)
    if x.x ~= y.x then return false end
    return x.y == y.y
end

local function make_map()
    local map = {}
    local start
    local y = 1
    ForEachLine(function (line)
        local t = {}
        local x = 1
        for c in line:gmatch(".") do
            table.insert(t, c)
            if c == "S" then
                start = {x=x, y=y}
            end
            x = x + 1
        end
        table.insert(map, t)
        y = y + 1
    end)

    local k = ""
    for _, n in pairs{"n", "s", "e", "w"} do
        local v = Dir[n]
        local pos = get_pos(map, add_coord(start, v))
        -- print(n .. ": " .. tostring(pos))
        if pos and Key[pos][Op[n]] then
            k = k .. n
            -- print(k)
        end
    end
    -- print("new: " .. k .. " s: " .. tostring(Key["S"][k]) .. " pos: " .. serpent.line2(start))
    map[start.y][start.x] = Key["S"][k]

    return map, start
end

local function crawl(map, probe)
    local old = probe.p

    probe.p = add_coord(probe.p, Dir[probe.d])
    local k = get_pos(map, probe.p)
    -- print("next: " .. k .. " at: " .. serpent.line2(probe.p))
    probe.d = Key[k][Op[probe.d]]

    set_pos(map, old, "#")
end

local function print_map(map)
    for _, r in pairs(map) do
        print(table.concat(r))
    end
    print()
end

run["1"] = function ()
    local map, start = make_map()

    -- print_map(map)

    local count = 1
    local k = Key[get_pos(map, start)]
    local p1 = {p=start, d=next(k)}
    local p2 = {p=start, d=next(k, p1.d)}
    -- print(serpent.line2(p1))
    -- print(serpent.line2(p2))
    crawl(map, p1)
    crawl(map, p2)
    -- print(serpent.line2(p1))
    -- print(serpent.line2(p2))

    while not eq_coord(p1.p, p2.p) do
        count = count + 1
        crawl(map, p1)
        crawl(map, p2)
    end

    return count
end

--[[
    F-7
    | |
    L-J
]]

local DKey = {
    ["|"] = {n = {"w"}, s = {"e"}},
    ["-"] = {e = {"n"}, w = {"s"}},
    ["L"] = {n = {"s", "w", "sw"}, e = {}},
    ["J"] = {n = {}, w = {"s", "e", "se"}},
    ["7"] = {s = {"n", "e", "ne"}, w = {}},
    ["F"] = {s = {}, e = {"n", "w", "nw"}},
}

local function mark_helper(map, markers, at, marker, side)
    for _, dir in pairs(side) do
        local pos = add_coord(at, Dir[dir])
        local check = get_pos(map, pos)
        set_pos(markers, pos, marker)
    end
end

local function mark(map, markers, probe)
    local k = get_pos(map, probe.p)
    local marker = probe.m[1]
    local side = DKey[k][probe.d]
    mark_helper(map, markers, probe.p, marker, side) --first side

    local marker = probe.m[2]
    local side = DKey[k][Key[k][probe.d]]
    mark_helper(map, markers, probe.p, marker, side) --next side
end

local function next_marker(map, start)
    for y = start.y, #map do
        for x = start.x + 1, #map[y] do
            local c = map[y][x]
            if c == "1" or c == "2" then
                return c, {x=x, y=y}
            end
        end
    end
end

local function find_inner(map)
    local flip = {
        ["1"] = "2",
        ["2"] = "1"
    }
    local check = {
        x = function (map, pos, e, d)
            for x = pos.x, e, d do
                if map[pos.y][x] == "#" then
                    return false
                end
            end
            return true
        end,
        y = function (map, pos, e, d)
            for y = pos.y, e, d do
                if map[y][pos.x] == "#" then
                    return false
                end
            end
            return true
        end
    }
    
    local pos = {x=0,y=1}
    local char
    while true do
        char, pos = next_marker(map, pos)
        if not char then return end

        local dis = {
            {f="x", e=#map[pos.y], d=1, w=math.abs(#map[pos.y] - pos.x)},
            {f="x", e=1, d=-1, w=math.abs(pos.x - 1)},
            {f="y", e=#map, d=1, w=math.abs(#map - pos.y)},
            {f="y", e=1, d=-1, w=math.abs(pos.y - 1)},
        }

        table:sort(dis, function (x, y)
            return x.w < y.w
        end)

        -- print(serpent.block2(dis))

        if check[dis[1].f](map, pos, dis[1].e, dis[1].d) then
            return flip[char]
        end
    end
end

local function count_char(map, char)
    local count = 0
    for _, r in pairs(map) do
        for _, c in pairs(r) do
            if c == char then count = count + 1 end
        end
    end
    return count
end

local function merge_map_markers(map, markers)
    for y, r in pairs(map) do
        for x, c in pairs(r) do
            if c ~= "#" then
                if markers[y][x] then
                    map[y][x] = markers[y][x]
                else
                    map[y][x] = "."
                end
            end
        end
    end
end

local function fill(map, pos, char)
    set_pos(map, pos, char)
    for k, _ in pairs(Op) do
        local next = add_coord(pos, Dir[k])
        if get_pos(map, next) == "." then
            fill(map, next, char)
        end
    end
end

local function try_fill_each(map, char)
    for y, r in pairs(map) do
        for x, c in pairs(r) do
            if c == char then
                fill(map, {x=x, y=y}, char)
            end
        end
    end
end

run["2"] = function ()
    local map, start = make_map()
    local markers = table.new2d(#map)

    -- print_map(map)

    local k = Key[get_pos(map, start)]
    local p1 = {p=start, d=next(k), m={"1","2"}}
    local p2 = {p=start, d=next(k, p1.d), m={"2","1"}}

    mark(map, markers, p1)
    crawl(map, p1)
    mark(map, markers, p1)
    
    crawl(map, p2)
    mark(map, markers, p2)

    while not eq_coord(p1.p, p2.p) do
        crawl(map, p1)
        mark(map, markers, p1)
        crawl(map, p2)
        mark(map, markers, p2)
    end

    merge_map_markers(map, markers)
    local inner = find_inner(map)
    print("inner: " .. inner)
    try_fill_each(map, inner)
    print_map(map)

    return count_char(map, inner)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())