require("shared")

local run = {}

local function get_connections()
    local connections = {}

    ForEachLine(function (line)
        -- print(line)
        local _, _, front, back = line:find("(%a*): (.*)")
        -- print(front, back)
        if not connections[front] then
            connections[front] = {}
        end
        
        for chunk in back:gmatch("%a*") do
            if not connections[chunk] then
                connections[chunk] = {}
            end

            connections[front][chunk] = 0
            connections[chunk][front] = 0
        end
    end)

    return connections
end

local function find_loop(connections, target, check)
    local visited = {}
    while next(check) do
        -- print(serpent.line2(check))
        local x = table.remove(check, 1)
        -- print(serpent.line2(x))

        for nex, value in pairs(connections[x.current]) do
            if nex ~= x.from and not visited[nex] then
                visited[nex] = true
                -- print(x.current, nex, x.depth)
                if nex == target then return x.depth end
                table.insert(check, {from=x.current, current=nex, depth=x.depth + 1})
            end
        end
    end
end

local function loop_distance(connections)
    local distance = {}

    for parent, value in pairs(connections) do
        for child, _ in pairs(value) do
            table.insert(
                distance,
                {
                    from=parent,
                    to=child,
                    distance=find_loop(connections, parent, {{from=parent, current=child, depth=1}})
                }
            )
        end
    end

    table.sort(distance, function (a, b)
        return a.distance > b.distance
    end)
    return distance
end

local function all_connected(connections, list, at)
    if list[at] then return end
    list[at] = true

    for key, value in pairs(connections[at]) do
        all_connected(connections, list, key)
    end
end

run["1"] = function ()
    local connections = get_connections()
    -- print(serpent.block2(connections))
    -- find_loop(connections, "fqn", {{from="fqn", current="dgc", depth=1}})
    -- find_loop(connections, "dgc", {{from="dgc", current="fqn", depth=1}})
    -- os.exit(1)
    local distance = loop_distance(connections)
    -- for index, value in ipairs(distance) do
    --     print(serpent.line2(value))
    -- end
    for i=1, 6 do
        local t = distance[i]
        connections[t.from][t.to] = nil
    end

    local list = {}
    all_connected(connections, list, distance[1].from)
    local a = table.count(list)
    list = {}
    all_connected(connections, list, distance[1].to)
    local b = table.count(list)

    print(a, b)
    return a * b
end

run["2"] = function ()

end

-- print("Enter Input:")
print(run[arg[1] or "1"]())