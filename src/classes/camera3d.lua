local Camera3D = Object:extend()


function Camera3D:new(owner)
    self.owner = owner
    self.transform = mat4()
    self.target = vec3()
    self.offset = vec3()
    self.restoffset = vec3()

    self.cameras = {}
    self.active_camera = nil
end

function Camera3D:update(dt)
    if self.active_camera then
        -- self.offset:set(self.cameras[self.active_camera])
        self.offset:lerp(self.cameras[self.active_camera], .05)
    else
        -- self.offset:set(self.restoffset)
        self.offset:lerp(self.restoffset, .05)
    end
    self.transform:look_at(
    vec3(self.target.x + self.offset.x, self.target.y + self.offset.y, self.target.z + self.offset.z),
        vec3(self.target.x, self.target.y, self.target.z), vec3(0, 1, 0))
end

function Camera3D:draw()

end

function Camera3D:follow_xz(x, z)
    self.target.x = x
    self.target.z = z
end

function Camera3D:follow_y(y)
    self.target.y = y
end

function Camera3D:set_offset(x, y, z)
    self.restoffset:set(x, y, z)
    self.offset:set(self.restoffset)
end

function Camera3D:add_camera(id, x, y, z, w, h, d)
    self.cameras[id] = vec3(0, 30, 5) -- custom offset
end

function Camera3D:set_active(id)
    assert(self.cameras[id], 'tf bro, id aint in .cameras list??')
    -- if self.active_camera then
    --     if (self.active_camera == id) then

    --     else
    --         self.active_camera = id
    --     end
    -- else
    --     self.active_camera = id
    -- end
    self.active_camera = id
end

return Camera3D
