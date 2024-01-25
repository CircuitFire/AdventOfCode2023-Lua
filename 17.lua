require("shared")

local run = {}

local Sides = {
    v = {"e", "w"},
    h = {"n", "s"},
}

local Dir_Sides = {
    n = "v",
    s = "v",
    e = "h",
    w = "h"
}

local Op_Sides = {
    v = "h",
    h = "v"
}

local function get_smaller(map, pos)
    local last = map:get(pos)
    if not last.v.h or (last.h.h and (last.h.h < last.v.h)) then
        return "h", last.h.h
    else
        return "v", last.v.h
    end
end

local function get_larger(map, pos)
    local last = map:get(pos)
    if not last.h.h or (last.v.h and (last.h.h < last.v.h)) then
        return "v", last.v.h
    else
        return "h", last.h.h
    end
end

local function insert(list, distance_map, endpoint)
    if not endpoint then return end
    if not next(list) then list[1] = endpoint end

    local s = endpoint.dir
    local value = distance_map:get(endpoint.pos)[s].h
    for i = 1, #list do
        -- print(serpent.line2(list[i].pos) .. " " .. serpent.line2(distance_map:get(list[i].pos)))
        local _, t = get_larger(distance_map, list[i].pos)
        -- print(t .. " <= " .. value)
        if t <= value then
            table.insert(list, i, endpoint)
            return
        end
    end
    table.insert(list, endpoint)
end

local function check_side(map, distance_map, current, dir, jump)
    local pos = current.pos
    local t_heat = 0
    for i = 1, jump do
        pos = table.add_coords(pos, Map.Dir[dir])
        heat = map:get(pos)
        if not heat then return end
        t_heat = t_heat + tonumber(heat)
    end

    local side = Dir_Sides[dir]
    local new_heat = distance_map:get(current.pos)[Op_Sides[side]].h + t_heat
    local new_pos = distance_map:get(pos)
    local old_heat = new_pos[side].h

    if old_heat and new_heat >= old_heat then return end
    new_pos[side] = {h=new_heat, f=current.pos, d=dir}

    return not old_heat and {dir = side, pos = pos}
end

local function crawl(map, distance_map, endpoints, min, jump)
    local current = table.remove(endpoints)
    
    for _, dir in pairs(Sides[current.dir]) do
        for i = min, jump do
            insert(
                endpoints,
                distance_map,
                check_side(map, distance_map, current, dir, i)
            )
        end
    end
end

function display(line)
    local out = ""
    local count = 1
    for key, value in pairs(line) do
        if key > count then
            out = out .. string.rep(" ", key - count)
            count = key
        end
        out = out .. Map.Dir_Arrows[value.d]
        count = count + 1
    end
    return out
end

function display2(line)
    local out = ""
    local count = 1
    for key, value in pairs(line) do
        if key > count then
            out = out .. string.rep("        ,", key - count)
            count = key
        end
        out = out .. string.format("h%3dv%3d,", value.h.h or 0, value.v.h or 0)
        count = count + 1
    end
    return out
end

local function filter_path(map, pos)
    local stop = {x=1, y=1}
    local count = 0
    local side = get_smaller(map, pos)
    while not table.coord_eq(pos, stop) do
        -- print(serpent.line2(pos))
        local temp = map:get(pos)
        temp.p = temp[side]
        pos = temp[side].f --table.add_coords(pos, Map.Dir[Map.Op[temp.d]])
        side = Op_Sides[side]
        count = count + 1
    end
    print("in path: " .. count)

    map:map(function (value)
        if value and value.p then
            return value.p
        end
        return nil
    end)
end

run["1"] = function ()
    local map = Map.read()
    map:print(table.concat)
    local distance_map = Map.new_fill(map:size(), function () return {h={},v={}} end)
    distance_map:set({x=1, y=1}, {h={h=0}, v={h=0},})

    local endpoints = {
        {dir = "v", pos = {x=1, y=1}},{dir = "h", pos = {x=1, y=1}}
    }

    local size = map:size()
    local i = 0
    while not table.coord_eq(endpoints[#endpoints].pos, size) and i < 3 do
        crawl(map, distance_map, endpoints, 1, 3)
        print(#endpoints)
        -- distance_map:print(display2)
        -- i = i + 1

    end

    -- print()
    -- distance_map:print(display2)
    filter_path(distance_map, size)
    print()
    distance_map:print(display)

    return distance_map:get(size).h
end

run["2"] = function ()
    local map = Map.read()
    map:print(table.concat)
    local distance_map = Map.new_fill(map:size(), function () return {h={},v={}} end)
    distance_map:set({x=1, y=1}, {h={h=0}, v={h=0},})

    local endpoints = {
        {dir = "v", pos = {x=1, y=1}},{dir = "h", pos = {x=1, y=1}}
    }

    local size = map:size()
    local i = 0
    while not table.coord_eq(endpoints[#endpoints].pos, size) and i < 3 do
        crawl(map, distance_map, endpoints, 4, 10)
        print(#endpoints)
        -- distance_map:print(display2)
        -- i = i + 1
    end

    -- print()
    -- distance_map:print(display2)
    filter_path(distance_map, size)
    print()
    distance_map:print(display)

    return distance_map:get(size).h
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())