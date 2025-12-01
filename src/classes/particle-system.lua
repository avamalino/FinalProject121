local ParticleSystem = Object:extend()

function ParticleSystem:new()
    self.list = {}
    self.limit = 100
    self.position = vec3()
    self.direction = vec3(1, 0, 0)
    self.lifetime = 1
    self.sizes = {1}
    self.colors = {color.yellow(), color.orange(), color.blue()}
    self.velocities = {1}
    self.gravity = 0
    self.spread = {r = 0, x = 0, y = 0, z = 0}
    self.draw_shape = function() pass.cube(mat4()) end
end

function ParticleSystem:update(dt)
    for i = #self.list, 1, -1 do
        local p = self.list[i]
        p.lifetime = p.lifetime - dt
        if p.lifetime <= 0 then table.remove(self.list, i)
        else
            local t = 1 - (p.lifetime / self.lifetime) -- useful for transform & size interpolations
            -- transform
            local velocity
            if #self.velocities > 1 then
                local s = math.remap(t, 0, 1, 1, #self.velocities)
                local j = math.floor(s)
                s = s - j 
                velocity = math.lerp(self.velocities[j], self.velocities[j + 1], s)
            else 
                velocity = self.velocities[1]
            end
            p.transform:translate(vec3(0, 0, -1) * velocity * dt) --???

            -- apply gravity if any
            if self.gravity ~= 0 then p.transform:translate(vec3(0, -1, 0):rotate(mat4(p.transform):invert():getOrientation()) * self.gravity * (self.lifetime - p.lifetime) * dt) end

            -- sizes
            local size
            if #self.sizes > 1 then
                local s = math.remap(t, 0, 1, 1, #self.sizes)
                local j = math.floor(s)
                s = s - j
                size = math.lerp(self.sizes[j], self.sizes[j + 1], s)
            else
                size = self.sizes[1]
            end
            p.size = size 
        
            -- colors
            local clr
            if #self.colors > 1 then
                local s = math.remap(t, 0, 1, 1, #self.colors)
                local j = math.floor(s)
                s = s - j
                clr = color.lerp(self.colors[j], self.colors[j + 1], s)
            else
                clr = self.colors[1]
            end
            p.color = clr
        end
    end
end

function ParticleSystem:draw()
    for i = 1, #self.list do
        local p = self.list[i]
        pass.push()
        -- pass.transform(p.transform)
        pass.transform:set(p.transform)
            pass.scale(p.size)
            graphics.set_color(p.color)
            self.draw_shape()
        pass.pop()
    end
    graphics.white()
end

function ParticleSystem:emit(amount, direction, spread)
    local direction = direction or self.direction
    local spread = spread or self.spread
    for i = 1, amount do
        -- set limit
        if #self.list >= self.limit then table.remove(self.list, 1) end

        local transform = mat4()
        transform:translate(self.position)
        transform = mat4.from_direction(direction, vec3(0, 1, 0)) * transform
        :rotate(random:float(-spread.r, spread.r), spread.x, 0, 0)
        :rotate(random:float(-spread.r, spread.r), 0, spread.y, 0)
        :rotate(random:float(-spread.r, spread.r), 0, 0, spread.z)
        table.insert(self.list, {
            transform = transform,
            lifetime = self.lifetime,
            size = self.sizes[1],
            color = self.colors[1],
        })
    end
end


function ParticleSystem:set_position(x, y, z)
    self.position:set(x, y, z)
    return self
end

function ParticleSystem:set_direction(x, y, z)
    self.direction:set(x, y, z)
    self.direction:normalize()
    return self
end

function ParticleSystem:set_lifetime(d)
    self.lifetime = d
    return self
end

function ParticleSystem:set_sizes(...)
    self.sizes = {...}
    return self
end

function ParticleSystem:set_colors(...)
    self.colors = {...}
    return self
end

function ParticleSystem:set_velocities(...)
    self.velocities = {...}
    return self
end

function ParticleSystem:set_gravity(n)
    self.gravity = n
    return self
end

function ParticleSystem:set_shape(f)
   self.draw_shape = f
   return self
end

function ParticleSystem:set_spread(rad, x, y, z)
    self.spread.r = rad
    self.spread.x = x or 1
    self.spread.y = y or 1
    self.spread.z = z or 1
    return self
end

function ParticleSystem:set_limit(l)
    self.limit = l

    return self
end

return ParticleSystem