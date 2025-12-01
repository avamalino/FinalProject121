local utf8 = require 'utf8'
local ConsoleLine = Object:extend()

function ConsoleLine:new(t)
    self.text_format = t
    self.line_frags = {}
    self.text = {}
    self.i = 1

    self:set_line_frags()
    self:add_text_until(self.i)
    timer:every(.02, function()
            self.i = self.i + 4 -- how many the text added up every .02 tick
            for j = self.i - 3, self.i do self:add_text_until(j) end
        end,
        { breaker = function() return self.i >= #self.line_frags end }
    )
end

function ConsoleLine:set_line_frags()
    for i = 1, #self.text_format, 2 do -- 2 because the self.text_format is a table containing {color, text}, so this'll skip the color part of it
        for j = 1, utf8.len(self.text_format[i + 1]) do
            table.insert(self.line_frags, {
                character = self.text_format[i + 1]:sub(j, j),
                color = self.text_format[i],
            })
        end
    end
end

function ConsoleLine:add_text_until(i)
    if i > #self.line_frags then return end
    table.insert(self.text, self.line_frags[i].color)
    table.insert(self.text, self.line_frags[i].character)
end



local console = {}

function console:load(font)
    love.keyboard.setKeyRepeat(true)

    -- local old_draw_function = .draw
    -- .draw = function(...)
    --     old_draw_function(...)
    --     self:draw()
    -- end

    local old_keypressed_function = love.keypressed
    love.keypressed = function(...)
        old_keypressed_function(...)
        self:keypressed(...)
    end

    self.show = false
    self.line = {}
    self.line_padding = 20
    self.line_y = height - self.line_padding * 2 - 10 -- because the lowest line is gonna be the input line
    self.raw_input_text = {}
    self.formatted_input_text = { ':' }
    self.font = font
    self.timer = Timer(self)

    -- blinking cursor
    self.cursor_visible = true
    self.timer:every(0.5, function() self.cursor_visible = not self.cursor_visible end, 0, nil, 'cursor')
end

function console:update(dt)
    self.timer:update(dt)
end

function console:draw()
    graphics.print(self.formatted_input_text, 10, height - self.line_padding - 10)
    for i = #self.line, 1, -1 do
        local line = self.line[i]
        graphics.print(line.text, 10, self.line_y - (self.line_padding * (#self.line - i)))
    end

    if self.cursor_visible then
        graphics.set_color(1, 1, 1, 1)
        -- calc x position
        local input_text = ''
        for _, character in ipairs(self.raw_input_text) do input_text = input_text .. character end
        local x = 10 + self.font:getWidth('> ' .. input_text)
        graphics.rectangle('fill', x, height - self.line_padding - 10,
            self.font:getWidth('w'), self.font:getHeight())
    end
end

function console:textinput(t)
    if self.show then
        if #self.raw_input_text < 30 then
            if not ((t == ' ') and (#self.raw_input_text == 0)) then 
                table.insert(self.raw_input_text, t)
            end
        end
        self:format_input_text()
    end
end

function console:keypressed(key)
    if self.show then
        if key == 'backspace' then
            if love.keyboard.isDown('lctrl') then
                self.raw_input_text = {}
                self.formatted_input_text = { ':' }
            else
                table.remove(self.raw_input_text, #self.raw_input_text)
                self:format_input_text()
            end
        elseif key == 'return' then
            local raw_input_text = ''
            for _, character in ipairs(self.raw_input_text) do raw_input_text = raw_input_text .. character end
            self:execute_input(raw_input_text)
            self.raw_input_text = {}
            self.formatted_input_text = { ':' }
        end
    end
end

function console:format_input_text()
    local base_input_format = { ': ' }
    local raw_input_text = ''
    for _, character in ipairs(self.raw_input_text) do
        raw_input_text = raw_input_text .. character
    end
    table.insert(base_input_format, color.hex_to_rgb('#9defff'))
    table.insert(base_input_format, raw_input_text)
    self.formatted_input_text = base_input_format

    self.cursor_visible = true
    self.timer:every(0.5, function() self.cursor_visible = not self.cursor_visible end, 0, nil, 'cursor' )
end

function console:add_line(text)
    table.insert(self.line, ConsoleLine(text))
    if #self.line > 30 then
        table.remove(self.line, 1)
    end
end

function console:return_command(c, description)
    self:add_line({ color.hex_to_rgb('ffc107'), c, color.hex_to_rgb('FFFFFF'), ': ' .. description })
end

function console:execute_input(input_text)
    if input_text == '' then
        self:add_line({ color.hex_to_rgb('ffc107'), '.' }) -- empty line
    elseif input_text == 'clear' then
        self.line = {}
    -- elseif input_text == 'playground' then
    --     gamestate.switch(playground)
    -- elseif input_text == 'level_1' then
    --     gamestate.switch(level_1)
    -- elseif input_text == 'editor' then
    --     local current_state = gamestate.current()
    --     if table.contains({level_1}, current_state) then
    --         gamestate.switch(level_editor, current_state)
    --     else
    --         self:return_command(input_text, 'invalid level in current state')
    --         return
    --     end
    elseif input_text == 'exit' then
        love.event.quit()
    else --invalid command
        local string = input_text
        if #self.raw_input_text > 8 then string = input_text:sub(1, 8) .. "..." end
        self:return_command(string, 'command not found')
    end
end

return console
