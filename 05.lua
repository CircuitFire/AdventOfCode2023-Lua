require("shared")

local run = {}

run["1"] = function ()
    local seeds = {}
    ForEachLineBreak("^$", function (line)
        for value in line:gmatch("%d+") do
            table.insert(seeds, tonumber(value))
        end
    end)

    local continue = ForEachLineBreak(":", function (line) end)

    while continue do
        local transforms = {}
        continue = ForEachLineBreak(":", function (line)
            local _, _, t, s, r = line:find("(%d+) (%d+) (%d+)")
            if t then
                table.insert(transforms, {tonumber(t), tonumber(s), tonumber(r)})
            end
        end)
        -- print("transforms: " .. serpent.block(transforms, {comment = false}))
        for i, seed in pairs(seeds) do
            for _, tr in pairs(transforms) do
                if tr[2] <= seed and seed < tr[2] + tr[3] then
                    seeds[i] = seed + (tr[1] - tr[2])
                end
            end
        end
    end

    table.sort(seeds)
    return seeds[1]
end

local function split_seeds(seed, range)
    local trimings = {}
    if seed[1] < range[1] and seed[2] >= range[1] then
        table.insert(trimings, {seed[1], range[1] - 1})
        seed[1] = range[1]
    end
    if seed[1] <= range[2] and seed[2] > range[2] then
        table.insert(trimings, {range[2] + 1, seed[2]})
        seed[2] = range[2]
    end

    return trimings
end

run["2"] = function ()
    -- []{start, end}
    local seeds = {}
    ForEachLineBreak("^$", function (line)
        for value in line:gfind("(%d+) (%d+)") do
            local s = tonumber(value[3])
            local l = tonumber(value[4])
            table.insert(seeds, {s, s + l - 1})
        end
    end)

    local continue = ForEachLineBreak(":", function (line) end)
    print("seeds: " .. serpent.line(seeds, {comment = false}))
    while continue do
        -- []{start, end, offset}
        local transforms = {}
        continue = ForEachLineBreak(":", function (line)
            local _, _, t, s, r = line:find("(%d+) (%d+) (%d+)")
            if t then
                t = tonumber(t)
                s = tonumber(s)
                r = tonumber(r)
                table.insert(transforms, {s, s + r - 1, t - s})
            end
        end)
        
        for i, seed in pairs(seeds) do
            for _, tr in pairs(transforms) do
                for _, trims in pairs(split_seeds(seed, tr)) do
                    table.insert(seeds, trims)
                end
                if seed[1] >= tr[1] and seed[2] <= tr[2] then
                    seed[1] = seed[1] + tr[3]
                    seed[2] = seed[2] + tr[3]
                    break
                end
            end
        end
        print("transforms: " .. serpent.line(transforms, {comment = false}))
        print("seeds: " .. serpent.line(seeds, {comment = false}))
    end

    table.sort(seeds, function (x, y)
        return x[1] < y[1]
    end)
    return seeds[1][1]
end

print("Enter Input:")
print(run[arg[1] or "1"]())