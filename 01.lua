require("shared")

local run = {}

run["1"] = function ()
    local total = 0

    ForEachLine(function (line)
        local _, _, f = line:find("([%d])")
        local _, _, l = line:reverse():find("([%d])")
        
        total = total + tonumber(f .. l)
    end)

    return total
end

local Nums = {
    one   = 1,
    two   = 2,
    three = 3,
    four  = 4,
    five  = 5,
    six   = 6,
    seven = 7,
    eight = 8,
    nine  = 9,
}

local Check = {
    o = {3},
    t = {3, 5},
    f = {4},
    s = {3, 5},
    e = {5},
    n = {4}
}

local function get_num(line, at, char)
    local c = tonumber(char)
    if c then return c end
    for _, value in pairs(Check[char]) do
        local sub = line:sub(at, at + value - 1)
        -- print(char .. ": " .. sub)
        c = Nums[sub]
        if c then return c end
    end
end

run["2"] = function ()
    local total = 0

    ForEachLine(function (line)
        local at = 1
        local f = nil
        while not f do
            local n, _, c = line:find("([%dotfsen])", at)
            f = get_num(line, n, c)
            at = n + 1
        end

        local rline = line:reverse()
        local at = 1
        local l = nil
        while not l do
            local n, _, c = rline:find("([%dotfsen])", at)
            l = get_num(line, line:len() - n + 1, c)
            at = n + 1
        end
        
        total = total + tonumber(f .. l)
    end)

    return total
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())