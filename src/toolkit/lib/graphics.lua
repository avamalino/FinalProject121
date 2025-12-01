local draft = {}
local g = love.graphics


function draft.line(...)
	g.line(...)
end

-- need work
-- function draft.dashline(p1, p2, dash, gap)
-- 	local dy, dx = p2.y - p1.y, p2.x - p1.x
-- 	local an, st = math.atan2(dy, dx), dash + gap
-- 	local len    = math.sqrt(dx * dx + dy * dy)
-- 	local nm     = (len - dash) / st
-- 	g.push()
-- 	love.gr.translate(p1.x, p1.y)
-- 	gr.rotate(an)
-- 	for i = 0, nm do
-- 		gr.line(i * st, 0, i * st + dash, 0)
-- 	end
-- 	gr.line(nm * st, 0, nm * st + dash, 0)
-- 	gr.pop()
-- end


function draft.triangle_isosceles(mode, cx, cy, width, height)
	local widthRadius = width / 2
	local heightRadius = height / 2
	local x1 = cx
	local y1 = cy - heightRadius
	local x2 = cx + widthRadius
	local y2 = cy + heightRadius
	local x3 = cx - widthRadius
	local y3 = y2
	g.polygon(mode, x1, y1, x2, y2, x3, y3)
end


function draft.triangle_right(mode, cx, cy, width, height)
	local widthRadius = width / 2
	local heightRadius = height / 2
	local x1 = cx - widthRadius
	local y1 = cy - heightRadius
	local x2 = cx + widthRadius
	local y2 = cy + heightRadius
	local x3 = x1
	local y3 = y2
	g.polygon(mode, x1, y1, x2, y2, x3, y3)
end


function draft.rectangle(mode, cx, cy, width, height, iscentered)
	if not iscentered then
		g.rectangle(mode, cx, cy, width, height)
		return
	end
	local widthRadius = width / 2
	local heightRadius = height / 2
	local left = cx - widthRadius
	local right = cx + widthRadius
	local top = cy - heightRadius
	local bottom = cy + heightRadius
	local vertices = { left, top, right, top, right, bottom, left, bottom }
	g.rectangle(mode, vertices[1], vertices[2], width, height)
end


function draft.capsule(mode, cx, cy, width, height, iscentered, roundness_scale) --roundness_scale: 0-1 
    if not iscentered then
		g.rectangle(mode, cx, cy, width, height, height * (roundness_scale or .5))
		return
	end
	local widthRadius = width / 2
	local heightRadius = height / 2
	local left = cx - widthRadius
	local right = cx + widthRadius
	local top = cy - heightRadius
	local bottom = cy + heightRadius
	local vertices = { left, top, right, top, right, bottom, left, bottom }
	g.rectangle(mode, vertices[1], vertices[2], width, height, height * (roundness_scale or .5))
end


function draft.polygon(...)
    g.polygon(...)
end


function draft.rhombus(mode, cx, cy, width, height)
	local widthRadius = width / 2
	local heightRadius = height / 2
	local vertices = {
		cx - widthRadius, cy,
		cx, cy - heightRadius,
		cx + widthRadius, cy,
		cx, cy + heightRadius
	}
	g.polygon(mode, vertices)
end

function draft.circle(mode, cx, cy, diameter, segments)
    g.circle(mode, cx, cy, diameter * .5, segments)
end

function draft.arc(...)
    g.arc(...)
end

function draft.ellipse(...)
	g.ellipse(...)
end


-- Love2D glue

function draft.resize_canvas(s, flags)
	-- width, 
	love.window.setMode(width * s, height * s, flags)
	canvas_scale = s
end

function draft.set_default_filter(...)
	g.setDefaultFilter(...)
end

function draft.set_line_style(style)
	g.setLineStyle(style)
end

function draft.set_line_width(width)
	g.setLineWidth(width)
end

function draft.get_line_width()
	return g.getLineWidth()
end

function draft.print(...)
	g.print(...)
end

function draft.printmid(text, x, y, r, sx, sy)
	g.print(text, x, y, r, sx, sy, g.getFont():getWidth(text)/2, g.getFont():getHeight()/2)
end

function draft.new_canvas(...)
	return g.newCanvas(...)
end

function draft.set_canvas(...)
	g.setCanvas(...)
end

function draft.new_image(filename, settings)
	return g.newImage(filename, settings)
end

function draft.clear(...)
	g.clear(...)
end

function draft.set_blend_mode(mode, alphamode)
	g.setBlendMode(mode, alphamode)
end

function draft.new_font(filename, size)
	return g.newFont(filename, size)
end

function draft.set_font(font)
	g.setFont(font)
end

function draft.get_font()
	return g.getFont()
end

function draft.set_background_color(...)
	g.setBackgroundColor(...)
end

function draft.set_color(...)
	g.setColor(...)
end

function draft.get_color()
	return g.getColor()
end

function draft.draw(...)
	g.draw(...)
end

function draft.pop()
	g.pop()
end

function draft.push(...)
	g.push(...)
end

function draft.translate(...)
	g.translate(...)
end

function draft.rotate(...)
	g.rotate(...)
end

function draft.origin()
	g.origin()
end

function draft.new_shader(...)
	return g.newShader(...)
end

function draft.set_shader(...)
	g.setShader(...)
end


----------------------------------------------------
-- Extra utilities
----------------------------------------------------
function draft.push_rotate_scale(x, y, r, sx, sy)
	local sx = sx or 1
	local sy = sy or sx
	g.push()
	g.translate(x, y)
	g.scale(sx, sy)
	g.rotate(r or 0)
	-- g.translate(-x, -y)
end


draft.point_list = {}

function draft.draw_point_at(x, y)
	table.insert(draft.point_list, {x = x, y = y})
end

function draft.draw_point_list()
	g.setColor(1, 0, 0, 1)
	for _, v in ipairs(draft.point_list) do
		g.circle('fill', v.x, v.y, 5)
	end
	draft.point_list = {}
	g.setColor(1, 1, 1, 1)
end


for k, v in pairs(color.sass) do
    draft[k] = function(alpha)
        color.sass[k][4] = alpha or 1
		g.setColor(color.sass[k])
    end
end

function draft.palette(n)
	g.setColor(color.palette[n])
end


return draft