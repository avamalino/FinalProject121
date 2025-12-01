-- written by groverbuger for g3d
-- september 2021
-- MIT license

-- pirated by PIGIC --

-- local collisions = require(g3d.path .. ".collisions")
-- local vectors = require(g3d.path .. ".vectors")
-- local camera = require(g3d.path .. ".camera")

----------------------------------------------------------------------------------------------------
-- define a model class
----------------------------------------------------------------------------------------------------

-- local iqm, anim9

-- if FFIEXISTS then
	-- iqm = require("toolkit/lib/iqm")
	-- anim9 = require("toolkit/lib/anim9")
-- end

local Model = Object:extend()
Model.vertex_format = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexNormal", "float", 3},
    {"VertexColor", "byte", 4},
}

function Model:new(verts, texture, load_objects)
	local extension = verts:sub(-4,-1)
	if extension == ".obj" then
		if load_objects then
			local objects = pigic.objloader(verts, false, true, true)
			local vert_list
			for name, vert in pairs(objects) do
				if name:find('COLLIDER') then 
					self.collider = vert
				else
					if not vert_list then
						vert_list = vert
					else
						for _, v in ipairs(vert) do
							table.insert(vert_list, v)
						end
					end
				end
			end
			self.verts = vert_list
			self.mesh = love.graphics.newMesh(self.vertex_format, self.verts, "triangles")
		else
			self.verts = pigic.objloader(verts, false, true, false)    
			self.mesh = love.graphics.newMesh(self.vertex_format, self.verts, "triangles")
		end
	-- elseif extension == ".iqm" then
	-- 	local data = iqm.load(verts)
	-- 	self.data = data
	-- 	self.verts = data.triangles
	-- 	self.mesh = data.mesh
	-- 	self.animated = true
	-- 	self.anims = iqm.load_anims(verts)
	end
	
	if texture then
        self.texture = texture and love.graphics.newImage(texture)
        self.texture:setFilter('nearest')
        self.texture:setWrap('repeat')
        self.mesh:setTexture(self.texture)
    end
end


function Model:update(dt, anim)
	if self.animated and self.anim then
		self.anim:update(dt)
	end
end


function Model:draw(scale)
    pass.push()
    if scale then pass.scale(scale) end
    local shader = gamestate.current().active_shader
    shader:send("modelMatrix", 'column', pass.transform)
    if shader:hasUniform("modelMatrixInverse") then
        shader:send("modelMatrixInverse", 'column', mat4():transpose(mat4():invert(pass.transform)))
    end
    if self.animated and shader:hasUniform("animated") then
		local animated = self.animated
		if self.animated and (not self.anim.current_pose) then
			animated = false
		end
		shader:send("animated", animated)
	end
	if self.animated and shader:hasUniform("u_pose") and self.anim and self.anim.current_pose then
		shader:send("u_pose", "column", unpack(self.anim.current_pose))
	end

    love.graphics.draw(self.mesh)
    pass.pop()
end


function Model:init_animation()
	self.anim = anim9(self.anims)
	self.anim.anim_tracks = {}
end

-- function Model:set_animation(anim)
-- 	self.anim = anim
-- end

function Model:register_track(name, weight, rate)
	self.anim.anim_tracks[name] = self.anim:new_track(name, weight, rate)
end

function Model:play_animation(name)
	self.anim:play(self.anim.anim_tracks[name])
	self.anim:update(0)
end

function Model:stop_animation(name)
	self.anim:stop(self.anim.anim_tracks[name])
	self.anim:update(0)
end

function Model:transition_animation(name, length)
	self.anim:transition(self.anim.anim_tracks[name],length)
	self.anim:update(0)
end

function Model:reset_animation(clear_locked)
	--Will delete all animation tracks
	self.anim:reset(clear_locked)
	self.anim:update(0)
end


return Model