require("shared")

local run = {}

local function gen_map()
    local map = {}
    ForEachLineBreak("^$", function (line)
        local row = {}
        for value in line:gmatch(".") do
            table.insert(row, value)
        end
        table.insert(map, row)
    end)
    if next(map) then return map end
end

local function match(iter1, iter2)
    for x, y in Iters.zip(iter1, iter2) do
        if x ~= y then return false end
    end
    return true
end

local function find_symmetry(map, size, iter)
    
    for i in Iters.zig(size) do
        local x, y = i, i + 1
        local pass = true
        -- print("start")
        while x > 0 and y <= size + 1 do
            -- print("checking:" .. x .. " and " .. y)
            if not match(iter(map, x), iter(map, y)) then
                pass = false
                break
            end

            x = x - 1
            y = y + 1
        end

        if pass then return i end
    end
end

run["1"] = function ()
    local total = 0
    for map in gen_map do
        -- table.print_2d(map)
        
        local column = find_symmetry(map, #map[1] - 1, table.column)
        if column then
            total = total + column
        else
            local row = find_symmetry(map, #map - 1, table.row)

            if row then
                total = total + (100 * row)
            end
        end
    end

    return total
end

local function match2(iter1, iter2)
    local error = 0
    for x, y in Iters.zip(iter1, iter2) do
        if x ~= y then error = error + 1 end
    end
    return error
end

local function find_symmetry2(map, size, iter)
    
    for i in Iters.zig(size) do
        local x, y = i, i + 1
        local error = 0
        -- print("start")
        while x > 0 and y <= size + 1 do
            error = error + match2(iter(map, x), iter(map, y))
            -- print("checking:" .. x .. " and " .. y .. " error " .. error)
            if error > 1 then
                break
            end

            x = x - 1
            y = y + 1
        end

        if error == 1 then return i end
    end
end

run["2"] = function ()
    local total = 0
    for map in gen_map do
        -- table.print_2d(map)
        
        -- print("C")
        local column = find_symmetry2(map, #map[1] - 1, table.column)
        if column then
            total = total + column
        else
            -- print("R")
            local row = find_symmetry2(map, #map - 1, table.row)

            if row then
                total = total + (100 * row)
            end
        end
    end

    return total
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())