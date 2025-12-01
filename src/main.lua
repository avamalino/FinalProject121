toolkit = require 'toolkit'

function love.load()
    toolkit:init()
    gamestate.init(require 'rooms.room1')
end

function love.update(dt)
    toolkit:update(dt)
end

function love.draw()
    toolkit:draw()
end

function love.resize(w, h)
    toolkit.resize(w, h)
end

function recursive_enumerate(folder, t)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local info = love.filesystem.getInfo(file)
        if info.type == 'file' then
            table.insert(t, file)
        elseif info.type == 'directory' then
            recursive_enumerate(file, t)
        end
    end
end

function require_files(t)
    for _, file in ipairs(t) do
        local file = file:sub(1, -5)
        require(file)
    end
end
