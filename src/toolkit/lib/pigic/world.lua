local World = Object:extend()

local function add_point(body, t, t_old)
    table.insert(body.points, {
        t = t,
        t_old = t_old and t_old:add(t) or t:clone()
    })
end

local function add_stick(body, ia, ib)
    table.insert(body.sticks, {
    pa = body.points[ia],
    pb = body.points[ib],
    len = body.points[ia].t:dist(body.points[ib].t)
    })
end


function World:new()
    self.tick_period = 1/60 -- seconds per tick
    self.accumulator = 0

	self.bounce = .9
	self.gravity = 1.2
	self.friction = .9

    self.bodies = {}
end

function World:update(dt)
    -- update physics at constant rate, independent to FPS
	self.accumulator = self.accumulator + dt
    if self.accumulator >= self.tick_period then
        self.accumulator = self.accumulator - self.tick_period
      -- Here be your fixed timestep.
		self:update_points()
		for i = 1, 3 do
			self:update_sticks()
			self:constrain_points()		
		end	
    end
end

function World:draw()
    self:draw_points()
    self:draw_sticks()
end


function World:update_points()
    for object, body in pairs(self.bodies) do
        if body.type == 'rigid' then
            for _, p in ipairs(body.points) do
                local vel = (p.t - p.t_old) * self.friction
                p.t_old:set(p.t)
                p.t:add(vel)
                p.t:add(0, self.gravity, 0)
            end
        end
    end
end

function World:draw_points()
    for object, body in pairs(self.bodies) do
        for _, p in ipairs(body.points) do 
            pass.push()
            -- draw ballz
            pass.translate(p.t)
            pass.scale(body.radius or 5)
            pass.sphere()
            pass.pop()
        end
    end
end

function World:update_sticks()
    for object, body in pairs(self.bodies) do
        if body.type == 'rigid' then
            if body.sticks then
                for _, s in ipairs(body.sticks) do
                    local dist = s.pa.t:dist(s.pb.t)
                    local diff = s.len - dist
                    local percent = diff / dist / 2
                    local dir = s.pb.t - s.pa.t
                    local offset = dir:scale(percent)
                    
                    s.pa.t:sub(offset)
                    s.pb.t:add(offset)
                end
            end
        end
    end
end

function World:draw_sticks()
    for object, body in pairs(self.bodies) do
        if body.sticks then
            for _, s in ipairs(body.sticks) do
                pass.line(s.pa.t, s.pb.t, 5)
            end
        end
    end
end

function World:constrain_points()
    for object, body in pairs(self.bodies) do
        if body.type == 'rigid' then
            for _, p in ipairs(body.points) do
                local vel = (p.t - p.t_old) * self.friction
                --[[
                local hw, hl = 1000/2, 1000/2  -- half width, half length
                if p.t.x > hw then
                    p.t.x = hw
                    p.t_old.x = p.t.x + vel.x * self.bounce
                elseif p.t.x < -hw then
                    p.t.x = -hw
                    p.t_old.x = p.t.x + vel.x * self.bounce
                end
                if p.t.z > hl then
                    p.t.z = hl
                    p.t_old.z = p.t.z + vel.z * self.bounce
                elseif p.t.z < -hl then
                    p.t.z = -hl
                    p.t_old.z = p.t.z + vel.z * self.bounce
                end
                ]]
                if p.t.y > 0 then
                    p.t.y = 0
                    p.t_old.y = p.t.y + vel.y * self.bounce
                    p.t_old.x = p.t.x + vel.x * self.friction
                    p.t_old.z = p.t.z + vel.z * self.friction
                end
            end
        end
    end
end

function World:set_type(object, type)
    assert(type == 'rigid' or type == 'kinematic', 'ERROR (World.set_type): type must be \'rigid\' or \'kinematic\'')
    self.bodies[object].type = type
    if type == 'rigid' then
        for _, p in ipairs(self.bodies[object].points) do
            p.t_old:set(p.t)
        end
    end
end

function World:get_type(object)
    return self.bodies[object].type
end

function World:ball(object, translation, radius, type)
    local body = {
        shape = 'point',
        radius = radius or 100,
        points = {},
        type = type or 'rigid',
    }
    local translation = translation or vec3()
    add_point(body, translation)
    self.bodies[object] = body
end

function World:plane(object, translation, scale, type)    
    local body = {
        shape = 'plane',
        scale = vec3(scale) or vec3(100),
        points = {},
        sticks = {},
        type = type or 'rigid',
    }
    local translation = translation or vec3()
    -- local len = len or 100
    add_point(body, translation + vec3(-.5, .5, 0):mul(body.scale)) -- bottom left
    add_point(body, translation + vec3(-.5, -.5, 0):mul(body.scale)) -- top left
	add_point(body, translation + vec3(.5, -.5, 0):mul(body.scale)) -- top right
    add_point(body, translation + vec3(.5, .5, 0):mul(body.scale)) -- bottom right

	add_stick(body, 1, 2)
	add_stick(body, 2, 3)
	add_stick(body, 3, 4)
	add_stick(body, 4, 1)
	
    add_stick(body, 1, 3)
    add_stick(body, 2, 4)

    self.bodies[object] = body
end


function World:cube(object, translation, scale, type)
    local body = {
        shape = 'cube',
        scale = vec3(scale) or vec3(100),
        points = {},
        sticks = {},
        type = type or 'rigid',
    }
    local translation = translation or vec3()
    local scale = body.scale:clone():scale(2) -- yeah, cube mesh scaled twice bigger??
    add_point(body, translation + vec3(0, 0, 0):mul(scale))
	add_point(body, translation + vec3(1, 0, 0):mul(scale))
	add_point(body, translation + vec3(1, -1, 0):mul(scale))
	add_point(body, translation + vec3(0, -1, 0):mul(scale))

	add_point(body, translation + vec3(0, 0, -1):mul(scale))
	add_point(body, translation + vec3(1, 0, -1):mul(scale))
	add_point(body, translation + vec3(1, -1, -1):mul(scale))
	add_point(body, translation + vec3(0, -1, -1):mul(scale))

	add_stick(body, 1, 2)
	add_stick(body, 2, 3)
	add_stick(body, 3, 4)
	add_stick(body, 4, 1)
	
	add_stick(body, 5, 6)
	add_stick(body, 6, 7)
	add_stick(body, 7, 8)
	add_stick(body, 8, 5)

	add_stick(body, 1, 5)
	add_stick(body, 2, 6)
	add_stick(body, 3, 7)
	add_stick(body, 4, 8)

	add_stick(body, 1, 3)
	add_stick(body, 2, 4)
	add_stick(body, 5, 7)
	add_stick(body, 6, 8)
	add_stick(body, 2, 7)
	add_stick(body, 3, 6)
	add_stick(body, 1, 8)
	add_stick(body, 4, 5)
	add_stick(body, 2, 5)
	add_stick(body, 1, 6)
	add_stick(body, 3, 8)
	add_stick(body, 4, 7)
	add_stick(body, 1, 7)
	add_stick(body, 2, 8)
	add_stick(body, 4, 6)
	add_stick(body, 5, 3)

    self.bodies[object] = body
end

function World:get_translation(object)
    local sum = vec3()
    for _, p in ipairs(self.bodies[object].points) do
        sum = sum + p.t
    end
    sum = sum / #self.bodies[object].points
    return sum
end


function World:get_transform(object)
    local body = self.bodies[object]
    if body.shape == 'cube' then
        local forward = ((body.points[4].t - body.points[8].t)/2):normalize()
        local up = ((body.points[8].t - body.points[5].t)/2):normalize()
        local mat = mat4()
        local mid = self:get_translation(object)
        mat:target(mid, mid + forward, up)
        return mat
    elseif body.shape == 'plane' then
        local side = ((body.points[4].t - body.points[1].t)/2):normalize()
        local up = ((body.points[2].t - body.points[1].t)/2):normalize()
        local forward = side:cross(up)
        local mat = mat4()
        local mid = self:get_translation(object)
        mat:target(mid, mid + forward, up)
        return mat
    end
end

function World:get_transform_scaled(object)
    return self:get_transform(object):scale(self.bodies[object].scale)
end

function World:get_orientation_matrix(object)
    local body = self.bodies[object]
    if body.shape == 'cube' then
        local forward = ((body.points[4].t - body.points[8].t)/2):normalize()
        local up = ((body.points[8].t - body.points[5].t)/2):normalize()
        local mat = mat4()
        local mid = self:get_translation(object)
        mat:target(vec3(), forward, up)
        return mat
    elseif body.shape == 'plane' then
        local side = ((body.points[4].t - body.points[1].t)/2):normalize()
        local up = ((body.points[2].t - body.points[1].t)/2):normalize()
        local forward = side:cross(up)
        local mat = mat4()
        mat:target(vec3(), forward, up)
        return mat
    end
end


function World:apply_force(object, v_force)
    local body = self.bodies[object]
    assert(body.type == 'rigid', 'ERROR (World.apply_force): body type must be rigid.')
    for _, p in ipairs(body.points) do
        p.t_old:add(v_force * self.tick_period)
    end
end

function World:set_transform(object, transform)
    local body = self.bodies[object]
    assert(body.type == 'kinematic', 'ERROR (World.set_transform): body type must be kinematic.')
    if body.shape == 'plane' then
        body.points[1].t:set((transform * vec3(-.5, .5, 0):mul(body.scale))) -- bottom left
        body.points[2].t:set((transform * vec3(-.5, -.5, 0):mul(body.scale))) -- top left
        body.points[3].t:set((transform * vec3(.5, -.5, 0):mul(body.scale))) -- top right
        body.points[4].t:set((transform * vec3(.5, .5, 0):mul(body.scale))) -- bottom right
    end
end


return World