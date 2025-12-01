local Vehicle3D = Object:extend()

function Vehicle3D:new(x, y, z, movespeed, maxforce)
    self.translation = vec3(x, y, z)
    self.velocity = vec3()
    self.acceleration = vec3()
    self.friction = 10

    self.r = 2
    self.movespeed = movespeed or 1.25
    self.maxforce = maxforce or .125

    self.current_path_point = 1
end

function Vehicle3D:update(dt)
    if self.acceleration:len() > 0 then
        -- self.velocity:add(self.acceleration)
        self.velocity.x = self.velocity.x + self.acceleration.x * dt
        self.velocity.y = self.velocity.y + self.acceleration.y * dt
        self.velocity.z = self.velocity.z + self.acceleration.z * dt
    else
        -- limit velocity is done by seek()
        self.velocity:scale(self.friction) --dk, but causing some jittery
    end
    
    -- self.translation:add(self.velocity)
    self.translation.x = self.translation.x + self.velocity.x * dt
    self.translation.y = self.translation.y + self.velocity.y * dt
    self.translation.z = self.translation.z + self.velocity.z * dt
    self.acceleration:set(0, 0, 0)
end


function Vehicle3D:apply_force(force)
    self.acceleration:add(force)
end

function Vehicle3D:seek(target, slows_at_radius)
    local desired = target - self.translation
    local d = desired:len()
    
    if slows_at_radius and d < slows_at_radius then
        desired:normalize():scale(math.remap(d, 0, slows_at_radius, 0, self.movespeed))
    else
        desired:normalize():scale(self.movespeed)
    end
    
    local steer = desired:sub(self.velocity)
    if steer:len() > self.maxforce then steer:normalize():scale(self.maxforce) end

    self:apply_force(steer)
end


function Vehicle3D:get_seek(target, slows_at_radius)
    local desired = target - self.translation
    local d = desired:len()
    
    if slows_at_radius and d < slows_at_radius then
        desired:normalize():scale(math.remap(d, 0, slows_at_radius, 0, self.movespeed))
    else
        desired:normalize():scale(self.movespeed)
    end
    
    local steer = desired:sub(self.velocity)
    if steer:len() > self.maxforce then steer:normalize():scale(self.maxforce) end

    return steer
end


function Vehicle3D:follow(path)
    if self.translation:dist(path[self.current_path_point]) < 20 then
        self.current_path_point = math.clamp(self.current_path_point + 1, 1, #path)
    end
    self:seek(path[self.current_path_point], self.current_path_point == #path)
end


function Vehicle3D:reset_path()
    self.current_path_point = 2
end

function Vehicle3D:separate(others)
    local desired_separation = self.r * 2
    local sum = vec3()
    local count = 0

    for _, v in ipairs(others) do
        local d = self.translation:dist(v.translation)
        if self ~= v and d < desired_separation then
            local diff = self.translation - v.translation
            diff:normalize():scale(1/d)
            sum:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        sum = sum /count
        sum:normalize():scale(self.movespeed)
        sum:sub(self.velocity)
        if sum:len() > self.maxforce then sum:normalize():scale(self.maxforce) end
    end
    self:apply_force(sum)
end


function Vehicle3D:get_separate(others)
    local desired_separation = self.r * 2
    local sum = vec3()
    local count = 0

    for _, v in ipairs(others) do
        local d = self.translation:dist(v.translation)
        if self ~= v and d < desired_separation then
            local diff = self.translation - v.translation
            diff:normalize():scale(1/d)
            sum:add(diff)
            count = count + 1
        end
    end

    if count > 0 then
        sum = sum /count
        sum:normalize():scale(self.movespeed)
        sum:sub(self.velocity)
        if sum:len() > self.maxforce then sum:normalize():scale(self.maxforce) end
    end
    return sum
end


function Vehicle3D:seek_separate(target, slows_at_radius, others)
    local separate_force = self:get_separate(others)
    local seek_force = self:get_seek(target, slows_at_radius)

    separate_force:scale(.5)
    seek_force:scale(.5)

    self:apply_force(separate_force)
    self:apply_force(seek_force)
end


function Vehicle3D:follow_separate(path, slows_at_radius, others)
    if self.translation:dist(path[self.current_path_point]) < 20 then
        self.current_path_point = math.clamp(self.current_path_point + 1, 1, #path)
    end
    self:seek_separate(path[self.current_path_point], (self.current_path_point == #path and slows_at_radius) or false, others)
end

return Vehicle3D