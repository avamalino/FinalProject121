local profiler = {}


local global_type_table = nil
local function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k, v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end
local function count_all(f)
	local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k, v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end
local function type_count()
	local counts = {}
	local enumerate = function(o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end


function profiler:load(font)
	self.main_canvas = love.graphics.newCanvas()
	self.font_height = font:getHeight() * 1.2
	self.show = false
	self.height = self.font_height
	self.timer = 0
end

function profiler:draw()
	if self.show then
		self.timer = self.timer + love.timer.getDelta()
		if self.timer >= 1 then
			self.timer = 0
			self:count()
		end
		love.graphics.setColor(0, 0, 0, .5)
		love.graphics.rectangle('fill', 0, 0, width/2, self.height)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.main_canvas, 10, 10)
	end
end

function profiler:count()
	love.graphics.setCanvas(self.main_canvas)
	love.graphics.clear()
	-- print memory usage
	love.graphics.print("Memory used: " .. collectgarbage("count") / 1024 .. " MB", 0, 0)

	local counts = type_count()
	-- print table first
	love.graphics.print('table	' .. tostring(table.removekey(counts, 'table')), 0, self.font_height)
	-- sort counts by name
	local tkeys = {}
	for k, _ in pairs(counts) do table.insert(tkeys, k) end
	table.sort(tkeys)
	local i = 2
	for _, k in ipairs(tkeys) do
		love.graphics.print(tostring(k) .. "	" .. tostring(counts[k]), 0, i * self.font_height)
		i = i + 1
	end
	love.graphics.setCanvas()
	self.height = 32 + self.font_height * i
end

function profiler:set_show(bool)
	self.show = bool
	if self.show then self:count() end
end

return profiler
