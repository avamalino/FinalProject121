local theme = require('theme')

Ending = {}

function Ending:enter()
    if toolkit and toolkit.time then
        toolkit.time:pause()
    end
    self.background_color = { 0.596, 0.984, 0.596 } -- soft green
end

function Ending:update(dt)
end

function Ending:draw()
    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.setDepthMode("always", false)

    -- background
    love.graphics.clear(self.background_color[1], self.background_color[2], self.background_color[3], 1)

    local r, g, b, a = theme.getTextColor()
    love.graphics.setColor(r, g, b, a)

    local defaultFont = love.graphics.newFont(36)
    love.graphics.setFont(defaultFont)
    love.graphics.printf(
        "Congrats! You Won!",
        0,
        love.graphics.getHeight() / 2 - 50,
        love.graphics.getWidth(),
        'center'
    )

    love.graphics.printf(
        "Press [ESC] to Exit",
        0,
        love.graphics.getHeight() / 2 + 50,
        love.graphics.getWidth(),
        'center'
    )

    love.graphics.setColor(1, 1, 1, 1)
end

function Ending:exit()
    toolkit.time:resume()
end

return Ending
