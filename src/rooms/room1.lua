local collision = require(pigic.collision)
local theme     = require('theme')     

Room1 = {}

function Room1:enter()
    if not self.camera then
        self.camera = class.camera3d(self)
        self.camera:add_camera('default', 0, 50, 50)
        self.camera:set_active('default')
        self.camera:follow_xz(0, 0)
    end

    self.camera:set_active('default')

    if not self.player then
        self.player = require('objects.player')(self, 0, 0, 0)
    end

    if not self.pushable then
        self.pushable = require('objects.pushable')(self, 2, 0, 0)
    end

    if not self.sensor then
        self.sensor = require('objects.sensor')(self, -3, 0, -3.75) -- Put sensor in middle of room
    end

    self.solid = {}
    self.stuff = class.holder(self)

    self.door = self.stuff:add(Door, 3, 0, -4.25)
    table.insert(self.solid, self.door)

    self.suitcase = self.stuff:add(Suitcase, -2, 0, 2, { angle = 0, axis = vec3(0, 1, 0) })
    table.insert(self.solid, self.suitcase)

    self:init_eye_and_sun()

    self.floor_model = pigic.model('assets/obj/floor.obj', 'assets/png/palette.png')
    local floor = { translation = vec3(0, 0, 0), collider = self.floor_model.verts }
    floor.aabb = collision.generateAABB(floor)
    table.insert(self.solid, floor)


    self.wall_model = pigic.model('assets/obj/wall.obj', 'assets/png/wall-texture.png')
    local wall = { translation = vec3(0, 0, 0), collider = self.wall_model.verts }
    wall.aabb = collision.generateAABB(wall)
    table.insert(self.solid, wall)


    self.room_bounds = {
        min_x = -4.5,
        max_x = 4.5,
        min_z = -4.5,
        max_z = 4.5 
    }
end

function Room1:init_eye_and_sun()
    self.eye = {}
    self.eye.transform = mat4()
    self.eye.shader = graphics.new_shader(pigic.unlit_web)
    self.eye.projection = mat4.from_perspective(60, love.graphics.getWidth() / love.graphics.getHeight(), .01, 300)

    self.eye.shader:send('projectionMatrix', 'column', self.eye.projection)

    self.camera_position = vec3(0, 12, 8) 
    self.camera_target = vec3(0, 0, 0)    
    self.eye.transform:look_at(self.camera_position, self.camera_target, vec3(0, 1, 0))
end

function Room1:update(dt)
    self.player:update(dt)
    self.pushable:update(dt)
    self.sensor:update(dt)
    self.stuff:update(dt)

    if self.suitcase and not self.suitcase.collected then
        local dx = self.player.translation.x - self.suitcase.translation.x
        local dy = self.player.translation.y - self.suitcase.translation.y
        local dz = self.player.translation.z - self.suitcase.translation.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

        local pickup_distance = self.player.radius + 1.5
        if dist < pickup_distance and input:pressed('interact') then
            self.suitcase.collected = true
            Inventory:add('suitcase')
            for i, solid in ipairs(self.solid) do
                if solid == self.suitcase then
                    table.remove(self.solid, i)
                    break
                end
            end
        end
    end

    if self.sensor.activated and not self.transitioning then
        local len = collision.sphereIntersection(
            self.door,
            self.player.translation.x,
            self.player.translation.y,
            self.player.translation.z,
            self.player.radius
        )

        if len then
            self.transitioning = true
            toolkit:switch(Room2)
            return
        end
    end
end

function Room1:draw()
    love.graphics.setDepthMode('lequal', true)

    graphics.set_canvas { toolkit.canvas, depth = true }
    graphics.set_shader(self.eye.shader)
    self.active_shader = self.eye.shader
    self.eye.shader:send('viewMatrix', 'column', self.eye.transform)

    self.floor_model:draw()
    self.wall_model:draw()

    self.stuff:draw()

    self.sensor:draw()

    self.pushable:draw()

    self.player:draw()

    graphics.set_shader()
    love.graphics.setDepthMode('always', false)

    theme.applyRoomTint()

    local r, g, b, a = theme.getTextColor()
    love.graphics.setColor(r, g, b, a)
    love.graphics.print("Inventory:", 10, 10)
    local y_offset = 30
    for i, item in ipairs(Inventory.items) do
        love.graphics.print("- " .. item, 10, y_offset)
        y_offset = y_offset + 20
    end

    local controls_text = "Controls:\nWASD/Arrows - Move\nSpace - Interact"
    local text_width = love.graphics.getFont():getWidth("Controls:")
    love.graphics.printf(controls_text, love.graphics.getWidth() - text_width - 150, 10, 200, 'left')

    love.graphics.setColor(1, 1, 1, 1)
end

function Room1:exit()
    self.solid = {}
    self.stuff:destroy()
end

return Room1
