-- placeholder functionalities. fairly limited, but just enough for this purpose.
--[[
    room: enter(), exit(), init(), destroy() -- the last 2 haven't implemented yet
]]

local gemstet = {}
gemstet.cur = nil
gemstet.queue = {}

function gemstet.init(cur, ...)
    gemstet.cur = cur
    gemstet.cur:enter(nil, ...)
end

function gemstet.switch(next, ...)
    table.insert(gemstet.queue, next)
    table.insert(gemstet.queue, { ... })
end

function gemstet.current()
    return gemstet.cur
end

function gemstet.update(dt)
    gemstet.cur:update(dt)
end

function gemstet.draw()
    gemstet.cur:draw()

    if #gemstet.queue > 0 then
        local prev = gemstet.cur
        if prev then prev:exit() end
        gemstet.cur = gemstet.queue[1]
        gemstet.cur:enter(prev, unpack(gemstet.queue[2]))
        gemstet.queue = {}
    end
end

function gemstet.register_events(callbacks)
    local old_functions = {}
    local empty_function = function() end
    for _, f in ipairs(callbacks) do
        old_functions[f] = love[f] or empty_function
        love[f] = function(...)
            old_functions[f](...)
            if gemstet.cur[f] then gemstet.cur[f](gemstet.cur, ...) end
        end
    end
end

return gemstet
