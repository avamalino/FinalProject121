local Vehicle = Object:extend()

function Vehicle:new(x, y, maxspeed, maxforce)
    self.position = vec2(x, y)
    self.velocity = vec2(0, 0)
    self.acceleration = vec2()
    self.friction = .9

    self.r = 20
    self.maxspeed = maxspeed or 1.25 *1
    self.maxforce = maxforce or .125 *1

    self.current_path_point = 1
end

function Vehicle:update(dt)
    if self.acceleration:len() > 0 then
        self.velocity:add(self.acceleration)
        -- limit velocity is done by seek()
    else
        -- self.velocity:scale(self.friction) --dk, but causing some jittery
    end

    self.position:add(self.velocity)
    self.acceleration:set(0, 0)
end

function Vehicle:draw()
    local angle = math.atan2(self.velocity.y, self.velocity.x)
    graphics.push_rotate_scale(self.position.x, self.position.y, angle)
    love.graphics.polygon('fill', self.r * 2, 0, -self.r * 2, -self.r, -self.r * 2, self.r)
    graphics.pop()

    graphics.circle('line', self.position.x, self.position.y, 100)
end

function Vehicle:apply_force(force)
    self.acceleration:add(force)
end

function Vehicle:seek(target, slows_at_radius)
    local desired = target - self.position
    local d = desired:len()
    
    if slows_at_radius and d < slows_at_radius then
        desired:normalize():scale(math.remap(d, 0, slows_at_radius, 0, self.maxspeed))
    else
        desired:normalize():scale(self.maxspeed)
    end
    
    local steer = desired:sub(self.velocity)
    if steer:len() > self.maxforce then steer:normalize():scale(self.maxforce) end

    self:apply_force(steer)
end


function Vehicle:get_seek(target, slows_at_radius)
    local desired = target - self.position
    local d = desired:len()
    
    if slows_at_radius and d < slows_at_radius then
        desired:normalize():scale(math.remap(d, 0, slows_at_radius, 0, self.maxspeed))
    else
        desired:normalize():scale(self.maxspeed)
    end
    
    local steer = desired:sub(self.velocity)
    if steer:len() > self.maxforce then steer:normalize():scale(self.maxforce) end

    return steer
end


function Vehicle:follow(path)
    if self.position:dist(path[self.current_path_point]) < 20 then
        self.current_path_point = math.clamp(self.current_path_point + 1, 1, #path)
    end
    self:seek(path[self.current_path_point], self.current_path_point == #path)
end


function Vehicle:reset_path()
    self.current_path_point = 2
end

function Vehicle:separate(others)
    local desired_separation = self.r * 2
    local sum = vec2()
    local count = 0

    for _, v in ipairs(others) do
        local d = self.position:dist(v.position)
        if self ~= v and d < desired_separation then
            local diff = self.position - v.position
            diff:normalize():scale(1/d)
            sum:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        sum = sum /count
        sum:normalize():scale(self.maxspeed)
        sum:sub(self.velocity)
        if sum:len() > self.maxforce then sum:normalize():scale(self.maxforce) end
    end
    self:apply_force(sum)
end


function Vehicle:get_separate(others)
    local desired_separation = self.r * 2
    local sum = vec2()
    local count = 0

    for _, v in ipairs(others) do
        local d = self.position:dist(v.position)
        if self ~= v and d < desired_separation then
            local diff = self.position - v.position
            diff:normalize():scale(1/d)
            sum:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        sum = sum /count
        sum:normalize():scale(self.maxspeed)
        sum:sub(self.velocity)
        if sum:len() > self.maxforce then sum:normalize():scale(self.maxforce) end
    end
    return sum
end


function Vehicle:seek_separate(target, slows_at_radius, others)
    local separate_force = self:get_separate(others)
    local seek_force = self:get_seek(target, slows_at_radius)

    separate_force:scale(.5)
    seek_force:scale(.5)

    self:apply_force(separate_force)
    self:apply_force(seek_force)
end


function Vehicle:follow_separate(path, slows_at_radius, others)
    if self.position:dist(path[self.current_path_point]) < 20 then
        self.current_path_point = math.clamp(self.current_path_point + 1, 1, #path)
    end
    self:seek_separate(path[self.current_path_point], (self.current_path_point == #path and slows_at_radius) or false, others)
end


return Vehicle