#!lua
require("shared")

local run = {}

local Dir = {
    n = {y =-1, x = 0},
    s = {y = 1, x = 0},
    e = {y = 0, x = 1},
    w = {y = 0, x =-1},
}

local Next_Dir = {
    ["."]  = {n = "n", s = "s", e = "e", w = "w"},
    ["\\"] = {n = "w", s = "e", e = "s", w = "n"},
    ["/"]  = {n = "e", s = "w", e = "n", w = "s"},
    ["-"]  = {n = "w", s = "e", e = "e", w = "w"},
    ["|"]  = {n = "n", s = "s", e = "n", w = "s"},
}

local Split = {
    ["-"]  = {n = "e", s = "w"},
    ["|"]  = {e = "s", w = "n"},
}

local Laser_Key = {
    n = "^",
    s = "v",
    e = ">",
    w = "<",
}

local function trace(laser, lasers, map, laser_map)
    while true do
        -- print(serpent.line2(laser))
        local c = map:get(laser.pos)
        if not c then
            -- print("left map")
            return
        end

        local new = Split[c] and Split[c][laser.dir]
        if new then
            table.insert(lasers, {pos=laser.pos, dir=new})
        end

        local l = laser_map:get(laser.pos)
        -- if not l then print(serpent.line2(laser)) end
        l[laser.dir] = true
        laser.dir = Next_Dir[c][laser.dir]

        laser.pos = table.add_coords(laser.pos, Dir[laser.dir])

        l = laser_map:get(laser.pos)
        if l and l[laser.dir] then
            -- print("moving onto laser")
            return
        end
    end
end

local function count_beam(laser_map)
    local total = 0
    for i = 1, laser_map:num_columns() do
        for pos, value in laser_map:in_row(i) do
            if next(value) then
                total = total + 1
            end
        end
    end
    return total
end

function format(value)
    local out = ""
    for _, v in pairs(value) do
        if v.n or v.s then
            if v.e or v.w then
                out = out ..  "+"
            else
                out = out ..  "|"
            end
        else
            if v.e or v.w then
                out = out ..  "-"
            else
                out = out ..  " "
            end
        end
    end
    return out
end

run["1"] = function ()
    local map = Map.read()
    local laser_map = Map.new_fill(map:size(), function () return {} end)
    map:print(table.concat)
    -- print()
    -- laser_map:print(format)
    -- laser_map:set({x=1, y=1}, "-")

    local lasers = {{pos={x=1, y=1}, dir="e"}}
    while next(lasers) do
        trace(table.remove(lasers), lasers, map, laser_map)
        -- print("next Split")
    end

    print()
    laser_map:print(format)
    return count_beam(laser_map)
end

run["2"] = function ()
    local map = Map.read()
    
    -- map:print(table.concat)
    -- print()
    -- laser_map:print(format)
    -- laser_map:set({x=1, y=1}, "-")

    local max = 0
    for _, val in pairs({{y=1, d="s"}, {y=map:num_rows(), d="n"}}) do
        for x = 1, map:num_columns() do
            local laser_map = Map.new_fill(map:size(), function() return {} end)
            local lasers = {{pos={x=x, y=val.y}, dir=val.d}}
            while next(lasers) do
                trace(table.remove(lasers), lasers, map, laser_map)
                -- print("next Split")
            end
            local new = count_beam(laser_map)
            print(new)
            if max < new then max = new end
        end
    end

    for _, val in pairs({{x=1, d="e"}, {x=map:num_columns(), d="w"}}) do
        for y = 1, map:num_rows() do
            local laser_map = Map.new_fill(map:size(), function () return {} end)
            local lasers = {{pos={x=val.x, y=y}, dir=val.d}}
            while next(lasers) do
                trace(table.remove(lasers), lasers, map, laser_map)
                -- print("next Split")
            end
            local new = count_beam(laser_map)
            print(new)
            if max < new then max = new end
        end
    end
    
    -- print()
    -- laser_map:print(format)
    return max
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())