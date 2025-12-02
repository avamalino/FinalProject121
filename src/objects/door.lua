local collision = require(pigic.collision)

Door = Object:extend()
Door.model = pigic.model('assets/obj/door.obj', 'assets/png/palette.png', true)

function Door:new(owner, x, y, z)
    self.owner = owner
    self.translation = vec3(x, y, z)

    self.collider = self.model.collider

    self.aabb = collision.generateAABB(self)
end

function Door:update(dt)

end

function Door:draw()
    pass.push()
    pass.translate(self.translation)
    self.model:draw()
    pass.pop()
end

function Door:destroy()

end
