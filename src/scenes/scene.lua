local Scene = {}
Scene.current = nil
Scene.scenes = {}

function Scene.register(name, scene)
    Scene.scenes[name] = scene
end

function Scene.switch(name, enterParams)
    if Scene.current and Scene.current.onExit then
        Scene.current.onExit()
    end

    local prev = Scene.current
    Scene.current = Scene.scenes[name]

    if not Scene.current then
        error("Scene not found: " .. name)
    end

    if Scene.current.onEnter then
        Scene.current.onEnter(prev, enterParams)
    end
end

function Scene.load()
    if Scene.current and Scene.current.load then
        Scene.current.load()
    end
end

function Scene:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function Scene:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

return Scene