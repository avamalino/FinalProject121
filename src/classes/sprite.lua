local Sprite = Object:extend()


function Sprite:new(owner)
    self.owner = owner
    self.x, self.y, self.r = self.owner.x, self.owner.y, self.owner.r
    self.state = nil
    self.scale = 1

    self.animation = {}
    self.animation.timer = 0
    self.animation.rate = 1/12 -- 1/fps
    self.animation.draw = nil

    self.color =  color.white()
    self.hit_color = color.red()
    self._color = {unpack(self.color)}

    self.hfxs = {}

    self.timer = Timer(self)
    self.spring = Spring()

    self.angle_offset = 0 -- this is glue code
end

function Sprite:update(dt)
    self.x, self.y, self.r = self.owner.x, self.owner.y, self.owner.r

    if self.state then
        self.animation.timer = self.animation.timer + dt
        if self.animation.timer >= self.animation.rate then
            self.animation.timer = 0
            self:next_frame()
        end
    end

    self.timer:update(dt)
    self.spring:update(dt)
end

function Sprite:draw()
    graphics.set_color(self._color)
    graphics.push_rotate_scale(self.x, self.y, self.r, self.spring.scale)
    graphics.draw(self.animation.draw, self.x, self.y, self.angle_offset, self.scale, self.scale, self.animation.draw:getWidth()/2, self.animation.draw:getHeight()/2)
    graphics.pop()
    graphics.set_color(color.white())
end

function Sprite:add_state(string_state, int_start, int_end, path_to_folder)
    self.animation[string_state] = {total = (int_end - int_start) + 1, current = 1, images = {}}
    for i = int_start, int_end do
        self.animation[string_state].images[#self.animation[string_state].images + 1] = graphics.new_image(path_to_folder .. '/' .. i .. '.png')
    end
end

function Sprite:set_state(string_state)
    self.state = string_state
    self.animation.draw = self.animation[self.state].images[1]
end

function Sprite:next_frame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
       anim.current = anim.current + 1
    else
       anim.current = 1
    end
    self.animation.draw = anim.images[anim.current]
end

function Sprite:set_scale(s)
    self.scale = s
end

function Sprite:set_color(color)
    self.color = color
    self._color = {unpack(self.color)}
end

function Sprite:set_hit_color(color)
    self.hit_color = color
end

function Sprite:tween_color(delay, color, method)
    local r, g, b = unpack(color)
    self.timer:tween(delay, self._color, {unpack(color)}, method or math.cubic_in_out, nil, 'tween_color')
end

function Sprite:pull(pull_force, stiffness, damping)
    self.spring:pull(pull_force or .2, stiffness, damping)
end

function Sprite:animate(new_origin_scale, stiffness, damping)
    self.spring:animate(new_origin_scale, stiffness, damping)
end

function Sprite:add_hfx(tag, pull_force, flash_dur)
    self.hfxs[tag] = {pull_force = pull_force, flash_dur = flash_dur}
end


function Sprite:use_hfx(tag)
    local hfx = self.hfxs[tag]
    self.spring:pull(hfx.pull_force)
    self._color[1], self._color[2], self._color[3] = unpack(self.hit_color)
    self:tween_color(hfx.flash_dur, self.color)
end

return Sprite