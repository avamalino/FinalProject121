local toolkit = {}
local path = ... .. '/'
require(path .. 'errorhandler')


function toolkit:init(scale)
    require (path .. 'lib.math')
    require (path .. 'lib.table')

    profiler = require (path .. 'profiler')
    Object      = require (path .. 'lib.classic')
    gamestate   = require (path .. 'lib.gemstet')
    color       = require (path .. 'lib.color')
    graphics    = require (path .. 'lib.graphics')
    log         = require (path .. 'lib.log')
    lume        = require (path .. 'lib.lume')
    input       = require (path .. 'lib.input')()
    bump3d      = require (path .. 'lib.bump-3dpd')
    cpml        = require (path .. 'lib.cpml')
    json        = require (path .. 'lib.json')
    mat4        = cpml.mat4
    vec3        = cpml.vec3
    quat        = cpml.quat
    vec2        = cpml.vec2
    intersect   = cpml.intersect
    pigic       = require (path .. 'lib/pigic')
    pass        = pigic.pass
    
    require 'classes'
    
    -- global callables
    random = class.random()
    self.timer = class.timer(self) --srry for the unconsistency ><
    
    -- color:extract_palette()
    -- self.timer:every(1, function()
    --     if color:is_palette_changed() then
    --         color:extract_palette()
    --     end
    -- end)
    
    -- global canvas and stuff
    self.canvas_scale = 1
    self.canvas_divider = 1
    width, height = width/self.canvas_divider, height/self.canvas_divider
    self.canvas = graphics.new_canvas(width, height, {format = 'srgba8'})
    self.canvas_x, self.canvas_y = 0, 0
    self.canvas:setFilter('nearest')
    graphics.set_line_style('rough')
    
    self.time_scale = 1

    local controllers = {}
    recursive_enumerate('controllers', controllers)
    require_files(controllers)
    
    local rooms = {}
    recursive_enumerate('rooms', rooms)
    require_files(rooms)
    
    local objects = {}
    recursive_enumerate('objects', objects)
    require_files(objects)
    
    self.font = graphics.new_font(path .. 'andina.ttf', 30)
    profiler:load(self.font)
    profiler.show = true
    
    log:init()

    self.os = love.system.getOS()
    -- if self.os == 'Windows' then
        gamestate.register_events({'mousepressed', 'mousemoved', 'mousereleased', 'keypressed', 'keyreleased', 'wheelmoved'})
    -- elseif self.os == 'Android' then
    --     gamestate.register_events({'touchpressed', 'touchmoved', 'touchreleased'})
    -- end

    -- self.fxaa = love.graphics.newShader(pigic.fxaa)
    -- self.fxaa:send('fxaa_reduce_min', (1.0 / 128.0))
    -- self.fxaa:send('fxaa_reduce_mul', (1.0 / 8.0))
    -- self.fxaa:send('fxaa_span_max', 8.0)  

    self.curtain_scale = 0
end

function toolkit:update(dt)
    local dt = math.min(dt, 1/30) -- at least 30 fps

    log:update(dt)
    pigic:update(dt)
    self.timer:update(dt)
    gamestate.update(dt * self.time_scale)
end

function toolkit:draw()
	-- gamestate.current():draw_shadow()
	
    graphics.set_canvas{self.canvas, depth = true}
    -- graphics.clear(.2, .2, .2)
    graphics.clear(color.palette[20])
        gamestate.draw()
    graphics.set_canvas()

   --gamestate.draw()
    
    graphics.set_blend_mode('alpha', 'premultiplied')
    -- graphics.set_shader(self.xbr)
    -- graphics.set_shader(self.fxaa)
    graphics.draw(self.canvas, 0, 0, 0, self.canvas_scale * self.canvas_divider)
    graphics.set_shader()
    graphics.set_blend_mode('alpha')

    -- curtain
	if self.curtain_scale > 0 then
		love.graphics.setColor(148/255, 194/255, 84/255)
		love.graphics.circle('fill', width/2, height/2, width*2 * self.curtain_scale)
	end


    -- draw debug point
    graphics.draw_point_list()
    
    -- draw log
    local previous_font = graphics.get_font()
    graphics.set_font(self.font)
    log:draw()
    graphics.set_font(previous_font)
end

function toolkit:get_mouse_position()
    local mx, my = love.mouse.getPosition()
    return mx / self.canvas_scale, my / self.canvas_scale
end


function toolkit:switch(to)
    self.timer:tween(2, self, {curtain_scale = 1}, math.cubic_in_out, function()
        gamestate.switch(to)
        self.timer:tween(2, self, {curtain_scale = 0}, math.cubic_in_out)
    end)
end


function love.resize(w, h)
    local default_ratio = width/height
    local new_ratio = w/h
    if new_ratio < default_ratio then
        toolkit.canvas_scale = w / width
        -- toolkit.canvas_x = 0
        -- toolkit.canvas_y = h / 2 - (toolkit.canvas_scale * height / 2)
    elseif new_ratio > default_ratio then
        toolkit.canvas_scale = h / height
        -- toolkit.canvas_x = w / 2 - (toolkit.canvas_scale * width / 2)
        -- toolkit.canvas_y = 0
    end
end


return toolkit