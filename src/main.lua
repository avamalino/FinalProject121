--loading the G3D graphics library
g3d = require "g3d"

--models
local floor
local marble
local destination

--set model transforms
local marblePos = {0,1,0}
local marbleRadius = 0.5
local destinationPos = {5,4,0}

local speed = 3

function love.load()
    --assets
    floor = g3d.newModel("assets/plane.obj", "assets/earth.png", {0,0,0}, nil, {10,10,10})
    marble = g3d.newModel("assets/sphere.obj","assets/moon.png", marblePos, nil, {1,1,1})
    destination = g3d.newModel("assets/sphere.obj", nil, destinationPos, nil, {1,1,1})
    --camera
    g3d.camera.position = {marblePos[1],15,marblePos[3] + 10}
    g3d.camera.target = {marblePos[1], 0, marblePos[3]}
    g3d.camera.fov = math.rad(60)
end

function love.update(dt)
    --movement
    local dx,dz = 0,0
    if love.keyboard.isDown("w") then dz = dz -1 end
    if love.keyboard.isDown("s") then dz = dz +1 end
    if love.keyboard.isDown("a") then dx = dx -1 end
    if love.keyboard.isDown("d") then dx = dx +1 end

    if dx ~= 0 or dz ~= 0 then
        local len = math.sqrt(dx*dx + dz*dz)
        dx,dz = dx/len, dz/len

        marblePos[1] = marblePos[1] + dx * speed * dt
        marblePos[2] = marblePos[2] + dz * speed * dt

        marble:setTranslation(marblePos[1], marblePos[2], marblePos[3])
    end
    
    g3d.camera.lookAt(0,0,15, 0, marblePos[2], 0)


    --collision with destination
    local distX = marblePos[1] - destinationPos[1]
    local distZ = marblePos[2] - destinationPos[2]
    local dist2 = distX * distX + distZ * distZ
    local destinationRadius = 0.5
    if dist2 < (marbleRadius + destinationRadius)^2 then
        print("You win!!")
    end

end

function love.draw()
    --g3d.camera:set()
    
    floor:draw()
    marble:draw()
    destination:draw()

    --g3d.camera:unset()
end