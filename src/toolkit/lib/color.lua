local color = {}

function color.hex_to_rgb(hex)
    local hex = hex:gsub("#","")
    return {tonumber("0x"..hex:sub(1,2)) / 255, tonumber("0x"..hex:sub(3,4)) / 255, tonumber("0x"..hex:sub(5,6)) / 255}
end

function color.rgb_to_hsl(r, g, b)
    local t = { r, g, b }
    table.sort(t, function(a, b) return a < b end)
    local max, min = t[3], t[1]
    local h, s, l
    l = (min + max) / 2

    if l <= .5 then s = (max - min) / (max + min)
    elseif l > .5 then s = (max - min) / (2 - max - min) end

    if max == r then h = (g - b) / (max - min)
    elseif max == g then h = 2 + (b - r) / (max - min)
    elseif max == b then h = 4 + (r - g) / (max - min) end

    return h, s, l
end

function color.hsl_to_rgb(h, s, l)
    if s <= 0 then return l, l, l end
    h, s, l = h * 6, s, l
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = (1 - math.abs(h % 2 - 1)) * c
    local m, r, g, b = (l - .5 * c), 0, 0, 0
    if h < 1 then r, g, b = c, x, 0
    elseif h < 2 then r, g, b = x, c, 0
    elseif h < 3 then r, g, b = 0, c, x
    elseif h < 4 then r, g, b = 0, x, c
    elseif h < 5 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    return r + m, g + m, b + m
end

function color.lighten(c)
    local h, s, l = color.rgb_to_hsl(unpack(c))
    h = (h * 60 + ((h < 0 and 360) or 0)) / 360
    s = s
    l = l + .1
    return { color.hsl_to_rgb(h, s, l) }
end

function color.darken(c)
    local h, s, l = color.rgb_to_hsl(unpack(c))
    h = (h * 60 + ((h < 0 and 360) or 0)) / 360
    s = s
    l = l - .1
    return { color.hsl_to_rgb(h, s, l) }
end



color.sass = {
    blue = color.hex_to_rgb('0d6efd'),
    indigo = color.hex_to_rgb('6610f2'),
    purple = color.hex_to_rgb('#8082a3'), --modified
    pink = color.hex_to_rgb('d63384'),
    red = color.hex_to_rgb('dc3545'),
    orange = color.hex_to_rgb('fd7e14'),
    yellow = color.hex_to_rgb('ffc107'),
    green = color.hex_to_rgb('198754'),
    teal = color.hex_to_rgb('20c997'),
    cyan = color.hex_to_rgb('0dcaf0'),
    gray = color.hex_to_rgb('adb5bd'),
    lgray = color.hex_to_rgb('E8ECEF'),
    dgray = color.hex_to_rgb('353A40'),
    black = color.hex_to_rgb('000000'),
    white = color.hex_to_rgb('FFFFFF'),
}



for k, v in pairs(color.sass) do
    color[k] = function(alpha)
        color.sass[k][4] = alpha or 1
        return color.sass[k]
    end
end

function color.lerp(from, to, weight)
    local r, g, b
    r = math.lerp(from[1], to[1], weight)
    g = math.lerp(from[2], to[2], weight)
    b = math.lerp(from[3], to[3], weight)
    return {r, g, b}
end


color.palette = {}
-- color.last_palette_modtime = love.filesystem.getInfo('assets/png/palette.png').modtime

-- load palette
-- local imagedata = love.image.newImageData('assets/png/endesga-32-1x.png')
-- local image = love.graphics.newImage(imagedata)
-- for i = 0, image:getWidth()-1 do
--     for j = 0, image:getHeight()-1 do
--         table.insert(color.palette, {imagedata:getPixel(i, j)})
--     end
-- end

-- function color:extract_palette()
--     local imagedata = love.image.newImageData('assets/png/palette.png')
--     local image = love.graphics.newImage(imagedata)
--     local count = 1 -- counter, use manual indexing to be able to update all referenced table instead of making new tables each update
--     for i = 0, image:getWidth()-1 do
--         for j = 0, image:getHeight()-1 do
--             local r, g, b, a = imagedata:getPixel(j, i)
--             color.palette[count][1] = r
--             color.palette[count][2] = g
--             color.palette[count][3] = b
--             color.palette[count][4] = a
--             count = count + 1
--         end
--     end
-- end

-- function color:is_palette_changed()
--     local modtime = love.filesystem.getInfo('assets/png/palette.png').modtime
--     if modtime > self.last_palette_modtime then
--         self.last_palette_modtime = modtime
--         return true
--     end
-- end

return color
