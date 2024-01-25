require("shared")

local run = {}

local function get_map()
    local map = Map.new()
    ForEachLine(function (line)
        local row = {}
        for value in line:gmatch(".") do
            table.insert(row, value)
        end
        table.insert(map, row)
    end)

    return map
end

local function get_move(t)
    local x, y = t(), t()
    return table.sub_coords(y, x)
end

local function shift(map, len, iter, reverse)
    local n = get_move(iter(map, 1, reverse))
    for i = 1, len do
        local free
        for pos, value in iter(map, i, reverse) do
            if value == "." and not free then
                free = pos
            elseif value == "#" then
                free = nil
            elseif value == "O" and free then
                map:set(free, "O")
                map:set(pos, ".")
                free = table.add_coords(free, n)
            end
        end
    end
end

local function measure_load(map)
    local total = 0
    local rows = map:num_rows()
    for i = rows, 1, -1 do
        for pos, value in map:in_row(i) do
            if value == "O" then
                total = total + (rows - i + 1)
            end
        end
    end
    return total
end

run["1"] = function ()
    local map = get_map()
    -- map:print()
    shift(map, map:num_columns(), map.in_column)
    -- print()
    -- map:print()
    return measure_load(map)
end

local function hash(map)
    local columns = map:num_columns()
    local sum = ""
    for i = 1, map:num_rows() do
        local line = 0
        for pos, value in map:in_row(i) do
            if value == "O" then
                line = line + (2 ^ (pos.x-1))
            end
        end
        sum = sum .. Coding.code(line, 64)
    end
    return sum
end

local function cycle(map)
    shift(map, map:num_columns(), map.in_column)
    shift(map, map:num_rows(), map.in_row)
    shift(map, map:num_columns(), map.in_column, true)
    shift(map, map:num_rows(), map.in_row, true)
end

run["2"] = function ()
    local map = get_map()

    local memory = {}
    local max = 1000000000
    local at, old
    for i = 1, max do
        cycle(map)
        local hash = hash(map)
        -- print("\n" .. i .. " = " .. hash)
        -- map:print()
        if memory[hash] then
            print(memory[hash] .. " = " .. i)
            old, at = memory[hash], i
            break
        else
            memory[hash] = i
        end
    end

    local max = math.fmod(max - at, at - old)
    print("new max: " .. max)
    for i = 1, max do
        cycle(map)
    end
    
    return measure_load(map)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())