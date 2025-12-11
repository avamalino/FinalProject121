-- Global inventory system
Inventory = {
    items = {},
    visible = false,

    name = "Inventory",

    size = 64,
    spacing = 74,
    pad = 20,

    popup_w = 500,
    popup_h = 350,
    cols = 5,
    cell = 64,
    cell_pad = 12,

    footer_text = "Hit ESC to close",
    show_item_names = true,
}

function Inventory:add(item_name)
    table.insert(self.items, item_name)
end

function Inventory:has(item_name)
    for _, item in ipairs(self.items) do
        if item == item_name then
            return true
        end
    end
    return false
end

function Inventory:remove(item_name)
    for i, item in ipairs(self.items) do
        if item == item_name then
            table.remove(self.items, i)
            return true
        end
    end
    return false
end

function Inventory:clear()
    self.items = {}
end

function Inventory:toggle()
    self.visible = not self.visible
end

function Inventory:hide()
    self.visible = false
end

function Inventory:show()
    self.visible = true
end

function Inventory:draw()
    graphics.set_shader()
    love.graphics.setDepthMode('always', false)

    if not self.visible then return end

    local sw, sh = love.graphics.getDimensions()

    -- Popup Location
    local x = (sw - self.popup_w) / 2
    local y = (sh - self.popup_h) / 2

    -- Background
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Panel
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", x, y, self.popup_w, self.popup_h)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, self.popup_w, self.popup_h)

    -- Grid
    local cols = self.cols
    local cell = self.cell
    local pad = self.cell_pad

    for i, item in ipairs(self.items) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)

        local cx = x + pad + col * (cell + pad)
        local cy = y + pad + row * (cell + pad)

        -- Draw cell background
        love.graphics.setColor(0.3, 0.3, 0.4, 0.8)
        love.graphics.rectangle("fill", cx, cy, cell, cell)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", cx, cy, cell, cell)

        -- Inventory Title
        if self.name then
            love.graphics.setColor(1, 1, 1, 1)
            local font = love.graphics.getFont()
            local tw = font:getWidth(self.name)

            love.graphics.print(
                self.name,
                x + (self.popup_w - tw) / 2,   -- centered
                y + self.cell_pad              -- slight top padding
            )
        end

        -- Draw item image --> need to draw in 3D
        if item.image then
            local scale = cell / item.image:getWidth()
            love.graphics.draw(item.image, cx, cy, 0, scale)
        end

        -- Draw item name + on hover, show description of item
        -- implement this later
    end

    -- Item count text
    local count_text = string.format("%d Items", #self.items)
    local font = love.graphics.getFont()
    local cw = font:getWidth(count_text)

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.print(
        count_text,
        x + self.popup_w - cw - self.cell_pad,
        y + self.cell_pad
    )

    -- Footer
    love.graphics.setColor(1, 1, 1, 0.9)
    local ft = self.footer_text
    local font = love.graphics.getFont()
    local fw = font:getWidth(ft)
    local fh = font:getHeight()

    love.graphics.print(
        ft,
        x + (self.popup_w - fw) / 2,
        y + self.popup_h - fh - self.cell_pad
    )

end

return Inventory