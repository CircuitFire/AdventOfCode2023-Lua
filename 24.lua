require("shared")

local run = {}

local function get_hail()
    local hail = {}

    ForEachLine(function (line)
        local _, _, px, py, pz, vx, vy, vz = line:find("(%d*), (%d*), (%d*) @ ([ -]?%d*), ([ -]?%d*), ([ -]?%d*)")
        -- print(px, py, pz, vx, vy, vz)
        table.insert(hail, {pos={x=tonumber(px), y=tonumber(py), z=tonumber(pz)}, vel={x=tonumber(vx), y=tonumber(vy), z=tonumber(vz)}})
    end)

    return hail
end

local function intersect_at(a, b)
    -- print("a", serpent.line2(a))
    -- print("b", serpent.line2(b))
    local ax1 = a.pos.x + 0.0
    local ax2 = a.pos.x + a.vel.x + 0.0
    local bx1 = b.pos.x + 0.0
    local bx2 = b.pos.x + b.vel.x + 0.0

    local ay1 = a.pos.y + 0.0
    local ay2 = a.pos.y + a.vel.y + 0.0
    local by1 = b.pos.y + 0.0
    local by2 = b.pos.y + b.vel.y + 0.0
 
    local det = (ax1-ax2)*(by1-by2) - (ay1-ay2)*(bx1-bx2)
 
    if det ~= 0 then
        local t1 = (ax1 * ay2) - (ay1 * ax2)
        local t2 = (bx1 * by2) - (by1 * bx2)

        local x = ((t1 * (bx1 - bx2)) - ((ax1 - ax2) * t2)) / det
        local y = ((t1 * (by1 - by2)) - ((ay1 - ay2) * t2)) / det

        local pos_time = (x>ax1)==(ax2>ax1) and (x>bx1)==(bx2>bx1)
        return {x=x, y=y}, pos_time, {det=det, t1=t1, t2=t2, t1p1=ax1 * ay2, t1p2=ay1 * ax2}
    end
end

local function intersect_at2(a, b)
    -- print("a", serpent.line2(a))
    -- print("b", serpent.line2(b))
    -- if x_change == 0 then
    --     if a.pos.y == b.pos.y then
    --         return a.pos
    --     end
    --     return
    -- end
    local a_slope = a.vel.y/a.vel.x
    local b_slope = b.vel.y/b.vel.x
    local x = ((a_slope * a.pos.x) - a.pos.y - (b_slope * b.pos.x) + b.pos.y) / (a_slope - b_slope)
    if x==x and math.abs(x) ~= math.huge
    and (x > a.pos.x) == ((a.pos.x + a.vel.x) > a.pos.x)
    and (x > b.pos.x) == ((b.pos.x + b.vel.x) > b.pos.x)
    then
        return {x=x, y=(a_slope * (x - a.pos.x)) + a.pos.y}
    end

    -- print(math.abs(x))
end

run["1"] = function ()
    local hail = get_hail()
    local min, max = 200000000000000, 400000000000000
    -- local min, max = 7, 27

    local count = 0
    i = 1
    while i < #hail do
        j = i + 1
        while j <= #hail do
            local intersect = intersect_at2(hail[i], hail[j])
            -- print(serpent.block2(test))
            -- print(serpent.line2(hail[i]))
            -- print(serpent.line2(hail[j]))
            -- print(serpent.line2(intersect))
            
            if intersect
            and intersect.x >= min and intersect.x <= max
            and intersect.y >= min and intersect.y <= max
            then
                -- print(i .. " " .. j)
                count = count + 1
            end

            j = j + 1
        end
        i = i + 1
    end

    return count
end

local function zig(i)
    if i < 0 then
        return (i - 1) * -1
    end
    return i * -1
end

local function smallest_in(hail, var)
    local arrangement = {}

    for key, value in pairs(hail) do
        table.insert(arrangement, {value.pos[var], key})
    end
    table.sort(arrangement, function (a, b)
        return a[1] < b[1]
    end)

    -- print(hail[arrangement[1][2]].pos[var])
    return arrangement[1][2]
end

local function linear_change(hail, var, test, smallest)
    print(var .. " testing: " .. test)
    local start
    if test > 0 then
        start = (((hail[smallest].vel[var] - test) * test) + hail[smallest].pos[var]) * test
    else
        start = (((hail[smallest].vel[var] + test) * test) + hail[smallest].pos[var])
    end
    if start < 0 then return end

    parts = {}
    for key, value in pairs(hail) do
        local t, r = math.modf((-(value.pos[var] - start))/(value.vel[var] - test))
        -- print("intersect_at: ", t, r, start, value.pos[var] )
        if t ~= t or math.abs(t) == math.huge then
            if start ~= value.pos[var] then
                return
            end
        else
            if r ~= 0 then
                table.insert(parts, r)
            end
        end
        -- print(t)
    end

    if next(parts) then
        table.sort(parts)
        return nil, mul
    end
    return start
end

local function check(hail, test, smallest)
    local x
    local i = 1
    while not z do
        local px, _mul = linear_change(hail, test, i, smallest)
        if px then
            x = i
            -- print("z start: " .. px .. " vel: " .. x)
            return x, px
        end
        i = zig(i)
        -- if i == 4 then break end
    end
end



local function intersect_at3(a, b, c1, c2, mod1, mod2)
    -- print("a", serpent.line2(a))
    -- print("b", serpent.line2(b))
    -- if x_change == 0 then
    --     if a.pos.y == b.pos.y then
    --         return a.pos
    --     end
    --     return
    -- end
    local a_slope = (a.vel[c2] - mod2)/(a.vel[c1] - mod1)
    local b_slope = (b.vel[c2] - mod2)/(b.vel[c1] - mod1)
    local x = ((a_slope * a.pos[c1]) - a.pos[c2] - (b_slope * b.pos[c1]) + b.pos[c2]) / (a_slope - b_slope)
    if x==x and math.abs(x) ~= math.huge
    -- and (x > a.pos[c1]) == ((a.pos[c1] + (a.vel[c1] + mod)) > a.pos[c1])
    -- and (x > b.pos[c1]) == ((b.pos[c1] + b.vel[c1]) > b.pos[c1])
    then
        return x
    end

    -- print(math.abs(x))
end

local function compare_all(hail, c1, c2, mod1, mod2)
    local intersections = {}
    local values = {}
    i = 1
    while i < #hail do
        j = i + 1
        while j <= #hail do
            local intersect = intersect_at3(hail[i], hail[j], c1, c2, mod1, mod2)
            -- print(mod1, mod2, intersect)
            
            if intersect then
                -- print()
                key = intersect // 10000--tostring(intersect)
                if not intersections[key] then
                    intersections[key] = 1
                    if next(intersections, next(intersections)) then
                        -- if c1 == "z" then
                        --     print(serpent.line2(intersections))
                        -- end
                        return
                    end
                else
                    intersections[key] = intersections[key] + 1
                end
                values[key] = intersect
            end
        
            j = j + 1
        end
        i = i + 1
    end

    -- print("end" .. serpent.line2(intersections))
    if not next(intersections, next(intersections)) then
        local k, i = next(intersections)
        if i > 4 then
            print(values[key])
            return values[key]
        end
    end
end

local function comp_dirs(hail, c1, c2, force)
    local max = 500

    for i=-max, max do
        print(i)
        if not force then
            for j=-max, max do
                local k = compare_all(hail, c1, c2, i, j)
                if k then
                    return i, k, j
                end
            end
        else
            local k = compare_all(hail, c1, c2, i, force)
            if k then
                return i, k
            end
        end
    end
end

run["2"] = function ()
    local hail = get_hail()
    
    print("x:")
    local x, xp, y = comp_dirs(hail, "x", "y")
    print("y:")
    local yp = compare_all(hail, "y", "x", y, x)
    print("z:")
    local z, zp = comp_dirs(hail, "z", "y", y)
    print(x, xp)
    print(y, yp)
    print(z, zp)

    return string.format("%18.0f", xp + yp + zp)
end

-- print("Enter Input:")
print(run[arg[1] or "1"]())