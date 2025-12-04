Ending = {}

function Ending:enter()
    if toolkit and toolkit.time then
        toolkit.time:pause()
    end
    self.background_color = { 0, 1, 0 }
end

function Ending:update(dt)

end

function Ending:draw()
    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.setDepthMode("always", false)

    -- green background
    love.graphics.clear(0.596, 0.984, 0.596, 1)
    love.graphics.setColor(0, 0, 0)

    love.graphics.setFont(specialFont)
    love.graphics.printf(
        "Congrats! You Won!",
        0,
        love.graphics.getHeight() / 2 - 50,
        love.graphics.getWidth(),
        'center'
    )

    love.graphics.setFont(specialFont)
    love.graphics.printf(
        "Press [ESC] to Exit",
        0,
        love.graphics.getHeight() / 2 + 50,
        love.graphics.getWidth(),
        'center'
    )
end

function Ending:exit()
    toolkit.time:resume()
end

return Ending
