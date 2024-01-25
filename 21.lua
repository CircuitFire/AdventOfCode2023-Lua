require("shared")
require("range_map")

local run = {}

function display(line)
    local out = ""
    for key, value in pairs(line) do
        if value == "." then
            value = " ."
        else
            -- value = value % 2
            value = string.format("%2d", value)
        end
        out = out .. value
    end
    return out
end

local function spread(map, extra, pos, count)
    -- print(count)
    if count == 0 then return end
    
    for key, value in pairs(Map.Dir) do
        local next_pos = table.add_coords(pos, value)
        local at1, at2 = map:get(next_pos), extra:get(next_pos)
        -- print(key)

        if at1 == "." and (at2 == "." or at2 < count) then
            extra:set(next_pos, count)
            -- print(serpent.block2(extra))
            -- extra:print(display)
            spread(map, extra, next_pos, count - 1)
        end
    end
end

local function count_positions(extra)
    local count = 0
    for y, row in pairs(extra) do
        for x, value in pairs(row) do
            if value ~= "." and value % 2 == 1 then
                count = count + 1
            end
        end
    end
    return count
end

run["1"] = function ()
    local map = Map:read()
    map:print(table.concat)
    local extra = Map.new_fill(map:size(), function ()
        return "."
    end)

    local start = table.map(map:size(), function (value)
        return math.ceil(value/2)
    end)
    
    spread(map, extra, start, 64)

    print()
    extra:print(display)

    return count_positions(extra)
end

local function count_positions2(extra)
    local counts = {[true] = 0, [false] = 0}
    for y, row in pairs(extra) do
        for x, value in pairs(row) do
            if value ~= "." then
                local i = value % 2 == 1
                counts[i] = counts[i] + 1
            end
        end
    end
    return counts
end

local function hash_pos(pos)
    return pos.y .. "," .. pos.x
end

local function remove(table)
    local k, v = next(table)
    if not k then return end
    table[k] = nil
    return v
end

local function spread2(map, extra, inputs)
    local next_round = table.remove(inputs)
    local addition = table.remove(inputs)

    local count = next_round.count
    next_round = {[hash_pos(next_round.pos)] = next_round.pos}

    while next(next_round) and count > 0 do
        while addition and addition.count == count do
            if extra:get(addition.pos) == "." then
                next_round[hash_pos(addition.pos)] = addition.pos
            end
            addition = table.remove(inputs)
        end
        

        local current_list = next_round
        -- print(serpent.line2(current_list))
        next_round = {}
        local current = remove(current_list)
        -- print(serpent.line2(current))

        while current do
            extra:set(current, count)

            for key, value in pairs(Map.Dir) do
                local next_pos = table.add_coords(current, value)
                local at1, at2 = map:get(next_pos), extra:get(next_pos)
                
                if (at1 == "." or at1 == "S") and (at2 == "." or at2 < count) then
                    -- print(key)
                    next_round[hash_pos(next_pos)] = next_pos
                end
            end

            current = remove(current_list)
        end
        count = count - 1

    end
end

local function exits(extra, sides)
    local out = {n={},s={},w={},e={}}

    local Sides = {
        n = {extra.in_row, 1, "y", extra:num_rows()},
        s = {extra.in_row, extra:num_rows(), "y", 1},
        w = {extra.in_column, 1, "x", extra:num_columns()},
        e = {extra.in_column, extra:num_columns(), "x", 1},
    }

    for _, value in pairs(sides) do
        Sides[value] = nil
    end

    for key, side in pairs(Sides) do
        for pos, value in side[1](extra, side[2]) do
            if value ~= "." and value > 1 then
                pos[side[3]] = side[4]
                table.insert(out[key], {pos = pos, count = value - 1})
            end
        end
    end
    for key, value in pairs({"n", "s", "e", "w"}) do
        if not next(out[value]) then out[value] = nil end
    end

    -- print(serpent.line2(out))
    return out
end

local function max(inputs)
    local max = 0
    for key, value in pairs(inputs) do
        -- print("value " .. serpent.line2(value))
        if value.count > max then max = value.count end
    end
    -- print("max_input " .. max_input)
    return max
end

local function min(inputs)
    local min = math.huge
    for i, value in pairs(inputs) do
        if value.count < min then min = value.count end
    end
    return min
end

local function find_in_saw_teeth(inputs)
    local min = min(inputs)
    local t = {}

    for key, value in pairs(inputs) do
        table.insert(t, {pos=value.pos, count = value.count - min})
    end

    return t, min
end



local function hash_saw_teeth(inputs)
    local min = min(inputs)

    local out = ""
    for key, value in pairs(inputs) do
        out = out .. hash_pos(value.pos) .. "=" .. value.count - min .. ":"
    end

    return out
end

local function flatten_outs(outs)
    local t = {}
    for side, list in pairs(outs) do
        for _, value in pairs(list) do
            table.insert(t, value)
        end
    end
    return t
end

local function find_out_saw_teeth(outs)
    local min = min(flatten_outs(outs))
    local t = {}

    for side, list in pairs(outs) do
        t[side] = {}
        for _, value in pairs(list) do
            table.insert(t[side], {pos=value.pos, count = value.count - min})
        end
    end

    return t, min
end

local function gen_new_out(saw_teeth, offset)
    local t = {}
    for _, value in pairs(saw_teeth) do
        table.insert(t, {pos=value.pos, count = value.count + offset})
    end
    return t
end

local function scan_map2(map, extended_extra, extended_map, at, read_from)
    local inputs = {}
    for key, value in pairs(read_from) do
        local out = extended_map:get(table.add_coords(at, Map.Dir[value]))
        if out then
            -- print(serpent.line2(table.add_coords(at, Map.Dir[value])) .. " = " .. out.offset)
            local data = extended_extra[out.hash]
            if data and data.teeth[Map.Op[value]] then
                for _, val in pairs(gen_new_out(data.teeth[Map.Op[value]], out.offset)) do
                    table.insert(inputs, val)
                end
            end
        end
    end
    
    if #inputs == 0 then return end

    local input_saw_teeth, input_offset = find_in_saw_teeth(inputs)
    -- local i = 1
    
    local hash = hash_saw_teeth(input_saw_teeth)
    -- local hash = math.random (1000000000)
    -- print(hash)
    if extended_extra[hash] then
        local t = extended_extra[hash]
        -- print("doop, " .. input_offset .. "<" .. t.req .. " " .. serpent.line2(t.tiles))
        if input_offset < t.req then
            -- print("missed")
            hash = hash .. input_offset
            local t = extended_extra[hash]
            if t then
                -- print("alt match " .. serpent.line2(t.tiles))
                local i = input_offset % 2 == t.shift
                t.repeats[i] = t.repeats[i] + 1
                -- table.insert(t.tiles, {at, i})
                -- t.out = gen_new_out(t.teeth, input_offset - t.req)
                return hash, input_offset - t.req
            end
        else
            -- print("jumping")
            local i = input_offset % 2 == t.shift
            t.repeats[i] = t.repeats[i] + 1
            --table.insert(t.tiles, {at, i})
            -- t.out = gen_new_out(t.teeth, input_offset - t.req)
            return hash, input_offset - t.req
            
            -- expected = gen_new_out(t.teeth, input_offset - t.req)
            -- r = t.repeats
        end
    end
    
    local extra = Map.new_fill(map:size(), function ()
        return "."
    end)
    
    table.sort(inputs, function (a, b)
        return a.count < b.count
    end)
    spread2(map, extra, inputs)
    -- extra:print(display)
    -- print()
    local count = count_positions2(extra)
    local out = exits(extra, read_from)
    local out_saw_teeth, out_offset = find_out_saw_teeth(out)
    -- if expected then
    --     print("expected:")
    --     for key, value in pairs({"n","s","e","w"}) do
    --         print(value .. ": " .. serpent.line2(expected[value]))
    --     end
    --     print("out:")
    --     for key, value in pairs({"n","s","e","w"}) do
    --         print(value .. ": " .. serpent.line2(out[value]))
    --     end
    -- end

    local repeats = {[true] = 1, [false] = 0}
    local i = input_offset % 2
    -- local repeats = {[0] = 0, 0}
    -- repeats[i] = repeats[i] + 1
    
    extended_extra[hash] = {shift = i, count = count, req = input_offset-out_offset, teeth=out_saw_teeth, repeats = repeats, --[[tiles = {{at, true}}]]}
    -- print(count .. " " .. extended_extra[hash].req .. " " .. extended_extra[hash].repeats )
    return hash, out_offset
end

local function scan_map(map, extended_extra, inputs, sides)
    
    local r
    local input_saw_teeth, input_offset = find_in_saw_teeth(inputs)
    local hash = hash_saw_teeth(input_saw_teeth)
    print(hash)
    -- local expected
    -- if extended_extra[hash] then
    --     local t = extended_extra[hash]
    --     print("doop_input, " .. input_offset .. "<" .. t.req)
    --     if input_offset < t.req then
    --         print("missed")
    --         hash = hash .. input_offset
    --     else
    --         print("jumping")
    --         t.repeats = t.repeats + 1
    --         t.out = gen_new_out(t.teeth, input_offset - t.req)
    --         return hash 
            
    --         -- expected = gen_new_out(t.teeth, input_offset - t.req)
    --         -- r = t.repeats
    --     end
    -- end
    
    local extra = Map.new_fill(map:size(), function ()
        return "."
    end)
    
    local max_in = max(inputs)
    table.sort(inputs, function (a, b)
        return a.count < b.count
    end)
    spread2(map, extra, inputs)
    print()
    extra:print(display)
    local count = count_positions2(extra)
    local out = exits(extra, sides)
    local out_saw_teeth, out_offset = find_out_saw_teeth(out)
    -- if expected then
    --     print("expected:")
    --     for key, value in pairs({"n","s","e","w"}) do
    --         print(value .. ": " .. serpent.line2(expected[value]))
    --     end
    --     print("out:")
    --     for key, value in pairs({"n","s","e","w"}) do
    --         print(value .. ": " .. serpent.line2(out[value]))
    --     end
    -- end
    local repeats = {[true] = 1, [false] = 0}
    local i = input_offset % 2
    -- repeats[i] = repeats[i] + 1

    extended_extra[hash] = {shift = i, count = count, req = input_offset-out_offset, teeth=out_saw_teeth, repeats = repeats, --[[tiles = {{{x=0,y=0}, true}}]]}
    -- print(count .. " " .. extended_extra[hash].req .. " " .. extended_extra[hash].repeats )
    return hash, out_offset
end

local function get_inputs(extended_map, extended_extra, pos, side)
    local input = extended_map:get(pos)
    
    if input then
        input = extended_extra[input]
        return input and input.out[side]
    end
end

local function fast_skip(extended_map, extended_extra, last2, pos, dir)
    local hash = extended_map:get(last2[2]).hash
    local cur_data = extended_map:get(last2[1])
    
    if hash == cur_data.hash then
        local data = extended_extra[hash]
        local req = data.req
        local offset = cur_data.offset
        
        -- local test = {[true] = 0, [false] = 0}
        -- local debug = pos
        if offset >= req then
            -- print("fast_skipping " .. serpent.line2(pos))
            local i = offset % 2 == data.shift
            local repeats = offset // req

            -- if req % 2 == 1 then
            --     test[i] = test[i] + math.ceil(repeats / 2)
            --     i = not i
            --     test[i] = test[i] + math.floor(repeats / 2)
            -- else
            --     test[i] = test[i] + repeats
            -- end
            
            if req % 2 == 1 then
                data.repeats[i] = data.repeats[i] + math.ceil(repeats / 2)
                i = not i
                data.repeats[i] = data.repeats[i] + math.floor(repeats / 2)
            else
                data.repeats[i] = data.repeats[i] + repeats
            end
            
            -- data.repeats[i] = data.repeats[i] + 1
            -- table.insert(data.tiles, {pos, i})
            to = table.add_coords(pos, table.mul_coords(dir, {x=repeats - 1, y=repeats - 1,}))
            -- print(serpent.line2(pos) .. "->" .. serpent.line2(to))
            extended_map:set(pos, {hash=hash, offset=offset - req}, {pos=to, change=req})
            pos = table.add_coords(to, dir)
            
            -- print("test: out pos: " .. serpent.line2(pos) .. " counts " .. serpent.line2(test))
            -- while not table.coord_eq(debug, table.add_coords(table.add_coords(to, dir), dir)) do
            --     print(serpent.line2(debug) .. " " .. serpent.line2(extended_map:get(debug)))
            --     debug = table.add_coords(debug, dir)
            -- end
        end

        -- local count = {[true] = 0, [false] = 0}
        -- pos = debug
        -- while offset >= req do
        --     -- print("fast_skipping " .. serpent.line2(pos))
        --     local i = offset % 2 == data.shift
        --     offset = offset - req
        --     count[i] = count[i] + 1
        --     -- data.repeats[i] = data.repeats[i] + 1
        --     -- table.insert(data.tiles, {pos, i})
        --     -- extended_map:set(pos, {hash=hash, offset=offset})
        --     -- print("test: " .. serpent.line2(pos) .. " " .. serpent.line2(extended_map:get(pos)))
        --     -- print("real: " .. serpent.line2(pos) .. " " .. serpent.line2({hash=hash, offset=offset}))
        --     pos = table.add_coords(pos, dir)
        --     -- break
        -- end
        -- print("real: out pos: " .. serpent.line2(pos) .. " counts " .. serpent.line2(count))
    end

    return pos
end

local function scan_in_lines(map, extended_map, extended_extra)
    local start = {x=0,y=0}
    
    for key, value in pairs(Map.Dir) do
        local pos = start
        local last2 = {}
        while true do
            pos = table.add_coords(pos, value)
            -- print(serpent.line2(pos))
            
            if #last2 == 2 then
                -- local temp = pos
                pos = fast_skip(extended_map, extended_extra, last2, pos, value)
                -- print("out pos: " .. serpent.line2(pos))
                -- pos = temp
            end

            local hash, offset = scan_map2(map, extended_extra, extended_map, pos, {Map.Op[key]})
            if not hash then break end
            -- print(serpent.line2(pos) .. " " .. hash .. " " .. offset)
            extended_map:set(pos, {hash=hash, offset=offset})

            table.insert(last2, 1, pos)
            if #last2 > 2 then
                table.remove(last2)
            end
        end
    end
end

local function fast_skip2(extended_map, extended_extra, last2, pos, dir, check_dir)
    local cur_data = extended_map:get(last2[1])
    local hash = extended_map:get(last2[2]).hash
    -- print("cur_under_hash: " .. serpent.line2(table.add_coords(last2[1], check_dir)) .. " = " .. serpent.line2(extended_map:get(table.add_coords(last2[1], check_dir))))
    local cur_under_hash = extended_map:get(table.add_coords(last2[1], check_dir)).hash
    local last_under_hash = extended_map:get(table.add_coords(last2[2], check_dir)).hash
    
    if (hash == cur_data.hash) and (last_under_hash == cur_under_hash) then
        local data = extended_extra[hash]
        local req = data.req
        local offset = cur_data.offset
        local under = extended_map:get(table.add_coords(pos, check_dir))
        -- print(serpent.line2(under))

        if offset >= req and cur_under_hash == under.hash then
            local i = offset % 2 == data.shift
            local repeats = offset // req
            local range = under.range or 1
            if range < repeats then
                repeats = range
            end
            -- print(repeats)
            
            if req % 2 == 1 then
                data.repeats[i] = data.repeats[i] + math.ceil(repeats / 2)
                i = not i
                data.repeats[i] = data.repeats[i] + math.floor(repeats / 2)
            else
                data.repeats[i] = data.repeats[i] + repeats
            end
            
            to = table.add_coords(pos, table.mul_coords(dir, {x=repeats - 1, y=repeats - 1,}))
            extended_map:set(pos, {hash=hash, offset=offset - req}, {pos=to, change=req})
            pos = table.add_coords(to, dir)
        end

        -- while offset >= req and cur_under_hash == extended_map:get(table.add_coords(pos, check_dir)).hash do
        --     -- print("fast_skipping " .. serpent.line2(pos))
        --     local i = offset % 2 == data.shift
        --     offset = offset - req
        --     data.repeats[i] = data.repeats[i] + 1
        --     -- table.insert(data.tiles, {pos, i})
        --     extended_map:set(pos, {hash=hash, offset=offset})
        --     pos = table.add_coords(pos, dir)
        --     -- break
        -- end
    end

    return pos
end

local function scan_in_diagonals(map, extended_map, extended_extra)
    -- print("scan_in_diagonals")
    local start = {x=0,y=0}
    
    for _, vertical in pairs({"n", "s"}) do
        local v_dir = Map.Dir[vertical]
        local op_v_dir = Map.Dir[Map.Op[vertical]]

        local row = table.add_coords(start, v_dir)
        while extended_map:get(row) do
            for _, horizontal in pairs({"e", "w"}) do
                local h_dir = Map.Dir[horizontal]
    
                local pos = row
                local last2 = {}
                while true do
                    pos = table.add_coords(pos, h_dir)
                    -- print(serpent.line2(pos))

                    if #last2 == 2 then
                        -- local temp = pos
                        pos = fast_skip2(extended_map, extended_extra, last2, pos, h_dir, op_v_dir)
                        -- pos = temp
                    end
            
                    local hash, offset = scan_map2(map, extended_extra, extended_map, pos, {Map.Op[vertical], Map.Op[horizontal]})
                    local test = extended_map:get(pos)
                    if not hash then break end
                    if test then
                        print(test.offset .. " " .. offset)
                    end
                    extended_map:set(pos, {hash=hash, offset=offset})

                    table.insert(last2, 1, pos)
                    if #last2 > 2 then
                        table.remove(last2)
                    end
                end
                -- print("finished: " .. horizontal)
            end
            -- print("current_row: " .. serpent.line2(row))
            local prev_2 = table.sub_coords(row, v_dir)
            -- print("last_row: " .. serpent.line2(prev_2))
            if prev_2.y ~= 0 then
                extended_map:clear(prev_2.y)
            end

            row = table.add_coords(row, v_dir)
            if row.y % 100 == 0 then
                print("finished: " .. row.y)
            end
        end
    end
end

run["2"] = function ()
    local map = Map:read()
    map:print(table.concat)
    local extended_map = RangeMap.new()--Map.new()
    local extended_extra = {}
    

    local start = table.map(map:size(), function (value)
        return math.ceil(value/2)
    end)
    
    local steps = 26501365
    local hash, offset = scan_map(map, extended_extra, {{pos = start, count = steps + 1}}, {})
    extended_map:set({x=0,y=0}, {hash=hash, offset=offset})
    
    -- print(serpent.block2(extended_map))
    scan_in_lines(map, extended_map, extended_extra)
    scan_in_diagonals(map, extended_map, extended_extra)
    
    local count = 0
    -- print("end")
    -- local t = {}
    for key, value in pairs(extended_extra) do
        -- print(serpent.block2(value))
        -- print(value.count .. " " .. value.repeats)
        -- print(serpent.line2(value.count) .. " " .. serpent.line2(value.tiles))
        -- for key, val in pairs(value.tiles) do
        --     table.insert(t, {pos=val[1], count=value.count, chose=val[2]})
        -- end
        count = count + (value.count[true] * value.repeats[true]) + (value.count[false] * value.repeats[false])
    end

    -- table.sort(t, function (a, b)
    --     if a.pos.y == b.pos.y then
    --         return  a.pos.x < b.pos.x
    --     end
    --     return a.pos.y < b.pos.y
    -- end)
    -- for key, value in pairs(t) do
    --     print("y:" .. value.pos.y .. " x:" .. value.pos.x  .. " = " .. serpent.line2(value.count) .. ": " .. tostring(value.chose))
    -- end

    return count
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())