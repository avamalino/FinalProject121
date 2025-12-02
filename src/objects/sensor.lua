local Sensor = Object:extend()

function Sensor:new(owner, x, y, z)
    self.owner = owner
    self.translation = vec3(x, y, z)
    self.radius = 0.5 -- Detection radius
    self.activated = false
end

function Sensor:update(dt)
    -- Check if pushable is on the sensor
    if self.owner.pushable then
        local pushable = self.owner.pushable
        local dx = pushable.translation.x - self.translation.x
        local dz = pushable.translation.z - self.translation.z
        local dist = math.sqrt(dx * dx + dz * dz)

        -- Activate if pushable is close enough
        if dist < self.radius then
            self.activated = true
        else
            self.activated = false
        end
    end
end

function Sensor:draw()
    -- Set color tint based on activation state
    if self.activated then
        love.graphics.setColor(0, 1, 0, 1) -- Green when activated
    else
        love.graphics.setColor(1, 0, 0, 1) -- Red when not activated
    end

    pass.push()
    pass.translate(self.translation)
    pass.scale(0.2, 0.1, 0.2) -- Make it flat like a pressure plate

    -- Draw a simple cube (will look like a flat plate due to scaling)
    pass.cube()

    pass.pop()

    -- Reset color to white
    love.graphics.setColor(1, 1, 1, 1)
end

return Sensor
