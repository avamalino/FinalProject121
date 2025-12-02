local collision = require(pigic.collision)

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

    -- Create a pushable
    if not self.pushable then
        self.pushable = require('objects.pushable')(self, 2, 0, 0)
    end

    -- Create a sensor that unlocks the door
    if not self.sensor then
        self.sensor = require('objects.sensor')(self, -3, 0, -3.75) -- Put sensor in middle of room
    end

    self.solid = {}
    self.stuff = class.holder(self)

    table.insert(self.solid, self.stuff:add(Door, 3, 0, -4.25))

    self:init_eye_and_sun()

    -- Load floor model
    self.floor_model = pigic.model('assets/obj/floor.obj', 'assets/png/palette.png')
    local floor = { translation = vec3(0, 0, 0), collider = self.floor_model.verts }
    floor.aabb = collision.generateAABB(floor)
    table.insert(self.solid, floor)

    -- Load wall model
    self.wall_model = pigic.model('assets/obj/wall.obj', 'assets/png/wall-texture.png')
    local wall = { translation = vec3(0, 0, 0), collider = self.wall_model.verts }
    wall.aabb = collision.generateAABB(wall)
    table.insert(self.solid, wall)

    -- Store room boundaries for simple boundary checking
    self.room_bounds = {
        min_x = -4.5,
        max_x = 4.5,
        min_z = -4.5,
        max_z = 4.5 -- Front edge boundary
    }
end

function Room1:init_eye_and_sun()
    self.eye = {}
    self.eye.transform = mat4()
    self.eye.shader = graphics.new_shader(pigic.unlit_web)
    self.eye.projection = mat4.from_perspective(60, love.graphics.getWidth() / love.graphics.getHeight(), .01, 300)

    self.eye.shader:send('projectionMatrix', 'column', self.eye.projection)

    -- Set up fixed angled camera position (higher, better view)
    self.camera_position = vec3(0, 12, 8) -- Higher and back for better overview
    self.camera_target = vec3(0, 0, 0)    -- Looking at room center
end

function Room1:update(dt)
    self.player:update(dt)
    self.pushable:update(dt)
    self.sensor:update(dt)
    self.stuff:update(dt)

    -- Check if player is touching door to transition to room2
    -- Only allow transition if sensor is activated
    if not self.transitioning and self.sensor.activated then
        for _, obj in ipairs(self.solid) do
            -- Check sphere intersection with this solid object
            local len = collision.sphereIntersection(
                obj,
                self.player.translation.x,
                self.player.translation.y,
                self.player.translation.z,
                self.player.radius
            )

            -- If intersecting and it's the door (at position 3, 0, -4.25), transition
            if len and obj.translation and obj.translation.x then
                if math.abs(obj.translation.x - 3) < 0.1 and math.abs(obj.translation.z - (-4.25)) < 0.1 then
                    self.transitioning = true
                    toolkit:switch(Room2)
                    return
                end
            end
        end
    end

    -- Fixed angled camera
    self.eye.transform:look_at(self.camera_position, self.camera_target, vec3(0, 1, 0))
end

function Room1:draw()
    love.graphics.setDepthMode('lequal', true)

    graphics.set_canvas { toolkit.canvas, depth = true }
    graphics.set_shader(self.eye.shader)
    self.active_shader = self.eye.shader
    self.eye.shader:send('viewMatrix', 'column', self.eye.transform)

    -- Draw floor and walls
    self.floor_model:draw()
    self.wall_model:draw()

    self.stuff:draw()

    -- Draw sensor
    self.sensor:draw()

    -- Draw pushable
    self.pushable:draw()

    -- Draw player
    self.player:draw()

    graphics.set_shader()
    love.graphics.setDepthMode('always', false)
end

function Room1:exit()
    self.solid = {}
    self.stuff:destroy()
end

return Room1
