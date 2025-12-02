local collision = require(pigic.collision)

Room2 = {}

function Room2:enter()
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

    self:init_eye_and_sun()

    self.solid = {}

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

function Room2:init_eye_and_sun()
    self.eye = {}
    self.eye.transform = mat4()
    self.eye.shader = graphics.new_shader(pigic.unlit_web)
    self.eye.projection = mat4.from_perspective(60, love.graphics.getWidth() / love.graphics.getHeight(), .01, 300)

    self.eye.shader:send('projectionMatrix', 'column', self.eye.projection)

    -- Set up fixed angled camera position (higher, better view)
    self.camera_position = vec3(0, 12, 8) -- Higher and back for better overview
    self.camera_target = vec3(0, 0, 0)    -- Looking at room center
end

function Room2:update(dt)
    self.player:update(dt)

    -- Fixed angled camera
    self.eye.transform:look_at(self.camera_position, self.camera_target, vec3(0, 1, 0))
end

function Room2:draw()
    love.graphics.setDepthMode('lequal', true)

    graphics.set_canvas { toolkit.canvas, depth = true }
    graphics.set_shader(self.eye.shader)
    self.active_shader = self.eye.shader
    self.eye.shader:send('viewMatrix', 'column', self.eye.transform)

    -- Draw floor and walls
    self.floor_model:draw()
    self.wall_model:draw()

    -- Draw player
    self.player:draw()

    graphics.set_shader()
    love.graphics.setDepthMode('always', false)
end

function Room2:exit()
    self.solid = {}
end

return Room2
