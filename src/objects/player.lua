local Player = class.vehicle3d:extend()

Player.model = pigic.model('assets/obj/cat.obj', 'assets/png/cat.png')

function Player:new(owner, x, y, z)
    Player.super.new(self, x, y, z)
    self.owner = owner
    self.movespeed = 5 -- Slower movement
    self.friction = 0
    self.yaw = 0
    self.radius = 0.5 -- Collision radius
end

function Player:update(dt)
    local move = vec3(0, 0, 0)
    if love.keyboard.isDown('w') then move.z = -1 end
    if love.keyboard.isDown('s') then move.z = 1 end
    if love.keyboard.isDown('a') then move.x = -1 end
    if love.keyboard.isDown('d') then move.x = 1 end

    if move:len() > 0 then
        move:normalize()

        -- Calculate yaw based on movement direction
        if move:len() > 0 then
            self.yaw = math.atan2(move.x, move.z)
        end

        move:scale(self.movespeed)
        self:apply_force(move)
    end

    Player.super.update(self, dt)

    -- Check collision with walls and floor
    self:check_collision()
end

function Player:check_collision()
    local collision = require(pigic.collision)

    -- Check collision with walls and floor
    for _, solid in ipairs(self.owner.solid) do
        local len, x, y, z, nx, ny, nz = collision.sphereIntersection(
            solid,
            self.translation.x,
            self.translation.y,
            self.translation.z,
            self.radius
        )

        if len then
            -- Push player out of wall
            self.translation.x = self.translation.x - nx * (len - self.radius)
            self.translation.y = self.translation.y - ny * (len - self.radius)
            self.translation.z = self.translation.z - nz * (len - self.radius)

            -- Stop velocity in collision direction
            local dot = self.velocity.x * nx + self.velocity.y * ny + self.velocity.z * nz
            if dot < 0 then
                self.velocity.x = self.velocity.x - nx * dot
                self.velocity.y = self.velocity.y - ny * dot
                self.velocity.z = self.velocity.z - nz * dot
            end
        end
    end

    -- Check collision with pushable and push it
    if self.owner.pushable then
        local pushable = self.owner.pushable
        local dx = self.translation.x - pushable.translation.x
        local dz = self.translation.z - pushable.translation.z
        local dist = math.sqrt(dx * dx + dz * dz)
        local min_dist = self.radius + pushable.radius

        if dist < min_dist and dist > 0 then
            -- Push pushable away
            local push_force = 15 -- How hard player pushes
            local nx = dx / dist
            local nz = dz / dist

            pushable:apply_force(vec3(-nx * push_force, 0, -nz * push_force))

            -- Push player back slightly
            self.translation.x = pushable.translation.x + nx * min_dist
            self.translation.z = pushable.translation.z + nz * min_dist
        end
    end

    -- Simple boundary clamping for room edges (including the open front)
    if self.owner.room_bounds then
        local bounds = self.owner.room_bounds
        if self.translation.x < bounds.min_x then
            self.translation.x = bounds.min_x
            self.velocity.x = 0
        elseif self.translation.x > bounds.max_x then
            self.translation.x = bounds.max_x
            self.velocity.x = 0
        end

        if self.translation.z < bounds.min_z then
            self.translation.z = bounds.min_z
            self.velocity.z = 0
        elseif self.translation.z > bounds.max_z then
            self.translation.z = bounds.max_z
            self.velocity.z = 0
        end
    end
end

function Player:draw()
    pass.push()
    pass.translate(self.translation)
    pass.rotate(self.yaw, 0, 1, 0)
    Player.model:draw()
    pass.pop()
end

return Player
