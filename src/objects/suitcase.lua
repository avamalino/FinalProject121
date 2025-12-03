local collision = require(pigic.collision)

Suitcase = Object:extend()
Suitcase.model = pigic.model('assets/obj/suitcase.obj', 'assets/png/palette.png', true)

function Suitcase:new(owner, x, y, z, rot)
    self.owner = owner
    self.translation = vec3(x, y, z)
    self.rotation = {}
    self.rotation.angle = rot.angle
    self.rotation.axis = vec3(rot.axis[1], rot.axis[2], rot.axis[3])

    self.collider = self.model.collider
    self.collected = false -- Track if suitcase has been picked up

    self.aabb = collision.generateAABB(self)
end

function Suitcase:update(dt)

end

function Suitcase:draw()
    if not self.collected then
        pass.push()
        pass.translate(self.translation)
        pass.rotate(self.rotation.angle, self.rotation.axis.x, self.rotation.axis.y, self.rotation.axis.z)
        self.model:draw()
        pass.pop()
    end
end

function Suitcase:destroy()

end
