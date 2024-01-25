require("shared")

local run = {}

local function not_all_zero(list)
    for _, value in pairs(list) do
        if value ~= 0 then
            return true
        end
    end
end

run["1"] = function ()
    local sum = 0

    ForEachLine(function (line)
        local last = {}
        local ends = {}

        for value in line:gmatch("[%d-]+") do
            table.insert(last, tonumber(value))
        end

        while not_all_zero(last) do
            table.insert(ends, last[#last])
            local temp = {}

            for i = 2, #last do
                table.insert(temp, last[i] - last[i - 1])
            end

            last = temp
        end

        -- print("ends: " .. serpent.line2(ends))
        -- print("last: " .. serpent.line2(last))
        for _, v in pairs(ends) do
            sum = sum + v
        end
    end)

    return sum
end

run["2"] = function ()
    local sum = 0

    ForEachLine(function (line)
        local last = {}
        local ends = {}

        for value in line:gmatch("[%d-]+") do
            table.insert(last, tonumber(value))
        end

        while not_all_zero(last) do
            table.insert(ends, last[1])
            local temp = {}

            for i = 2, #last do
                table.insert(temp, last[i - 1] - last[i])
            end

            last = temp
        end

        -- print("ends: " .. serpent.line2(ends))
        -- print("last: " .. serpent.line2(last))
        for _, v in pairs(ends) do
            sum = sum + v
        end
    end)

    return sum
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())