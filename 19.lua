require("shared")

local run = {}

local Check = {
    [">"] = function (x, c)
        return x > c
    end,
    ["<"] = function (x, c)
        return x < c
    end,
}

local function get_workflows(check)
    local workflows = {}
    ForEachLineBreak("^$", function (line)
        local _, _, name, f_rules = line:find("(.*){(.*)}")
        local rules = {}

        for f_rule in f_rules:gmatch("[^,]*") do
            local rule = {}
            local _, _, v, c, n, t = f_rule:find("(.)(.)(%d*):(.*)")
            if not t then t = f_rule end
            -- print(tostring(v) .. " " .. tostring(c) .. " " .. tostring(n) .. " " .. tostring(t))
            if v then
                rule.value = v
                rule.check = check[c]
                rule.number = tonumber(n)
            end
            rule.to = t

            table.insert(rules, rule)
        end
        workflows[name] = rules
    end)

    return workflows, start
end

local function get_parts()
    local parts = {}
    ForEachLine(function (line)
        local part = {}

        for value in line:gfind("(.)=(%d*)") do
            part[value[3]] = tonumber(value[4])
        end

        table.insert(parts, part)
    end)

    return parts
end

local function run_rule(rule, part)
    if rule.check then
        if rule.check(part[rule.value], rule.number) then
            return rule.to
        end
    else
        return rule.to
    end
end

local function run_rules(workflows, current, part)
    while true do
        local rules = workflows[current]
        -- print("on rule: " .. current)
        for i, rule in pairs(rules) do
            -- print("rule #" .. i)
            local out = run_rule(rule, part)
            -- print(out)
            if out == "A" then
                return part
            elseif out == "R" then
                return
            elseif out ~= nil then
                current = out
                break
            end
        end
        
    end
end

local function filter_parts(workflows, parts)
    local accepted = {}

    for _, part in pairs(parts) do
        local out = run_rules(workflows, "in", part)
        if out then table.insert(accepted, out) end
    end

    return accepted
end

run["1"] = function ()
    local workflows = get_workflows(Check)
    local parts = get_parts()

    -- print(serpent.block2(workflows))
    -- print(serpent.block2(parts))
    local accepted = filter_parts(workflows, parts)
    local total = 0
    for _, part in pairs(accepted) do
        for _, value in pairs(part) do
            total = total + value
        end
    end

    return total
end

local Check2 = {
    [">"] = function (x, key, c)
        local y = table.deep_copy(x)
        if x[key].max > c then
            x[key].max = c
        end
        if y[key].min <= c then
            y[key].min = c + 1
        end
        return y
    end,
    ["<"] = function (x, key, c)
        local y = table.deep_copy(x)
        if x[key].min < c then
            x[key].min = c
        end
        if y[key].max >= c then
            y[key].max = c - 1
        end
        return y
    end,
}

local function sift(workflows, accepted, part, flow)
    if flow == "A" then
        table.insert(accepted, part)
        return
    end
    if flow == "R" then
        return
    end

    -- print(flow)
    for _, filter in pairs(workflows[flow]) do
        if filter.check then
            sift(workflows, accepted, filter.check(part, filter.value, filter.number), filter.to)
        else
            sift(workflows, accepted, part, filter.to)
        end
    end
end

run["2"] = function ()
    local workflows = get_workflows(Check2)
    local accepted = {}
    sift(workflows, accepted, {x={min=1, max=4000},m={min=1, max=4000},a={min=1, max=4000},s={min=1, max=4000}}, "in")
    -- print(serpent.block2(accepted))

    local i = 1
    while i < #accepted do
        local part = accepted[i]
        local r = false
        for _, value in pairs(part) do
            local temp = (value.max + 1) - value.min
            if temp > 0 then
                r = true
                break
            end
        end
        print(tostring(r) .. " " .. serpent.line2(part))
        if r then
            i = i + 1
        else
            table.remove(accepted, i)
        end
    end

    local total = 0
    for _, part in pairs(accepted) do
        local count = 1
        for _, value in pairs(part) do
            local temp = (value.max + 1) - value.min
            if temp > 0 then
                count = count * temp
            end
        end
        print(count .. " " .. serpent.line2(part))
        total = total + count
    end

    return total
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())