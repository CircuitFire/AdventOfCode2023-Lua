require("shared")

local run = {}

local Funcs = {
    ["?"] = function (self, from, input)
        return {s=input, n=self.name, o=self.out}
    end,
    ["%"] = function (self, from, input)
        if input then return end
        self.state = not self.state
        return {s=self.state, n=self.name, o=self.out}
    end,
    ["&"] = function (self, from, input)
        self.state[from] = input
        for _, value in pairs(self.state) do
            if not value then
                return {s=true, n=self.name, o=self.out}
            end
        end
        return {s=false, n=self.name, o=self.out}
    end,
}

local Setup = {
    ["?"] = function (rule, inputs)
        rule.func = Funcs["?"]
    end,
    ["%"] = function (rule, inputs)
        rule.func = Funcs["%"]
        rule.state = false
    end,
    ["&"] = function (rule, inputs)
        rule.func = Funcs["&"]
        local state = {}
        for key, value in pairs(inputs) do
            state[value] = false
        end
        rule.state = state
    end,
}

local function get_circuit()
    local circuit = {}

    ForEachLine(function (line)
        local _, _, f, n, o = line:find("([%%&]?)([^ ]*) %->(.*)")
        if f == "" then f = "?" end
        -- print(f .. " " .. n .. " " .. o)
        
        local rule = {name=n , func=f, out={}}
        for value in o:gfind(" ([^, ]*),?") do
            -- print(value)
            table.insert(rule.out, value[3])
        end
        circuit[n] = rule
        -- print(serpent.block2(circuit))
    end)

    local inputs = {}
    for name, rule in pairs(circuit) do
        for _, out in pairs(rule.out) do
            local t = inputs[out] or {}
            table.insert(t, name)
            inputs[out] = t
        end
    end

    for name, rule in pairs(circuit) do
        -- print(serpent.line2(rule))
        rule.inputs = inputs[name]
        Setup[rule.func](rule, inputs[name])
    end

    return circuit
end

local function exe(circuit, counts, q)
    local current = table.remove(q)
    -- counts[current.s] = counts[current.s] + 1

    while current do
        -- print(serpent.line2(current))
        for _, value in pairs(current.o) do
            counts[current.s] = counts[current.s] + 1
            local t = circuit[value]
            if t then
                local out = t:func(current.n, current.s)
                if out then
                    table.insert(q, 1, out)
                end
            end
        end
        
        current = table.remove(q)
    end
end

run["1"] = function ()
    local circuit = get_circuit()
    -- print(serpent.block2(circuit))
    local counts = {[true] = 0, [false] = 0}
    local q = {}

    for i = 1, 1000 do
        print(serpent.block2(counts))
        table.insert(q, 1, {s=false, n="button", o={"broadcaster"}})
        exe(circuit, counts, q)
    end

    return counts[true] * counts[false]
end

local function find_start(circuit)
    for name, rule in pairs(circuit) do
        for key, value in pairs(rule.out) do
            if not circuit[value] then
                return name
            end
        end
    end
end

local function exe2(circuit, watch, q, i, find)
    local current = table.remove(q)

    while current do
        for _, value in pairs(current.o) do
            -- counts[current.s] = counts[current.s] + 1
            local t = circuit[value]
            if t then
                local out = t:func(current.n, current.s)
                if watch[value] then
                    -- print(i .. " " .. current.n .. " " .. tostring(current.s) .. "->" .. value .. " out: " .. tostring(out.s) .. " state: " .. serpent.line2(t.state))
                    if out.s == false and #watch[value] == 0 then
                        table.insert(watch[value], i)
                    end
                end
                if out then
                    table.insert(q, 1, out)
                end
            end
        end
        
        current = table.remove(q)
    end
end

local function found_all(watch)
    -- print(serpent.line2(watch))
    for key, value in pairs(watch) do
        if #value < 1 then
            return false
        end
    end
    return true
end

local function get_watch(circuit, start, watch, depth)
    local temp = {{start}}
    for i = 1, depth - 1 do
        temp[i + 1] = {}
        for j = 1, #temp[i] do
            local name = temp[i][j]
            for _, name in pairs(circuit[name].inputs) do
                table.insert(temp[i + 1], name)
            end
        end
    end
    print(serpent.block2(temp))

    for _, value in pairs(temp[depth]) do
        -- local t = circuit[value].func
        -- print(value .. ((t == Funcs["&"]) and "&") or "%")
        watch[value] = {}
    end
end

run["2"] = function ()
    local circuit = get_circuit()
    -- print(serpent.block2(circuit))

    -- for key, value in pairs(circuit) do
    --     print(key .. " " .. serpent.line2(value.inputs))
    -- end
    -- return
    
    local watch = {}
    local start = find_start(circuit)
    get_watch(circuit, start, watch, 3)
    print(serpent.block2(watch))
    
    -- watch = {nl = {}} -- dj nl
    local find = false
    local q = {}
    i = 1
    while not found_all(watch) do
        if i % 100 == 0 then print(i--[[ .. " " .. serpent.line2(watch)]]) end
        table.insert(q, 1, {s=false, n="button", o={"broadcaster"}})
        if exe2(circuit, watch, q, i, find) then return end
        i = i + 1
    end
    
    print(serpent.block2(watch))
    local temp = {}
    for key, value in pairs(watch) do
        table.insert(temp, value[1])
    end

    print(serpent.line2(temp))
    return math.lcmm(temp)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())


--[[ tests
    local function examine(circuit, current)
    print(current)
    current = circuit[current]
    if current.cache then return current.cache end

    local inputs = {}
    if current.func == Funcs["&"] then
        local max = 0
        local state = {}
        for i, value in pairs(current.inputs) do
            local input = examine(circuit, value)
            -- print("input " .. serpent.line2(input))
            max = max + input.l
            inputs[i] = input
            state[i] = false
        end
        
        local out = {l=max, p={}}
        local i = 0
        local offset = 0
        while i < max do
            local added = 0
            for j, list in pairs(inputs) do
                -- print(i .. " " .. j)
                local t = list.p[(i) % list.l]
                if t ~= nil then
                    state[j] = t
                    
                    local new = false
                    for _, value in pairs(state) do
                        if not value then
                            new = true
                            break
                        end
                    end
                    -- print(i .. " " .. offset .. " " .. serpent.line2(state) .. " " .. tostring(new))
                    -- print(i+(j-1))
                    out.p[i+offset] = new
                    offset = offset + 1
                    added = added + 1
                end
            end
            max = max - (added - 1)
            offset = offset - 1
            i = i + 1
        end

        current.cache = out
        -- print(current.name .. serpent.block2(current.cache))
        return out
    elseif current.func == Funcs["%"] then
        local max = 0
        for i, value in pairs(current.inputs) do
            local input = examine(circuit, value)
            -- print("input " .. serpent.line2(input))
            inputs[i] = input
            local count = 0
            for _, value in pairs(inputs[i].p) do
                if value == false then
                    count = count + 1
                end
            end

            if count % 2 == 1 then
                count = input.l * 2
            end
            max = max + count
        end
        
        local state = false
        local j = 0
        local out = {p={}}
        for i = 0, max - 1 do
            for _, list in pairs(inputs) do
                -- print(serpent.line2(list))
                local t = list.p[i % list.l]
                if t == false then
                    state = not state
                    out.p[j] = state
                end
                j = j + 1
            end
        end
        out.l = max

        current.cache = out
        -- print(current.name .. serpent.block2(current.cache))
        return out
    else
        current.cache = {l=1, p={[0]=false}}
        -- print(current.name .. serpent.block2(current.cache))
        return {l=1, p={[0]=false}}
    end
end
]]