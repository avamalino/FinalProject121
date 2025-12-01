-- Copyright (c) 2012-2013 Matthias Richter (with some modifications)


local Signal = Object:extend()

function Signal:new(...)
    self.list = {}
    for _, v in ipairs({...}) do
        self.list[v] = {}
    end
end


function Signal:register(s, f)
    assert(self.list[s], 'signal: tag not found.')
    self.list[s][f] = f
end

function Signal:emit(s, ...)
    assert(self.list[s], 'signal: tag not found.')
	for f in pairs(self.list[s]) do
		f(...)
	end
end

function Signal:emit_eatable(s, ...)
    assert(self.list[s], 'signal: tag not found.')
	for f in pairs(self.list[s]) do
		if f(...) then return end
	end
end

function Signal:emit_eatable_returned(s, ...)
    assert(self.list[s], 'signal: tag not found.')
	for f in pairs(self.list[s]) do
		local returned = f(...)
		if returned then return returned end
	end
end

function Signal:remove(s, ...)
	local f = {...}
	for i = 1, select('#', ...) do
		self.list[s][f[i]] = nil
	end
end

function Signal:clear(...)
	local s = {...}
	for i = 1,select('#', ...) do
		self.list[s[i]] = {}
	end
end


return Signal