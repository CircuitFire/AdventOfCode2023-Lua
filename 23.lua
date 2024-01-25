require("shared")

local run = {}

local function valid_directions(map, pos, from)
    local paths, exits = 0, 0
    local nex, dir
    for key, value in pairs(Map.Dir) do
        if Map.Op[from] ~= key then
            local p = table.add_coords(pos, value)
            local n = map:get(p)
            if n and n ~= "#" and n ~= "," then
                paths = paths + 1
                if n ~= Map.Dir_Arrows[Map.Op[key]] then
                    nex = p
                    dir = key
                    exits = exits + 1
                end
            end
        end
    end
    return paths > 1, exits, nex, dir
end

local function crawl(map, nodes, start)
    local len = 0
    local one_way = false
    -- print("crawling: " .. serpent.line2(start))
    local _, _, at, dir = valid_directions(map, start)
    local intersection, exits, nex

    while true do
        -- print("crawling: " .. serpent.line2(at))
        intersection, exits, nex, dir = valid_directions(map, at, dir)
        -- print(serpent.line2(at) .. ": " .. dir .. ": " .. serpent.line2(nex))
        len = len + 1

        if intersection or nodes[table.hash_pos(at)] then -- at cross
            map:set(at, "x")
            return at, len, one_way, exits
        elseif exits == 1 then --on path
            if map:get(at) == Map.Dir_Arrows[dir] then one_way = true end
            map:set(at, ",")
            at = nex
        else -- dead end
            map:set(at, "d")
            return at, len, one_way
        end
    end
end

local function add_node(nodes, from, to, len, one_way)
    if not nodes[to] then nodes[to] = {} end

    nodes[from][to] = len
    if not one_way then
        nodes[to][from] = len
    end
end

local function get_graph()
    local map = Map.read()
    -- map:print(table.concat)
    local start = {x=2, y=1}
    local stop = table.sub_coords(map:size(), {x=1, y=0})

    local branches = {[table.hash_pos(start)] = {pos=start, branches=1}}
    local nodes = {[table.hash_pos(start)] = {}}

    local branch, pos_hash = table.map_remove(branches)
    while branch do
        while branch.branches > 0 do
            local at, len, one_way, directions = crawl(map, nodes, branch.pos)
            add_node(nodes, pos_hash, table.hash_pos(at), len, one_way)
            if directions and directions > 0 then
                branches[table.hash_pos(at)] = {pos=at, branches=directions}
            end
            branch.branches = branch.branches - 1
        end
        
        branch, pos_hash = table.map_remove(branches)
    end

    map:print(table.concat)
    return {start=table.hash_pos(start), stop=table.hash_pos(stop), nodes=nodes}
end

local function find_paths(graph, current, count, traversed, paths)
    if current == graph.stop then
        table.insert(paths, count)
    end

    traversed[current] = true
    for key, value in pairs(graph.nodes[current]) do
        if not traversed[key] then
            find_paths(graph, key, count + value, traversed, paths)
        end
    end
    traversed[current] = nil
end

run["1"] = function ()
    local graph = get_graph()
    -- print(serpent.block2(graph))
    local traversed, paths = {}, {}
    find_paths(graph, graph.start, 0, traversed, paths)
    -- print(serpent.block2(paths))
    table.sort(paths)
    return paths[#paths]
end

local function get_graph2()
    local map = Map.read()
    -- map:print(table.concat)
    local start = {x=2, y=1}
    local stop = table.sub_coords(map:size(), {x=1, y=0})

    local branches = {[table.hash_pos(start)] = {pos=start, branches=1}}
    local nodes = {[table.hash_pos(start)] = {}}

    local branch, pos_hash = table.map_remove(branches)
    while branch do
        while branch.branches > 0 do
            local at, len, one_way, directions = crawl(map, nodes, branch.pos)
            add_node(nodes, pos_hash, table.hash_pos(at), len)
            if directions and directions > 0 then
                branches[table.hash_pos(at)] = {pos=at, branches=directions}
            end
            branch.branches = branch.branches - 1
        end
        
        branch, pos_hash = table.map_remove(branches)
    end

    map:print(table.concat)
    return {start=table.hash_pos(start), stop=table.hash_pos(stop), nodes=nodes}
end

run["2"] = function ()
    local graph = get_graph2()
    -- print(serpent.block2(graph))
    local traversed, paths = {}, {}
    find_paths(graph, graph.start, 0, traversed, paths)
    -- print(serpent.block2(paths))
    table.sort(paths)
    return paths[#paths]
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())