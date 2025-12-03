local collision = require(pigic.collision)

Key = Object:extend()
Key.model = pigic.model('assets/obj/key.obj', 'assets/png/palette.png', true)

function Key:new(owner, x, y, z, rot)
    self.owner = owner
    self.translation = vec3(x, y, z)
    self.rotation = {}
    self.rotation.angle = rot.angle
    self.rotation.axis = vec3(rot.axis[1], rot.axis[2], rot.axis[3])

    self.collider = self.model.collider

    self.picked = false

    self.aabb = collision.generateAABB(self)
end


function Key:update(dt)
end


function Key:draw()
    pass.push()
    if self.picked then
        pass.transform:set(self.owner.player.grabtransform)
        self.translation:set(self.owner.player.grabtransform:get_translation())
    else
        pass.translate(self.translation)
    end
    pass.rotate(self.rotation.angle, self.rotation.axis.x, self.rotation.axis.y, self.rotation.axis.z)
    self.model:draw()
    pass.pop()
end


function Key:destroy()
    
end