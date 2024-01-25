require("shared")

local run = {}

local function format_data(line)
    local _, _, pattern, groups = line:find("(.*) (.*)")

    local g = {}
    local gp = {}
    for num in groups:gmatch("%d*") do
        table.insert(g, "." .. string.rep("#", tonumber(num)) .. ".")
        table.insert(gp, "[.?]" .. string.rep("[#?]", tonumber(num)) .. "[.?]")
    end

    return {
        pattern = pattern,
        groups = gp,
        groupsd = g
    }
end

local function rfind(data, depth, start)
    if depth > #data.groups then
        -- print("end")
        if data.pattern:find("#", start) then
            return 0, true
        else
            return 1
        end
    end

    local count = 0
    while true do
        local s, e = data.pattern:find(data.groups[depth], start)
        local f = data.pattern:sub(start, s):find("#")
        if not s or f then return count, f end
        print(depth .. " " .. data.pattern:sub(1, s-1) .. "|" .. data.groupsd[depth] .. "|" .. data.pattern:sub(e+1) .. " " .. data.groupsd[depth])
        -- print("(d: " .. depth .. ", s: " .. s .. ", e: " .. e .. ")")

        local c, f = rfind(data, depth + 1, e)
        if c == 0 and not f then return count, f end
        count = count + c
        -- print(depth .. " " .. count)

        start = s + 1
    end
    
    return count
end

run["1"] = function ()
    local count = 0
    local i = 1
    ForEachLine(function (line)
        local data = format_data(line)
        data.pattern = "." .. data.pattern .. "."
        -- print(serpent.block2(data))
        -- print(data.pattern)
        local c = rfind(data, 1, 1)
        count = count + c
        print(c)
        i = i + 1
    end)
    return count
end

local function multiply(data, mul)
    data.pattern = string.rep(data.pattern, mul, "?")

    local new = {}
    for i = 1, mul do
        for _, value in pairs(data.groups) do
            table.insert(new, value)
        end
    end

    data.groups = new
end

local function valid_gap(pattern, s, e)
    local x = pattern:sub(s, e):find("#")
    if x then return false end
    return true
end

--{continue = -1|0|1, found = [{s = int, e = int, count = int}]}
-- -1 = failed match, 1 = match ended, 0 = return match list
local function rfind2(data, depth, start)
    if depth > #data.groups then
        if data.pattern:find("#", start) then
            return {continue = -1}
        else
            return {continue = 1}
        end
    end

    local s, e, out
    while true do -- find first valid match
        s, e = data.pattern:find(data.groups[depth], start)
        if not s then return {continue = -1} end
        start = s + 1
        out = rfind2(data, depth + 1, e)
        if out.continue ~= -1 then break end
    end
    
    local found = {}
    while out.continue == 1 do -- reached end of matches
        table.insert(found, {s = s, e = e, count = 1})
        s, e = data.pattern:find(data.groups[depth], start)
        if not s then
            -- print("d: " .. depth .. " | " .. serpent.line2(found))
            return {continue = 0, found = found}
        end
        start = s + 1
    end

    local i = 1
    if out.continue == 0 then
        while i <= #out.found do -- add successful match
            local count = 0
            for j = i, #out.found do
                if valid_gap(data.pattern, e, out.found[j].s) then
                    count = count + out.found[j].count
                end
            end
            table.insert(found, {s = s, e = e, count = count})
            
            s, e = data.pattern:find(data.groups[depth], start)
            if not s then
                -- print("d: " .. depth .. " | " .. serpent.line2(found))
                return {continue = 0, found = found}
            end
            start = s + 1
    
            while i <= #out.found and out.found[i].s < e do
                out.found[i] = nil
                i = i + 1
            end 
        end
    end
    
    -- print("d: " .. depth .. " | " .. serpent.line2(found))
    return {continue = 0, found = found}
end

run["2"] = function ()
    local count = 0
    local i = 1
    ForEachLine(function (line)
        local data = format_data(line)
        multiply(data, 5)
        data.pattern = "." .. data.pattern .. "."
        -- print(serpent.block2(data))
        -- print(data.pattern)
        local out = rfind2(data, 1, 1)
        local c = 0
        for _, value in pairs(out.found) do
            if valid_gap(data.pattern, 1, value.s) then
                c = c + value.count
            end
        end

        count = count + c
        -- print(c)
        i = i + 1
    end)
    return count
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())