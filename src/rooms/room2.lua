Room2 = {}

function Room2:enter()
    if toolkit and toolkit.time then
        toolkit.time:pause()
    end
    self.background_color = {0, 1, 0}

end


function Room2:update(dt)

end

function Room2:draw()
    local state = require "../state" -- double check
    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.setDepthMode("always", false)

    -- green background
    love.graphics.clear(0.596, 0.984, 0.596, 1)
    love.graphics.setColor(0,0,0)
    
    local defaultFont = love.graphics.newFont(36)
    love.graphics.setFont(defaultFont)
    love.graphics.printf(
        "Congrats! You Won!",
        0,
        love.graphics.getHeight() / 2 -50,
        love.graphics.getWidth(),
        'center'
    )

    love.graphics.setFont(defaultFont)
    love.graphics.printf(
        "Press [ESC] to Exit",
        0,
        love.graphics.getHeight() /2 + 50,
        love.graphics.getWidth(),
        'center'
    )
   
end

function Room2:exit()
    toolkit.time:resume()
end

return Room2
