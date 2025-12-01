width = 1280
height = 720

function love.conf(t)
    t.window.title = "Cat Game"
    t.window.width = width
    t.window.height = height
    t.window.resizable = true
    t.modules.physics = false
end
