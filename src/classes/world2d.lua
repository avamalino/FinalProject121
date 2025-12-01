local World2D = Object:extend()

-- credit to SNKRX's physics.lua & group.lua

function World2D:new(meter, xg, yg, tags)
    love.physics.setMeter(meter or 30) --dk, 30 is the default anyway..
    self.tags = table.unify(table.unshift(tags, 'Ghost')) -- set Ghost as the first value
    self.collision_tags = {}
    self.trigger_tags = {}
    for i, tag in ipairs(self.tags) do
        self.collision_tags[tag] = { category = i, masks = {1} } -- 1 is Ghost
        self.trigger_tags[tag] = { category = i, triggers = {} }
    end
    -- set the triggers to be disabled by default
    for i, tag in ipairs(self.tags) do
        local trigger_mask = self.trigger_tags[tag].triggers
        for i = 1, #self.tags do
            table.insert(trigger_mask, i)            
        end
    end

    self._world = love.physics.newWorld(xg or 0, yg or 0)
    local beginContact = function(fa, fb, c)
        local oa, ob = fa:getUserData(), fb:getUserData()
        if fa:isSensor() or fb:isSensor() then
            if fa:isSensor() then if oa.on_trigger_enter then oa:on_trigger_enter(ob, c) end end
            if fb:isSensor() then if ob.on_trigger_enter then ob:on_trigger_enter(oa, c) end end
        else
            if oa.on_collision_enter then oa:on_collision_enter(ob, c) end
            if ob.on_collision_enter then ob:on_collision_enter(oa, c) end
        end
    end
    local endContact = function(fa, fb, c)
        local oa, ob = fa:getUserData(), fb:getUserData()
        if fa:isSensor() or fb:isSensor() then
            if fa:isSensor() then if oa.on_trigger_exit then oa:on_trigger_exit(ob, c) end end
            if fb:isSensor() then if ob.on_trigger_exit then ob:on_trigger_exit(oa, c) end end
        else
            if oa.on_collision_exit then oa:on_collision_exit(ob, c) end
            if ob.on_collision_exit then ob:on_collision_exit(oa, c) end
        end
    end
    self._world:setCallbacks(beginContact, endContact)
    return self
end

function World2D:get()
    return self._world
end

function World2D:enable_collision_between(tag1, tag2)
    table.delete(self.collision_tags[tag1].masks, self.collision_tags[tag2].category)
end

function World2D:disable_collision_between(tag1, tag2)
    table.insert(self.collision_tags[tag1].masks, self.collision_tags[tag2].category)
end

function World2D:enable_trigger_between(tag1, tag2)
    table.delete(self.trigger_tags[tag1].triggers, self.trigger_tags[tag2].category)
end

function World2D:disable_trigger_between(tag1, tag2)
    table.insert(self.trigger_tags[tag1].triggers, self.trigger_tags[tag2].category)
end


function World2D:update(dt)
    self._world:update(dt)
end

function World2D:draw(alpha)
    -- get the current color values to reapply
    local r, g, b, a = love.graphics.getColor()
    -- alpha value is optional
    alpha = alpha or 1

    -- Colliders debug
    love.graphics.setColor(.6, .6, .6, alpha)
    local bodies = self._world:getBodies()
    for _, body in ipairs(bodies) do
        local fixtures = body:getFixtures()
        for _, fixture in ipairs(fixtures) do
            if fixture:getShape():type() == 'PolygonShape' then
                love.graphics.polygon('line', body:getWorldPoints(fixture:getShape():getPoints()))
            elseif fixture:getShape():type() == 'EdgeShape' or fixture:getShape():type() == 'ChainShape' then
                local points = { body:getWorldPoints(fixture:getShape():getPoints()) }
                for i = 1, #points, 2 do
                    if i < #points - 2 then love.graphics.line(points[i], points[i + 1], points[i + 2], points[i + 3]) end
                end
            elseif fixture:getShape():type() == 'CircleShape' then
                local body_x, body_y = body:getPosition()
                local shape_x, shape_y = fixture:getShape():getPoint()
                local r = fixture:getShape():getRadius()
                love.graphics.circle('line', body_x + shape_x, body_y + shape_y, r, 360)
            end
        end
    end
    love.graphics.setColor(1, 1, 1, alpha)

    -- Joint debug
    love.graphics.setColor(222 / 255, 128 / 255, 64 / 255, alpha)
    local joints = self._world:getJoints()
    for _, joint in ipairs(joints) do
        local x1, y1, x2, y2 = joint:getAnchors()
        if x1 and y1 then love.graphics.circle('line', x1, y1, 4) end
        if x2 and y2 then love.graphics.circle('line', x2, y2, 4) end
    end
    love.graphics.setColor(r, g, b, a)
end

function World2D:destroy()
    self._world:destroy()
    self._world = nil
    self.collision_tags = nil
    self.trigger_tags = nil
end


return World2D