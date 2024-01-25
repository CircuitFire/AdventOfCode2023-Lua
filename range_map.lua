require("shared")

RangeMap = {}
RangeMap.__index = RangeMap

function RangeMap.get(self, pos)
    local out = self.map:get(pos)
    if out then return out end

    if self.x_range[pos.y] then
        for x, value in pairs(self.x_range[pos.y]) do
            if pos.x >= x and pos.x <= x + value.range then
                -- print("range: " .. value.offset .. "->" .. value.offset - (value.change * value.range) .. " change = " .. value.change)
                -- print("getting: x: " .. x .. " <= " .. serpent.line2(pos) .. " <= " .. x + value.range .. " = " .. value.offset - ((pos.x - x + 1) * value.change))
                local to
                if value.flip then
                    to = {x = x, y = pos.y} 
                else
                    to = {x = x + value.range, y = pos.y} 
                end
                return {hash = value.hash, offset=value.offset - ((pos.x - x) * value.change), to=to, range=value.range}
            end
        end
    end
    if self.y_range[pos.x] then
        for y, value in pairs(self.y_range[pos.x]) do
            if pos.y >= y and pos.y <= y + value.range then
                -- print("range: " .. value.offset .. "->" .. value.offset - (value.change * value.range) .. " change = " .. value.change)
                -- print("getting: y: " .. y .. " <= " .. serpent.line2(pos) .. " <= " .. y + value.range .. " = " .. value.offset - ((pos.y - y + 1) * value.change))
                local to
                if value.flip then
                    to = {y = y, x = pos.x} 
                else
                    to = {y = y + value.range, x = pos.x} 
                end
                return {hash = value.hash, offset=value.offset - ((pos.y - y) * value.change), to=to, range=value.range}
            end
        end
    end
end

function RangeMap.set(self, pos, set, extra)
    if not extra or table.coord_eq(pos, extra.pos) then
        self.map:set(pos, set)
        return
    end

    local extend_to = extra.pos
    local difference = table.sub_coords(pos, extend_to)
    local section
    if difference.y == 0 then -- x_range
        section = "x_range"
    else -- y_range
        pos, extend_to = table.flip_coord(pos), table.flip_coord(extend_to)
        section = "y_range"
    end
    
    local change = extra.change
    local offset = set.offset
    local flip
    if extend_to.x < pos.x then
        pos, extend_to = extend_to, pos
        offset = offset - (change * (extend_to.x - pos.x))
        change = -change
        flip = true
    end
    local range = extend_to.x - pos.x
    self[section]:set(pos, {hash=set.hash, offset=offset, range=range, change=change, flip=flip})
    -- local t
    -- if flip then
    --     pos = table.flip_coord(pos)
    --     t = {x=pos.x, y=pos.y + range}
    -- else
    --     t = {x=pos.x + range, y=pos.y}
    -- end
    -- print("setting: " .. section .. " " .. serpent.line2(pos) .. "->" .. serpent.line2(t))
end

function RangeMap.clear(self, y)
    self.map[y] = {}
    self.x_range[y] = {}
end

function RangeMap.new()
    local new = {
        map = Map.new(),
        x_range = Map.new(),--y index
        y_range = Map.new(),--x index
    }
    setmetatable(new, RangeMap)
    return new
end

-- local test = RangeMap.new()

-- local x = 0
-- local y = 0

-- print("+X")
-- test:set({x=1,y=0}, {hash="1", offset=100}, {pos={x=8,y=0}, change=13})
-- test:set({x=9,y=0}, {hash="1b", offset=0})
-- for x = 0, 10 do
--     print(serpent.line2(test:get{x=x,y=y}))
-- end

-- print("+Y")
-- test:set({x=0,y=1}, {hash="2", offset=100}, {pos={x=0,y=8}, change=13})
-- for y = 0, 10 do
--     print(serpent.line2(test:get{x=x,y=y}))
-- end

-- print("-X")
-- test:set({x=-1,y=0}, {hash="3", offset=100}, {pos={x=-8,y=0}, change=13})
-- for x = 0, -10, -1 do
--     print(serpent.line2(test:get{x=x,y=y}))
-- end

-- print("-Y")
-- test:set({x=0,y=-1}, {hash="4", offset=100}, {pos={x=0,y=-8}, change=13})
-- for y = 0, -10, -1 do
--     print(serpent.line2(test:get{x=x,y=y}))
-- end