local collision = require(pigic.collision)

Room1 = {}

--inventory

function Room1:keypressed(key)
    if key == "i" then
        Inventory:toggle()
        return
    elseif key == "escape" then
        Inventory:hide()
        return
    end
end

function Room1:enter()
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

    self.door = self.stuff:add(Door, 3, 0, -4.25)
    table.insert(self.solid, self.door)

    -- Add suitcase to inventory puzzle
    -- Preserve collected state if it was already set
    local was_collected = self.suitcase and self.suitcase.collected
    self.suitcase = self.stuff:add(Suitcase, -2, 0, 2, { angle = 0, axis = vec3(0, 1, 0) })
    -- Restore collected state or check inventory
    if was_collected or Inventory:has('suitcase') then
        self.suitcase.collected = true
    else
        table.insert(self.solid, self.suitcase)
    end

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
    -- Fixed angled camera
    self.eye.transform:look_at(self.camera_position, self.camera_target, vec3(0, 1, 0))
end

function Room1:update(dt)
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
    self.pushable:update(dt)
    self.sensor:update(dt)
    self.stuff:update(dt)
    
    Joystick:update(dt)
    moveX = Joystick.joystick.sensing.motion.x() 
    moveZ = Joystick.joystick.sensing.motion.y()
    self.player:moveWithJoystick(moveX,moveZ)


    -- Check if player can pick up suitcase
    if self.suitcase and not self.suitcase.collected then
        -- Calculate distance between player and suitcase
        local dx = self.player.translation.x - self.suitcase.translation.x
        local dy = self.player.translation.y - self.suitcase.translation.y
        local dz = self.player.translation.z - self.suitcase.translation.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

        -- If player is close enough and presses interact, pick it up
        local pickup_distance = self.player.radius + 1.5
        if dist < pickup_distance and input:pressed('interact') then
            -- Track item pickup in undo stack
            UndoStack:push({
                type = 'item_pickup',
                item_type = 'suitcase',
                position = vec3(self.suitcase.translation.x, self.suitcase.translation.y, self.suitcase.translation.z),
                rotation = {
                    angle = self.suitcase.rotation.angle,
                    axis = vec3(self.suitcase.rotation.axis.x, self.suitcase.rotation.axis.y, self.suitcase.rotation.axis.z)
                }
            })

            self.suitcase.collected = true
            -- Add to global inventory
            Inventory:add('suitcase')
            -- Remove from solid array so player doesn't collide with it
            for i, solid in ipairs(self.solid) do
                if solid == self.suitcase then
                    table.remove(self.solid, i)
                    break
                end
            end
        end
    end

    -- Check if player is touching door to transition to room2
    -- Only allow transition if sensor is activated
    if self.sensor.activated and not self.transitioning and (not self.door_cooldown or self.door_cooldown <= 0) then
        local len = collision.sphereIntersection(
            self.door,
            self.player.translation.x,
            self.player.translation.y,
            self.player.translation.z,
            self.player.radius
        )

        -- If intersecting with door, transition to room2
        if len then
            -- Track room transition in undo stack
            UndoStack:push({
                type = 'room_transition',
                from_room = Room1,
                to_room = Room2
            })

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

    -- Draw inventory
    Inventory:draw()

    graphics.set_shader()
    love.graphics.setDepthMode('always', false)

    --draw joystick
    
    Joystick:draw()

    -- Display inventory contents
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Inventory:", specialFont, 10, 10, 0, 0.5, 0.5)
    local y_offset = 30
    for i, item in ipairs(Inventory.items) do
        love.graphics.print("- " .. item, specialFont, 10, y_offset, 0, 0.5, 0.5)
        y_offset = y_offset + 20
    end

    -- Display controls in top right
    specialFont = love.graphics.newFont("assets/fonts/SuperCrossiant.ttf", 36)

    local controls_text = "Controls:\nWASD/Arrows - Move\nSpace - Interact\nZ - Undo\nI - Inventory"
    local text_width = love.graphics.getFont():getWidth("Controls:")
    love.graphics.printf(controls_text, specialFont, love.graphics.getWidth() - text_width - 150, 10, 500, 'left', nil, 0.5)
end

function Room1:exit()
    self.solid = {}
    self.stuff:destroy()
end

return Room1
