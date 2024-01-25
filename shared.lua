serpent = require("serpent")
serpent.line2 = function (t, m)
    local x = m or {}
    x.comment = false
    return serpent.line(t, x)
end

serpent.block2 = function (t, m)
    local x = m or {}
    x.comment = false
    return serpent.block(t, x)
end

---comment
---@param func function
function ForEachLine(func)
    local line = io.read()
    while line do
        if line ~= "" then
            func(line)
        end
        line = io.read()
    end
end

function ForEachLineBreak(pattern, func)
    local line = io.read()
    while line do
        if line:find(pattern) then
            return line
        end
        func(line)
        line = io.read()
    end
end

---comment
---@param line string
---@param pattern string
---@return function
string.gfind = function(line, pattern)
    local current = 1
    return function()
        local t = {line:find(pattern, current)}
        if not next(t) then return end
        current = t[2] + 1
        return t
    end
end

math.gdc = function(a, b)
    --Return greatest common divisor using Euclid's Algorithm.
    while b ~= 0 do
        a, b = b, a % b
    end
    return a
end

math.lcm = function(a, b)
    --Return lowest common multiple.
    return math.floor((a * b) / math.gdc(a, b))
end

math.lcmm = function(...)
    local args = {...}
    if type(args[1]) == "table" then
        args = args[1]
    end
    --Return lcm of args.
    local current = args[1]
    for i = 2, #args do
        current = math.lcm(current, args[i])
    end
    return current
end

table.new2d = function (hight)
    local new = {}
    for i = 1, hight do
        table.insert(new, {})
    end
    return new
end

table.print_2d = function (map)
    for _, value in pairs(map) do
        print(serpent.line2(value))
    end
end

table.row = function (map, row)
    local i = 0
    return function ()
        i = i + 1
        return map[row] and map[row][i]
    end
end

table.column = function (map, column)
    local i = 0
    return function ()
        i = i + 1
        return map[i] and map[i][column]
    end
end

function table.copy(t)
    local x = {}
    for key, value in pairs(t) do
        x[key] = value
    end
    return x
end

function table.deep_copy(t)
    local x = {}
    for key, value in pairs(t) do
        if type(value) == "table" then
            x[key] = table.deep_copy(value)
        else
            x[key] = value
        end
        
    end
    return x
end

function table.count(t)
    local c = 0
    for key, value in pairs(t) do
       c = c + 1 
    end
    return c
end

function table.add_coords(x, y)
    return {x=x.x + y.x, y=x.y + y.y}
end

function table.sub_coords(x, y)
    return {x=x.x - y.x, y=x.y - y.y}
end

function table.mul_coords(x, y)
    return {x=x.x * y.x, y=x.y * y.y}
end

function table.div_coords(x, y)
    return {x=x.x / y.x, y=x.y / y.y}
end

function table.flip_coord(x)
    return {x=x.y, y=x.x}
end

function table.map(table, func)
    local remove = {}
    for x, value in pairs(table) do
        local out = func(value)
        if out ~= nil then
            table[x] = out
        else
            table.insert(remove, x)
        end
    end
    for _, x in pairs(remove) do
        table[x] = nil
    end
    return table
end

table.coord_eq = function(a, b)
    return (a.x == b.x) and (a.y == b.y)
end

function table.into_dir(a, b)
    local t = table.sub_coords(a, b)

    if t.x < 0 then return "w" end
    if t.x > 0 then return "e" end
    if t.y < 0 then return "n" end
    if t.y > 0 then return "s" end
end

function table.hash_pos(pos)
    return "x" .. pos.x .. "y" .. pos.y
end

function table.map_remove(table)
    local k, v = next(table)
    if not k then return end
    table[k] = nil
    return v, k
end

Iters = {}

Iters.zig = function (max)
    local change = -1
    local dir = 1
    local current = math.ceil(max / 2)
    return function ()
        change = change + 1
        if change == max then return end
        dir = dir * -1
        current = current + change * dir
        return current
    end
end

Iters.zip = function (x, y)
    return function ()
        return x(), y()
    end 
end

Map = {}
Map.__index = Map

Map.Dir = {
    n = {y =-1, x = 0},
    s = {y = 1, x = 0},
    e = {y = 0, x = 1},
    w = {y = 0, x =-1},
}

Map.Dir_Arrows = {
    n = "^",
    s = "v",
    e = ">",
    w = "<",
}

Map.Op = {
    n = "s",
    s = "n",
    e = "w",
    w = "e"
}

---@param size integer
---@return table
function Map.new(size)
    local new = {}
    setmetatable(new, Map)
    for i = 1, size or 0 do
        table.insert(new, {})
    end
    return new
end

---@param size table
---@param fill function
---@return table
function Map.new_fill(size, fill)
    local new = {}
    setmetatable(new, Map)
    for y = 1, size.y do
        local row = {}
        for x = 1, size.x do
            table.insert(row, fill())
        end
        table.insert(new, row)
    end
    return new
end

function Map.set(self, pos, data)
    if not self[pos.y] then self[pos.y] = {} end
    self[pos.y][pos.x] = data
end

function Map.get(self, pos)
    return self[pos.y] and self[pos.y][pos.x]
end

function Map.in_row(self, row, reverse)
    local i, change = 0, 1
    if reverse then i, change = self:num_rows() + 1, -1 end
    return function ()
        i = i + change
        local x = self[row] and self[row][i]
        if x then return {x=i, y=row}, x end
    end
end

function Map.in_column(self, column, reverse)
    local i, change = 0, 1
    if reverse then i, change = self:num_columns() + 1, -1 end
    return function ()
        i = i + change
        local x = self[i] and self[i][column]
        if x then return {x=column, y=i}, x end
        return 
    end
end

function Map.map(self, func)
    for y = 1, self:num_rows() do
        local row = self[y]
        local remove = {}
        for x, value in pairs(row) do
            local out = func(row[x])
            if out ~= nil then
                row[x] = out
            else
                table.insert(remove, x)
            end
        end
        for _, x in pairs(remove) do
            row[x] = nil
        end
    end
end

function Map.num_rows(self)
    return #self
end

function Map.num_columns(self)
    return (self[1] and #self[1]) or 0
end

function Map.size(self)
    return {x=self:num_columns(), y=self:num_rows()}
end

---@param self table
---@param format function
function Map.print(self, format)
    for y, value in pairs(self) do
        print(format(value))
    end
end

function Map.read()
    local map = Map.new()
    ForEachLineBreak("^$", function (line)
        local row = {}
        for value in line:gmatch(".") do
            table.insert(row, value)
        end
        table.insert(map, row)
    end)

    return map
end

local code = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-="

Coding = {}

function Coding.code(num, base)
    local out = ""
    while true do
        local part = math.fmod(num, base) + 1
        out = code:sub(part, part) .. out
        num = num // base
        if num == 0 then return out end
    end
end