local Pushable = class.vehicle3d:extend()

Pushable.model = pigic.model('assets/obj/cat.obj', 'assets/png/palette.png')

function Pushable:new(owner, x, y, z)
    Pushable.super.new(self, x, y, z)
    self.owner = owner
    self.friction = 0 -- Pushable has friction so it doesn't slide forever
    self.radius = 0.4 -- Collision radius
    self.mass = 2     -- Heavier than player so it pushes nicely
end

function Pushable:update(dt)
    Pushable.super.update(self, dt)

    -- Check collision with walls and boundaries
    self:check_collision()
end

function Pushable:check_collision()
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
            -- Push Pushable out of wall
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

    -- Simple boundary clamping for room edges
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

function Pushable:draw()
    pass.push()
    pass.translate(self.translation)
    Pushable.model:draw()
    pass.pop()
end

return Pushable
