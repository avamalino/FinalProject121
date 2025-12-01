-- pigic (PIrated G3d mashed wIth Cpml)
--[[
      ___                       ___                       ___
     /\  \          ___        /\  \          ___        /\  \
    /::\  \        /\  \      /::\  \        /\  \      /::\  \
   /:/\:\  \       \:\  \    /:/\:\  \       \:\  \    /:/\:\  \
  /::\~\:\  \      /::\__\  /:/  \:\  \      /::\__\  /:/  \:\  \
 /:/\:\ \:\__\  __/:/\/__/ /:/__/_\:\__\  __/:/\/__/ /:/__/ \:\__\
 \/__\:\/:/  / /\/:/  /    \:\  /\ \/__/ /\/:/  /    \:\  \  \/__/
      \::/  /  \::/__/      \:\ \:\__\   \::/__/      \:\  \
       \/__/    \:\__\       \:\/:/  /    \:\__\       \:\  \
                 \/__/        \::/  /      \/__/        \:\__\
                               \/__/                     \/__/
]]


--[[
-------------------------------------------------------------------------------
RIGHT HAND RULE
      +x: right
	+y: top
	+z: to the screen
-------------------------------------------------------------------------------
]]

local path        = ... .. '/'

pigic = {}
-- pigic.vert_shader       = path .. 'shaders/g3d.vert'
-- pigic.frag_normal       = path .. 'shaders/g3d_normal.frag'
-- pigic.frag_unlit        = path .. 'shaders/g3d_unlit.frag'
-- pigic.frag_phong        = path .. 'shaders/phong.frag'
-- pigic.phong_shadow      = path .. 'shaders/phong_shadow.glsl'
-- pigic.glsl_depth        = path .. 'shaders/depth.glsl'
-- pigic.unlit_shadow      = path .. 'shaders/unlit_shadow.glsl'
pigic.unlit_web         = path .. 'shaders/unlit_web.glsl'
-- pigic.cel_shadow        = path .. 'shaders/cel_shadow.glsl'
-- pigic.glsl_xray         = path .. 'shaders/xray.glsl'
-- pigic.frag_coloronly    = path .. 'shaders/coloronly.frag'
-- pigic.triplanar         = path .. 'shaders/triplanar.glsl'
-- pigic.platform_shader   = path .. 'shaders/platform.glsl'
-- pigic.fxaa              = path .. 'shaders/fxaa.glsl'

-- pigic.shader      = love.graphics.newShader(pigic.vert_shader, pigic.frag_unlit)
pigic.objloader   = require(path .. 'objloader')
pigic.platformloader   = require(path .. 'platformloader')
pigic.model       = require(path .. 'model')
pigic.platform    = require(path .. 'platform')
pigic.camera      = require(path .. 'camera')
pigic.pass        = require(path .. 'pass')
pigic.world       = require(path .. 'world')
pigic.verlet      = require(path .. 'verlet')
pigic.collision   = path .. 'collision'

function pigic:update(dt)
	self.pass.transform:identity()
	self.pass.matrix_stack = {}
end

-- get rid of g3d from the global namespace and return it instead
local pigic = pigic
_G.pigic = nil
return pigic
