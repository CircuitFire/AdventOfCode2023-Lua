require("shared")

local run = {}

local function hash_chunk(chunk)
    local value = 0
    for i = 1, chunk:len() do
        value = math.fmod((value + chunk:byte(i)) * 17, 256)
    end
    return value
end

run["1"] = function ()
    total = 0
    for chunk in io.read():gmatch("[^,]*") do
        local hash = hash_chunk(chunk)
        -- print("hash: " .. hash)
        total = total + hash
    end
    return total
end

--boxes = [hash]{count: int, lenses: [label]{focus = int, pos: int}}
local function do_instruction(chunk, boxes)
    local _, _, label, job, focus = chunk:find("(%a*)([-=])(%d*)")
    local hash = hash_chunk(label) + 1
    -- print(label .. " " .. job .. " " .. focus)

    if not boxes[hash] then boxes[hash] = {count = 0, lenses = {}} end
    local box = boxes[hash]
    local lens = box.lenses[label]
    if job == "=" then
        if not lens then
            box.count = box.count + 1
            lens = {pos = box.count}
            box.lenses[label] = lens
        end
        lens.focus = focus
    else
        if lens then
            box.lenses[label] = nil
        end
    end
end


run["2"] = function ()
    local boxes = {}
    for chunk in io.read():gmatch("[^,]*") do
        do_instruction(chunk, boxes)
    end
    -- print(serpent.block2(boxes))

    local total = 0
    
    for key, box in pairs(boxes) do
        local sort = {}
        for _, lens in pairs(box.lenses) do
            table.insert(sort, lens)
        end
        table.sort(sort, function (a, b)
            return a.pos < b.pos
        end)
        for i, lens in pairs(sort) do
            total = total + (key * i * lens.focus)
        end
    end

    return total
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())