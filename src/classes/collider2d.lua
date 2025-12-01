local Collider = Object:extend()

function Collider:wrap_collider(tag, body, shape)
    self.body, self.shape = body, shape
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self.owner)
    local world = gamestate.current().world
    self.category = world.collision_tags[tag].category
    self.fixture:setCategory(self.category)
    self.fixture:setMask(unpack(world.collision_tags[tag].masks))
    if #world.trigger_tags[tag].triggers < #world.tags then
        self.sensor = love.physics.newFixture(self.body, self.shape) --love.physics.newCircleShape(30 / 2))
        self.sensor:setUserData(self.owner)
        self.sensor:setSensor(true)
        self.sensor:setCategory(world.trigger_tags[tag].category)
        self.sensor:setMask(unpack(world.trigger_tags[tag].triggers))
    end
end


function Collider:set_type(type)
    if self.body then self.body:setType(type) end 
end

function Collider:set_body_enabled()

end

function Collider:enable_trigger()
    self.sensor:setCategory(self.category)
end

function Collider:disable_trigger()
    self.sensor:setCategory(1) -- 1 is Ghost
end

function Collider:position_to_collider()
    if self.body then self.owner.x, self.owner.y = self.body:getPosition() end
    return self
end

function Collider:position_to_owner()
    if self.body then self.body:setPosition(self.owner.x, self.owner.y) end
    return self
end

function Collider:rotation_to_collider()
    if self.body then self.owner.r = self.body:getAngle() end
    return self
end

function Collider:rotation_to_owner()
    if self.body then self.body:setAngle(self.owner.r) end
    return self
end

function Collider:get_position()
    if self.body then return self.body:getPosition() end
end

function Collider:set_position(x, y)
    if self.body then self.body:setPosition(x, y) end
    return self
end

function Collider:get_angle()
    if self.body then return self.body:getAngle() end
end

function Collider:set_angle(v)
    if self.body then self.body:setAngle(v) end
    return self
end

function Collider:angle_to_point(x, y)
    return math.atan2(y - self.owner.y, x - self.owner.x)
end

function Collider:angle_to_object(object)
    return self:angle_to_point(object.x, object.y)
end

function Collider:get_velocity()
    if self.body then return self.body:getLinearVelocity() end
end

function Collider:is_zero_velocity(epsilon)
    local vx, vy = self.body:getLinearVelocity()
    local EPSILON = epsilon or 0.0001
    return math.abs(vx) < EPSILON and math.abs(vy) < EPSILON
end

function Collider:set_velocity(vx, vy)
    if self.body then self.body:setLinearVelocity(vx, vy) end
    return self
end

function Collider:update_velocity()
    return self:set_velocity_rotated(self.owner.velocity, self.owner.r)
end

function Collider:set_velocity_rotated(vt, r)
    if self.body then self.body:setLinearVelocity(math.cos(r) * vt, math.sin(r) * vt) end
    return self
end

function Collider:set_angular_velocity(v)
    if self.body then self.body:setAngularVelocity(v) end
    return self
end

function Collider:apply_force(fx, fy, x, y)
    if self.body then self.body:applyForce(fx, fy, x or self.owner.x, y or self.owner.y) end
    return self
end

function Collider:apply_impulse(fx, fy)
    if self.body then self.body:applyLinearImpulse(fx, fy) end
    return self
end

function Collider:apply_angular_impulse(f)
    if self.body then self.body:applyAngularImpulse(f) end
    return self
end

function Collider:set_damping(v)
    if self.body then self.body:setLinearDamping(v) end
    return self
end

function Collider:set_angular_damping(v)
    if self.body then self.body:setAngularDamping(v) end
    return self
end

function Collider:set_restitution(v)
    if self.fixture then self.fixture:setRestitution(v) end
    return self
end

function Collider:set_fixed_rotation(bool)
    if self.body then self.body:setFixedRotation(bool) end
    return self
end

function Collider:rotate_towards_velocity(weight)
    local vx, vy = self:get_velocity()
    self:set_angle(math.lerp_angle(self:get_angle(), self:angle_to_point(self.owner.x + vx, self.owner.y + vy), weight))
    return self
end

function Collider:accelerate_towards_point(x, y, max_speed, deceleration, turn_coefficient)
    local tx, ty = x - self.owner.x, y - self.owner.x
    local d = math.length(tx, ty)
    if d > 0 then
        local speed = d / ((deceleration or 1) * 0.08)
        speed = math.min(speed, max_speed)
        local current_vx, current_vy = speed * tx / d, speed * ty / d
        local vx, vy = self:get_velocity()
        self:apply_force((current_vx - vx) * (turn_coefficient or 1), (current_vy - vy) * (turn_coefficient or 1))
    end
    return self
end

function Collider:accelerate_velocity_toward(tvx, tvy, weight)
    local vx, vy = self.body:getLinearVelocity()
    local weight = math.clamp(weight, 0, 1)
    local nvx = math.lerp(vx, tvx, weight)
    local nvy = math.lerp(vy, tvy, weight)
    self.body:setLinearVelocity(nvx, nvy)
end

-- Sets the object as a steerable object.
-- This is implemented in the Collider mixin because it plays well with the rest of it, thus, to make a game object steerable it needs to implement the Collider mixin.
-- The implementation of steering behaviors here mostly follows the one from chapter 3 of the book "Programming Game AI by Example"
-- https://github.com/wangchen/Programming-Game-AI-by-Example-src
-- self:set_as_steerable(100, 1000)
local C2DMatrix = Object:extend()
local steering = {}

function Collider:set_as_steerable(max_v, max_f, max_turn_rate, turn_multiplier)
    self.steerable = true
    self.steering_enabled = true
    self.heading = Vector()
    self.side = Vector()
    self.steering_force = Vector()
    self.applied_force = Vector()
    self.applied_impulse = Vector()
    self.mass = 1
    self.max_v = max_v or 100
    self.max_f = max_f or 2000
    self.max_turn_rate = max_turn_rate or 2 * math.pi
    self.turn_multiplier = turn_multiplier or 2
    self.seek_f = Vector()
    self.wander_f = Vector()
    local r = random:float(0, 2 * math.pi)
    self.wander_target = Vector(40 * math.cos(r), 40 * math.sin(r)) --check
    self.separation_f = Vector()
    self.apply_force_f = Vector()
    self.apply_impulse_f = Vector()
    self.t = Timer()
    return self
end

function Collider:steering_update(dt)
    if self.steerable and self.steering_enabled then
        local steering_force = self:calculate_steering_force(dt):div(self.mass)
        local applied_force = self:calculate_applied_force(dt):div(self.mass)
        local applied_impulse = self:calculate_applied_impulse(dt):div(self.mass)
        self:apply_force(steering_force.x + applied_force.x, steering_force.y + applied_force.y)
        local vx, vy = self:get_velocity()
        local v = Vector(vx, vy):truncate(self.max_v)
        self:set_velocity(v.x + applied_impulse.x, v.y + applied_impulse.y)
        if v:length_squared() > 0.00001 then
            self.heading = v:clone():normalize()
            self.side = self.heading:perpendicular()
        end
        self.apply_force_f:set(0, 0)
        self.t:update(dt)
    end
end

function Collider:calculate_steering_force(dt)
    self.steering_force:set(0, 0)
    if self.seeking then self.steering_force:add(self.seek_f) end
    if self.wandering then self.steering_force:add(self.wander_f) end
    if self.separating then self.steering_force:add(self.separation_f) end
    self.seeking = false
    self.wandering = false
    self.separating = false
    return self.steering_force:truncate(self.max_f)
end

function Collider:calculate_applied_force(dt)
    self.applied_force:set(0, 0)
    if self.applying_force then self.applied_force:add(self.apply_force_f) end
    return self.applied_force
end

function Collider:calculate_applied_impulse(dt)
    self.applied_impulse:set(0, 0)
    if self.applying_impulse then self.applied_impulse:add(self.apply_impulse_f) end
    return self.applied_impulse
end

-- Applies force f to the object at the given angle r for duration s
-- This plays along with steering behaviors, whereas the apply_force function simply applies it directly to the body and doesn't work when steering behaviors are enabled
-- self:apply_steering_force(100, math.pi/4)
function Collider:apply_steering_force(f, r, s)
    self.applying_force = true
    self.apply_force_f:set(f * math.cos(r), f * math.sin(r))
    if s then
        self.t:after((s or 0.01) / 2, function()
            self.t:tween((s or 0.01) / 2, self.apply_force_f, { x = 0, y = 0 }, 'linear',
                {
                    after = function()
                        self.applying_force = false
                        self.apply_force_f:set(0, 0)
                    end,
                    tag = 'apply_steering_force_2'
                })
        end, 'apply_steering_force_1')
    end
end

-- Applies impulse f to the object at the given angle r for duration s
-- This plays along with steering behaviors, whereas the apply_impulse function simply applies it directly to the body and doesn't work when steering behaviors are enabled
-- self:apply_steering_impulse(100, math.pi/4, 0.5)
function Collider:apply_steering_impulse(f, r, s)
    self.applying_impulse = true
    self.apply_impulse_f:set(f * math.cos(r), f * math.sin(r))
    if s then
        self.t:after((s or 0.01) / 2, function()
            self.t:tween((s or 0.01) / 2, self.apply_impulse_f, { x = 0, y = 0 }, 'linear',
                {
                    after = function()
                        self.applying_impulse = false
                        self.apply_impulse_f:set(0, 0)
                    end,
                    'apply_steering_impulse_2'
                })
        end, 'apply_steering_impulse_1')
    end
end

-- Arrive steering behavior
-- Makes this object accelerate towards a destination, slowing down the closer it gets to it
-- deceleration - how fast the object will decelerate once it gets closer to the target, higher values will make the deceleration more abrupt, do not make this value 0
-- weight - how much the force of this behavior affects this object compared to others
-- self:seek_point(player.x, player.y)
function Collider:seek_point(x, y, deceleration, weight)
    self.seeking = true
    local tx, ty = x - self.owner.x, y - self.owner.y
    local d = math.length(tx, ty)
    if d > 0 then
        local v = d / ((deceleration or 1) * 0.08)
        v = math.min(v, self.max_v)
        local dvx, dvy = v * tx / d, v * ty / d
        local vx, vy = self:get_velocity()
        self.seek_f:set((dvx - vx) * self.turn_multiplier * (weight or 1), (dvy - vy) * self.turn_multiplier *
            (weight or 1))
    else
        self.seek_f:set(0, 0)
    end
end

-- Same as self:seek_point but for objects instead.
-- self:seek_object(player)
function Collider:seek_object(object, deceleration, weight)
    return self:seek_point(object.x, object.y, deceleration, weight)
end

-- Same as self:seek_point and self:seek_object but for the mouse instead.
-- self:seek_mouse()
function Collider:seek_mouse(deceleration, weight)
    local mx, my = self.group.camera:get_mouse_position()
    return self:seek_point(mx, my, deceleration, weight)
end

-- Separation steering behavior
-- Keeps this object separated from other objects of specific classes according to the radius passed in
-- What this function does is simply look at all nearby objects and apply forces to this object such that it remains separated from them
-- self:separate(40, {Enemy}) -> when this is called every frame, this applies forces to this object to keep it separated from other Enemy instances by 40 units at all times
function Collider:steering_separate(rs, class_avoid_list, weight)
    self.separating = true
    local fx, fy = 0, 0
    local objects = table.flatten(
        table.foreachn(class_avoid_list, function(v) return gamestate.current().holder:get_objects_by_class(v) end), true)
    for _, object in ipairs(objects) do
        if object ~= self.owner and math.distance(object.x, object.y, self.owner.x, self.owner.y) < 2 * rs then
            local tx, ty = self.owner.x - object.x, self.owner.y - object.y
            local nx, ny = math.normalize(tx, ty)
            local l = math.length(nx, ny)
            fx = fx + rs * (nx / l)
            fy = fy + rs * (ny / l)
        end
    end
    self.separation_f:set(fx * (weight or 1), fy * (weight or 1))
end

-- Wander steering behavior
-- Makes the object move in a jittery manner, adding some randomness to its movement while keeping the overall direction
-- What this function does is project a circle in front of the entity and then choose a point randomly inside that circle for the entity to move towards and it does that every frame
-- rs - the radius of the circle
-- distance - the distance of the circle from this object, the further away the smoother the changes to movement will be
-- jitter - the amount of jitter to the movement, the higher it is the more abrupt the changes will be
-- self:wander(50, 100, 20)
function Collider:wander(rs, distance, jitter, weight)
    self.wandering = true
    self.wander_target:add(random:float(-1, 1) * (jitter or 20), random:float(-1, 1) * (jitter or 20))
    self.wander_target:normalize()
    self.wander_target:mul(rs or 40)
    local target_local = self.wander_target:clone():add(distance or 40, 0)
    local target_world = steering.point_to_world_space(target_local, self.heading, self.side,
        Vector(self.owner.x, self.owner.y))
    self.wander_f:set((target_world.x - self.owner.x) * (weight or 1), (target_world.y - self.owner.y) * (weight or 1))
end

-- Steering behavior specific auxiliary functions, shouldn't really be used elsewhere
function C2DMatrix:new()
    self._11, self._12, self._13 = 0, 0, 0
    self._21, self._22, self._23 = 0, 0, 0
    self._31, self._32, self._33 = 0, 0, 0
    self:identity()
end

function C2DMatrix:multiply(other)
    local mat_temp = C2DMatrix()
    mat_temp._11 = (self._11 * other._11) + (self._12 * other._21) + (self._13 * other._31);
    mat_temp._12 = (self._11 * other._12) + (self._12 * other._22) + (self._13 * other._32);
    mat_temp._13 = (self._11 * other._13) + (self._12 * other._23) + (self._13 * other._33);
    mat_temp._21 = (self._21 * other._11) + (self._22 * other._21) + (self._23 * other._31);
    mat_temp._22 = (self._21 * other._12) + (self._22 * other._22) + (self._23 * other._32);
    mat_temp._23 = (self._21 * other._13) + (self._22 * other._23) + (self._23 * other._33);
    mat_temp._31 = (self._31 * other._11) + (self._32 * other._21) + (self._33 * other._31);
    mat_temp._32 = (self._31 * other._12) + (self._32 * other._22) + (self._33 * other._32);
    mat_temp._33 = (self._31 * other._13) + (self._32 * other._23) + (self._33 * other._33);
    self._11 = mat_temp._11; self._12 = mat_temp._12; self._13 = mat_temp._13
    self._21 = mat_temp._21; self._22 = mat_temp._22; self._23 = mat_temp._23
    self._31 = mat_temp._31; self._32 = mat_temp._32; self._33 = mat_temp._33
end

function C2DMatrix:identity()
    self._11, self._12, self._13 = 1, 0, 0
    self._21, self._22, self._23 = 0, 1, 0
    self._31, self._32, self._33 = 0, 0, 1
end

function C2DMatrix:transform_vector(point)
    local temp_x = (self._11 * point.x) + (self._21 * point.y) + (self._31)
    local temp_y = (self._12 * point.x) + (self._22 * point.y) + (self._32)
    point.x, point.y = temp_x, temp_y
end

function C2DMatrix:translate(x, y)
    local mat = C2DMatrix()
    mat._11 = 1; mat._12 = 0; mat._13 = 0;
    mat._21 = 0; mat._22 = 1; mat._23 = 0;
    mat._31 = x; mat._32 = y; mat._33 = 1;
    self:multiply(mat)
end

function C2DMatrix:scale(sx, sy)
    local mat = C2DMatrix()
    mat._11 = sx; mat._12 = 0; mat._13 = 0;
    mat._21 = 0; mat._22 = sy; mat._23 = 0;
    mat._31 = 0; mat._32 = 0; mat._33 = 1;
    self:multiply(mat)
end

function C2DMatrix:rotate(fwd, side)
    local mat = C2DMatrix()
    mat._11 = fwd.x; mat._12 = fwd.y; mat._13 = 0;
    mat._21 = side.x; mat._22 = side.y; mat._23 = 0;
    mat._31 = 0; mat._32 = 0; mat._33 = 1;
    self:multiply(mat)
end

function C2DMatrix:rotater(r)
    local mat = C2DMatrix()
    local sin = math.sin(r)
    local cos = math.cos(r)
    mat._11 = cos; mat._12 = sin; mat._13 = 0;
    mat._21 = -sin; mat._22 = cos; mat._23 = 0;
    mat._31 = 0; mat._32 = 0; mat._33 = 1;
    self:multiply(mat)
end

function steering.point_to_world_space(point, heading, side, position)
    local trans_point = Vector(point.x, point.y)
    local mat_transform = C2DMatrix()
    mat_transform:rotate(heading, side)
    mat_transform:translate(position.x, position.y)
    mat_transform:transform_vector(trans_point)
    return trans_point
end

function steering.point_to_local_space(point, heading, side, position)
    local trans_point = Vector(point.x, point.y)
    local mat_transform = C2DMatrix()
    local tx, ty = -position:dot(heading), -position:dot(side)
    mat_transform._11 = heading.x; mat_transform._12 = side.x;
    mat_transform._21 = heading.y; mat_transform._22 = side.y;
    mat_transform._31 = tx; mat_transform._32 = ty;
    mat_transform:transform_vector(trans_point)
    return trans_point
end

function steering.vector_to_world_space(v, heading, side)
    local trans_v = Vector(v.x, v.y)
    local mat_transform = C2DMatrix()
    mat_transform:rotate(heading, side)
    mat_transform:transform_vector(trans_v)
    return trans_v
end

function steering.rotate_vector_around_origin(v, r)
    local mat = C2DMatrix()
    mat:rotater(r)
    mat:transform_vector(v)
    return v
end

-------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL CALLABLES --
-------------------------------------------------------------------------------------------------------------------------------

local RectangleCollider = Object:extend()
RectangleCollider:implement(Collider)

function RectangleCollider:new(owner, type, tag, x, y, w, h, isnotcentered)
    self.owner = owner
    local x, y, w, h = x, y, w, h
    if isnotcentered then
        x = x + w/2
        y = y + h/2
    end
    self:wrap_collider(tag, love.physics.newBody(gamestate.current().world:get(), x, y, type or "dynamic"),
        love.physics.newRectangleShape(w, h))
end

local CircleCollider = Object:extend()
CircleCollider:implement(Collider)

function CircleCollider:new(owner, type, tag, x, y, d)
    self.owner = owner
    self:wrap_collider(tag, love.physics.newBody(gamestate.current().world:get(), x, y, type or "dynamic"),
        love.physics.newCircleShape(d / 2))
end

local LineCollider = Object:extend()
LineCollider:implement(Collider)

function LineCollider:new(owner, type, tag, x1, y1, x2, y2)
    self.owner = owner
    self:wrap_collider(tag, love.physics.newBody(gamestate.current().world:get(), 0, 0, type or "dynamic"),
        love.physics.newEdgeShape(x1, y1, x2, y2))
end


return RectangleCollider, CircleCollider, LineCollider