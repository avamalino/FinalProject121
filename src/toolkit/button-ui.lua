local ButtonUI = {}

function ButtonUI:draw_button(button)
    if not button.visible then
        return
    end

    -- Fill
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 8)

    -- Border
    love.graphics.setColor(0, 0.3, 0, 1)
    love.graphics.rectangle("line", button.x, button.y, button.w, button.h, 8)

    -- Text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(
        button.text,
        specialFont,
        button.x,
        button.y + button.h / 2 - 8,
        button.w,
        "center"
    )
end

function ButtonUI:draw_buttons(button_list)
    for _, button in ipairs(button_list) do
        self:draw_button(button)
    end
end

function ButtonUI:draw_all(buttons_table)
    for name, button in pairs(buttons_table) do
        self:draw_button(button)
    end
end

return ButtonUI
