local collision = require(pigic.collision)

Room3 = {}

function Room3:enter()
    -- Reset transition flag to allow new transitions
    self.transitioning = false
    -- Set door cooldown to prevent immediate re-entry after undo
    self.door_cooldown = 4

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

    self.solid = {}
    self.stuff = class.holder(self)

    -- Add door that requires suitcase to open
    self.door = self.stuff:add(Door, 0, 0, -4.25)
    table.insert(self.solid, self.door)

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

function Room3:init_eye_and_sun()
    self.eye = {}
    self.eye.transform = mat4()
    self.eye.shader = graphics.new_shader(pigic.unlit_web)
    self.eye.projection = mat4.from_perspective(60, love.graphics.getWidth() / love.graphics.getHeight(), .01, 300)

    self.eye.shader:send('projectionMatrix', 'column', self.eye.projection)

    -- Set up fixed angled camera position (higher, better view)
    self.camera_position = vec3(0, 12, 8) -- Higher and back for better overview
    self.camera_target = vec3(0, 0, 0)    -- Looking at room center
    self.eye.transform:look_at(self.camera_position, self.camera_target, vec3(0, 1, 0))
end

function Room3:update(dt)
    -- Handle undo action
    if input:pressed('undo') then
        UndoStack:undo()
        return
    end

    -- Decrement door cooldown timer
    if self.door_cooldown and self.door_cooldown > 0 then
        self.door_cooldown = self.door_cooldown - dt
    end

    self.player:update(dt)
    self.stuff:update(dt)

    -- Check if player is touching door with the suitcase in inventory
    if Inventory:has('suitcase') and not self.transitioning and (not self.door_cooldown or self.door_cooldown <= 0) then
        local len = collision.sphereIntersection(
            self.door,
            self.player.translation.x,
            self.player.translation.y,
            self.player.translation.z,
            self.player.radius
        )

        -- If intersecting with door, transition to Ending
        if len then
            -- Track room transition in undo stack
            UndoStack:push({
                type = 'room_transition',
                from_room = Room3,
                to_room = Ending
            })

            self.transitioning = true
            toolkit:switch(Ending)
            return
        end
    end
end

function Room3:draw()
    love.graphics.setDepthMode('lequal', true)

    graphics.set_canvas { toolkit.canvas, depth = true }
    graphics.set_shader(self.eye.shader)
    self.active_shader = self.eye.shader
    self.eye.shader:send('viewMatrix', 'column', self.eye.transform)

    -- Draw floor and walls
    self.floor_model:draw()
    self.wall_model:draw()

    self.stuff:draw()

    -- Draw player
    self.player:draw()

    graphics.set_shader()
    love.graphics.setDepthMode('always', false)

    -- Display inventory contents and instruction
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Inventory:",specialFont, 10, 10, 0, 0.5, 0.5)
    local y_offset = 30
    for i, item in ipairs(Inventory.items) do
        love.graphics.print("- " .. item,specialFont, 10, y_offset, 0, 0.5, 0.5)
        y_offset = y_offset + 20
    end

    -- Display message about door requirement
    if not Inventory:has('suitcase') then
        love.graphics.setColor(1, 0.5, 0.5, 1)
        love.graphics.printf(
            "The door is locked. You forgot the suitcase! Return to the first room.",
            specialFont,
            0,
            love.graphics.getHeight() - 50,
            love.graphics.getWidth(),
            'center'
        )
    else
        love.graphics.setColor(0.5, 1, 0.5, 1)
        love.graphics.printf(
            "You have the suitcase! Walk to the door to proceed.",
            specialFont,
            0,
            love.graphics.getHeight() - 50,
            love.graphics.getWidth(),
            'center'
        )
    end

    -- Display controls in top right
    love.graphics.setColor(1, 1, 1, 1)
    local controls_text = "Controls:\nWASD/Arrows - Move\nSpace - Interact\nZ - Undo"
    local text_width = love.graphics.getFont():getWidth("Controls:")
    love.graphics.printf(controls_text, specialFont, love.graphics.getWidth() - text_width - 150, 10, 500, 'left', nil, 0.5)
end

function Room3:exit()
    self.solid = {}
    self.stuff:destroy()
end

return Room3
