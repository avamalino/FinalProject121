toolkit = require 'toolkit'
Inventory = require 'inventory'
UndoStack = require 'undo-stack'

function love.load()
    toolkit:init()

    input:bind('w', 'up')
    input:bind('s', 'down')
    input:bind('a', 'left')
    input:bind('d', 'right')
    input:bind('up', 'up')
    input:bind('down', 'down')
    input:bind('right', 'right')
    input:bind('left', 'left')
    input:bind('space', 'interact')
<<<<<<< HEAD
    Joystick = require('objects.touchJoystick')
=======
    input:bind('z', 'undo')

>>>>>>> refs/remotes/origin/main
    gamestate.init(Room1)

    love.window.setVSync(true)
end

function love.update(dt)
    toolkit:update(dt)
end

function love.draw()
    toolkit:draw()
end

function love.resize(w, h) end

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
