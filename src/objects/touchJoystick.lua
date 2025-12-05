local collision = require(pigic.collision)

local touchJoystick = {}
touchJoystick.__index = touchJoystick

-- Create the joystick instance
function touchJoystick:new()
    local self = setmetatable({}, touchJoystick)

    self.joystick = {
        paddle = { x = 0, y = 0, radius = 50 },
        scrollArea = { x = 0, y = 0, radius = 100 },
        sensing = { motion = { x = function() return 0 end, y = function() return 0 end } }
    }

    self.offsetX = 125 -- horizontal distance from left
    self.offsetY = 125 -- vertical distance from bottom

    return self
end

-- Initialize joystick positions
function touchJoystick:load()
    self:updatePositions()
end

-- Update joystick position relative to screen
function touchJoystick:updatePositions()
    local screenHeight = love.graphics.getHeight()
    self.joystick.scrollArea.x = self.offsetX
    self.joystick.scrollArea.y = screenHeight - self.offsetY
    self.joystick.paddle.x = self.offsetX
    self.joystick.paddle.y = screenHeight - self.offsetY
end

-- Update joystick input
function touchJoystick:update(dt)
    self:updatePositions() -- ensure position is correct for screen height

    local joystick = self.joystick
    local touchX, touchY = joystick.scrollArea.x, joystick.scrollArea.y

    -- Touch input
    for _, id in ipairs(love.touch.getTouches()) do
        touchX, touchY = love.touch.getPosition(id)
    end

    -- Mouse input
    if love.mouse.isDown(1) then
        touchX, touchY = love.mouse.getPosition()
    end

    -- Clamp paddle inside scroll area
    local dx = touchX - joystick.scrollArea.x
    local dy = touchY - joystick.scrollArea.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < joystick.scrollArea.radius then
        joystick.paddle.x = touchX
        joystick.paddle.y = touchY
    else
        local angle = math.atan2(dy, dx)
        joystick.paddle.x = joystick.scrollArea.x + math.cos(angle) * joystick.scrollArea.radius
        joystick.paddle.y = joystick.scrollArea.y + math.sin(angle) * joystick.scrollArea.radius
    end

    -- Update sensing motion
    joystick.sensing.motion.x = function()
        return (joystick.paddle.x - joystick.scrollArea.x) / joystick.scrollArea.radius
    end
    joystick.sensing.motion.y = function()
        return (joystick.paddle.y - joystick.scrollArea.y) / joystick.scrollArea.radius
    end
end

-- Draw the joystick
function touchJoystick:draw()
    if not self.joystick then return end

    local j = self.joystick

    -- Draw scroll area
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.circle("fill", j.scrollArea.x, j.scrollArea.y, j.scrollArea.radius)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("line", j.scrollArea.x, j.scrollArea.y, j.scrollArea.radius)

    -- Draw paddle
    love.graphics.circle("fill", j.paddle.x, j.paddle.y, j.paddle.radius)
end

-- Handle window resize
function touchJoystick:resize()
    self:updatePositions()
end

-- Create and return the singleton instance
local joystick_instance = touchJoystick:new()
joystick_instance:load()
return joystick_instance

--local touchJoystick = {}
--touchJoystick.__index = touchJoystick
----joystick attempt from https://www.youtube.com/watch?v=iT7UCzWByGo
--
--function touchJoystick:new()
--    local self = setmetatable({}, touchJoystick)
--
--    self.joystick = {
--        paddle = {x=0, y = 0},
--        scrollArea = {x=0, y=0},
--        sensing = { motion = {x= function() return 0 end, y= function() return 0 end} }
--    }
--    return self
--end
--
--function touchJoystick:load()
--    local joystick = {}
--    self.joystick = joystick
--
--    joystick.paddle = {
--        radius = 50,
--        position = {
--            x = 125,
--            y = love.graphics.getHeight() - 125
--        }
--    }
--
--    function joystick.paddle.draw()
--        --local colorTable = {love.graphics.getColor()}
--        --love.graphics.setColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
--        --love.graphics.circle("fill", joystick.paddle.position.x, joystick.paddle.position.y, joystick.paddle.radius)
--        love.graphics.circle("fill",
--            joystick.paddle.position.x,
--            joystick.paddle.position.y,
--            joystick.paddle.radius
--        )
--    end
--
--    joystick.scrollArea = {
--        radius = 100,
--        position = {
--            x = 125,
--            y = love.graphics.getHeight() - 125
--        }
--    }
--
--    function joystick.scrollArea.draw()
--        --local colorTable = {love.graphics.getColor()}
--        --love.graphics.setColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4] * 0.5)
--        --love.graphics.circle("fill", joystick.scrollArea.position.x, joystick.scrollArea.position.y, joystick.scrollArea.radius)
--        --love.graphics.setColor(colorTable[1], colorTable[2], colorTable[3], colorTable[4])
--        --love.graphics.circle("line", joystick.scrollArea.position.x, joystick.scrollArea.position.y, joystick.scrollArea.radius)
--        love.graphics.setColor(1,1,1,0.3)
--        love.graphics.circle("fill",
--            joystick.scrollArea.position.x,
--            joystick.scrollArea.position.y,
--            joystick.scrollArea.radius
--        )
--        love.graphics.setColor(1,1,1,1)
--        love.graphics.circle("line",
--            joystick.scrollArea.position.x,
--            joystick.scrollArea.position.y,
--            joystick.scrollArea.radius
--        )
--    end
--
--    joystick.sensing = {}
--    joystick.sensing.motion = {}
--    function joystick.sensing.motion.x()
--        return ((joystick.scrollArea.position.x - joystick.paddle.position.x) * -1)
--    end
--    function joystick.sensing.motion.y()
--        return ((joystick.scrollArea.position.y - joystick.paddle.position.y) * -1)
--    end
--end
--
--function touchJoystick:update(dt)
--    -- This function can be expanded to update joystick state if needed
--    local joystick = self.joystick
--    if not joystick then return end
--
--    local touch_x, touch_y = joystick.scrollArea.position.x, joystick.scrollArea.position.y
--
--    for _, id in ipairs(love.touch.getTouches()) do
--        touch_x, touch_y = love.touch.getPosition(id)
--    end
--
--    if love.mouse.isDown(1) then
--        touch_x, touch_y = love.mouse.getPosition()
--    end
--
--    -- clamp paddle inside scroll area
--    local dx = touch_x - joystick.scrollArea.position.x
--    local dy = touch_y - joystick.scrollArea.position.y
--    local dist = math.sqrt(dx*dx + dy*dy)
--
--    if dist < joystick.scrollArea.radius then
--        joystick.paddle.position.x = touch_x
--        joystick.paddle.position.y = touch_y
--    else
--        local angle = math.atan2(dy, dx)
--        joystick.paddle.position.x =
--            joystick.scrollArea.position.x + math.cos(angle) * joystick.scrollArea.radius
--        joystick.paddle.position.y =
--            joystick.scrollArea.position.y + math.sin(angle) * joystick.scrollArea.radius
--    end
--end
--
--function touchJoystick:draw()
--    if not self.joystick then return end
--    love.graphics.setColor(1,1,1,0.3)
--    self.joystick.scrollArea.draw()
--    love.graphics.setColor(1,1,1,1)
--    self.joystick.paddle.draw()
--end
--
--local joystick_instance = touchJoystick:new()
--joystick_instance:load()
--
--return joystick_instance