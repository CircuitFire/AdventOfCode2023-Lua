require("shared")

local run = {}

local Into = {
    U = "n",
    D = "s",
    R = "e",
    L = "w",
}

local function gen_map()
    
    local pos = {x=1, y=1}
    local offset = {x=0, y=0}
    local temp = {}
    ForEachLine(function (line)
        local _, _, d, x, r, g, b = line:find("(.) (%d*) %(#(..)(..)(..)%)")
        d = Map.Dir[Into[d]]
        for i = 1, tonumber(x) do
            pos = table.add_coords(pos, d)
            for key, value in pairs(pos) do
                if value + offset[key] < 1 then
                    offset[key] = (value - 1) * -1
                end
            end
            
            table.insert(temp, {pos=pos, c={r=r,g=g,b=b}})
        end
    end)

    local map = Map.new()
    map:set(table.add_coords({x=1, y=1}, offset), {d="#"})
    for _, value in pairs(temp) do
        map:set(table.add_coords(value.pos, offset), {d="#", c=value.c})
    end

    print("offset: " .. serpent.line2(offset))
    return map, table.add_coords(offset, {x=2, y=2})
end

local function fill_empty(map)
    for y, row in pairs(map) do
        local biggest = 0
        for x, value in pairs(row) do
            if x > biggest then
                biggest = x
            end
        end
        for i = 1, biggest do
            if not row[i] then
                local a, b = map:get({y=y-1,x=i}), map:get({y=y,x=i-1})
                -- if a and b and a.d == "#" and b.d == "#" then
                --     row[i] = {d="#"}
                -- else
                    row[i] = {d="."}
                -- end
            end
        end
    end
end

local function count_mined(map)
    local total = 0
    for y, row in pairs(map) do
        local count = 0
        local last = nil
        local pit = false
        for x, value in pairs(row) do
            if value.d == "#" then
                count = count + 1
            --     if last ~= value.d then
            --         pit = not pit
            --     end
            -- elseif pit then
            --     count = count + 1
            end
            -- last = value.d
        end
        -- print(display(row) .. " " .. count)
        total = total + count
    end
    return total
end

function display(line)
    local out = ""
    local count = 1
    for key, value in pairs(line) do
        if key > count then
            out = out .. string.rep(" ", key - count)
            count = key
        end
        out = out .. value.d
        count = count + 1
    end
    return out
end

function flood(map, start)
    map:set(start, {d="#"})

    for key, value in pairs(Map.Dir) do
        local new = table.add_coords(start, value)
        local x = map:get(new)
        if not x then print(serpent.line2(new)) end
        if x.d == "." then
            flood(map, new)
        end
    end
end

run["1"] = function ()
    local map, inner = gen_map()
    fill_empty(map)
    map:print(display)
    flood(map, inner)
    map:print(display)
    -- map:print(serpent.line2)
    return count_mined(map)
end

local Into2 = {
    ["3"] = "n",
    ["1"] = "s",
    ["0"] = "e",
    ["2"] = "w",
}

local function point_list()
    local pos = {x=0, y=0}
    local list = {{x=0, y=0}}
    local lines = 0
    ForEachLine(function (line)
        local _, _, x, d = line:find(". %d* %(#(.*)(.)%)")
        d = Into2[d]
        x = tonumber(x, 16)
        lines = lines + x
        -- print(d .. " " .. x)
        d = table.mul_coords(Map.Dir[d], {x=x, y=x})
        pos = table.add_coords(pos, d)
        table.insert(list, pos)
    end)

    list.lines = lines
    return list
end

local function area(list)
    local total = 0
    for i = 1, #list - 1 do
        local a, b = list[i], list[i+1]
        total = total + ((a.x * b.y) - (a.y * b.x))
    end
    return math.abs(total / 2) + list.lines/2 + 1
end

run["2"] = function ()
    local list = point_list()
    table.print_2d(list)
    -- print(area{{x=0,y=0},{x=5,y=9},{x=9,y=3},{x=6,y=0},{x=0,y=0}})
    return area(list)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())