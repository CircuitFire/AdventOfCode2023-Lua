require("shared")

local run = {}

local function get_blocks()
    local blocks = {}
    local max_x = 0
    local max_y = 0

    ForEachLine(function (line)
        local _, _, x1, y1, z1, x2, y2, z2 = line:find("(%d*),(%d*),(%d*)~(%d*),(%d*),(%d*)")
        local block = {
            holding = {}, 
            held_by = {}, 
            {x=tonumber(x1 + 1), y=tonumber(y1 + 1), z=tonumber(z1)},
            {x=tonumber(x2 + 1), y=tonumber(y2 + 1), z=tonumber(z2)}
        }

        table.sort(block, function (a, b)
            if a.x ~= b.x then return a.x < b.x end
            if a.y ~= b.y then return a.y < b.y end
            return a.z < b.z
        end)

        if block[2].x > max_x then max_x = block[2].x end
        if block[2].y > max_x then max_y = block[2].y end

        table.insert(blocks, block)
    end)

    table.sort(blocks, function (a, b)
        return a[1].z < b[1].z
    end)

    return blocks, {x=max_x, y=max_y}
end

local function shift_y(block, amount)
    block[1].z = block[1].z + amount
    block[2].z = block[2].z + amount
end

local function collision(a, b)
    return not ((a[1].x > b[2].x or a[2].x < b[1].x) or (a[1].y > b[2].y or a[2].y < b[1].y))
end

local function settle(blocks)
    local i = 1
    while i <= #blocks do -- block getting shifted
        local j = i - 1
        local move_to = 1
        -- print("moving : " .. serpent.line2(serpent.line2(blocks[i])))
        while j >= 1 do -- blocks underneath
            if collision(blocks[i], blocks[j]) then
                if blocks[j][2].z + 1 > move_to then
                    move_to = blocks[j][2].z + 1
                end
                -- print("collides with #" .. serpent.line2(blocks[j]))
                -- break
            end

            j = j - 1
        end
        -- print("moving #" .. i .. " to #" .. move_to)
        shift_y(blocks[i], move_to - blocks[i][1].z)

        i = i + 1
    end
end

local function check_collisions(blocks)
    local i = 1
    while i <= #blocks do
        local j = 1
        while j <= #blocks do
            if (blocks[j][1].z == blocks[i][2].z + 1) and collision(blocks[i], blocks[j]) then
                blocks[i].holding[j] = true
                blocks[j].held_by[i] = true
            end

            j = j + 1
        end

        i = i + 1
    end
end

local function only_support(blocks, block)
    for key, value in pairs(block.holding) do
        local t = blocks[key].held_by
        if not next(t, next(t)) then return true end
    end
    return false
end

local function print_blocks(blocks, size)
    print("max size: x: " .. size.x .. " y: " .. size.y)
    local max_z = 0
    for key, block in pairs(blocks) do
        if block[2].z > max_z then max_z = block[2].z end
    end

    local map = {}
    for z = 1, max_z do
        map[z] = Map.new_fill(size, function ()
            return "(    )"
        end)
    end

    for i, block in pairs(blocks) do
        for z = block[1].z, block[2].z do
            for y = block[1].y, block[2].y do
                for x = block[1].x, block[2].x do
                    map[z][y][x] = string.format("(%4d)", i)
                end
            end
        end
    end

    for z, layer in ipairs(map) do
        print("layer: " .. z)
        layer:print(table.concat)
        print()
    end
end

run["1"] = function ()
    local blocks, size = get_blocks()
    -- print_blocks(blocks, size)
    settle(blocks)
    check_collisions(blocks)
    -- print(serpent.block2(blocks))
    -- print_blocks(blocks, size)

    local count = 0
    for i, block in ipairs(blocks) do
        if not only_support(blocks, block) then
            -- print("removed: #" .. i .. " (" .. block[1].x-1 .. ", " .. block[1].y-1 .. ", " .. block[1].z .. ") -> (" .. block[2].x-1 .. ", " .. block[2].y-1 .. ", " .. block[2].z .. ")")
            count = count + 1
        end
    end

    return count
end

local function all_supports_removed(removed, block)
    for key, value in pairs(block.held_by) do
        if not removed[key] then return false end
    end
    return true
end

local function get_effected(effected, removed, blocks, block)
    for key, value in pairs(block.holding) do
        if all_supports_removed(removed, blocks[key]) then
            removed[key] = true
            effected[key] = true
            get_effected(effected, removed, blocks, blocks[key])
        end
    end
end

run["2"] = function ()
    local blocks, size = get_blocks()
    -- print_blocks(blocks, size)
    settle(blocks)
    check_collisions(blocks)
    -- print(serpent.block2(blocks))
    -- print_blocks(blocks, size)

    local count = 0
    for i, block in ipairs(blocks) do
        if only_support(blocks, block) then
            local effected = {}
            local removed = {}
            removed[i] = true
            get_effected(effected, removed, blocks, block)
            -- print(i .. ": " .. serpent.line2(effected))
            count = count + table.count(effected)
        end
    end

    return count
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())