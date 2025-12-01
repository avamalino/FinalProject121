-- written by groverbuger for g3d
-- september 2021
-- MIT license

-- pirated by PIGIC --

-- local collisions = require(g3d.path .. '.collisions')
-- local vectors = require(g3d.path .. '.vectors')
-- local camera = require(g3d.path .. '.camera')

----------------------------------------------------------------------------------------------------
-- define a Platform class
----------------------------------------------------------------------------------------------------
local Platform = Object:extend()
Platform.vertex_format = {
    {'VertexPosition', 'float', 3},
    {'VertexTexCoord', 'float', 2},
    {'VertexNormal', 'float', 3},
    {'VertexColor', 'byte', 4},
}

local function is_exclude_list(name)
	return name:find('player') or name:find('cam') or name:find('lava') or name:find('cannon') or name:find('spring')
end

function Platform:new(verts, textures, translation, rotation, scale)
	-- xray optimized model
	local verts_minimal = pigic.platformloader(verts, false, true, true)
	local verts_minimal_combined = {}
	for name, verts in pairs(verts_minimal) do
		local name = name:lower()
		if is_exclude_list(name) then
			-- pass
		else
			for _, v in ipairs(verts) do
				table.insert(verts_minimal_combined, v)
			end
		end
	end
	self.minimal = love.graphics.newMesh(self.vertex_format, verts_minimal_combined, "triangles")
	
	-- visual models
	self.objects = {}
	self.textures = {}
	for tag, data in pairs(textures) do
		if type(data) == 'string' then
			self.textures[tag] = love.graphics.newImage(data)
			self.textures[tag]:setWrap('repeat')
		elseif type(data) == 'table' then
			self.textures[tag] = data
		end
	end
	local objects = pigic.platformloader(verts, false, true, true)
	for name, verts in pairs(objects) do
		local name = name:lower()
		if is_exclude_list(name) then
			-- pass			
		else
			local mesh = love.graphics.newMesh(pigic.model.vertex_format, verts, 'triangles')
			local object = {verts = verts, mesh = mesh}
			for tag, data in pairs(self.textures) do
				if (name:find(tag)) then
					if type(data) == 'userdata' then
						mesh:setTexture(data)
					elseif type(data) == 'table' then
						object.color = data
					end
					if (tag ~= 'cube') then object.no_triplanar = true end
				end
			end
			if not object.no_triplanar then -- define grass-ground transition y position
				local y = verts[1][2]
				for v = 2, #verts do
					-- idk, but a- means candidate
					local ay = verts[v][2]
					if ay > y then y = ay end
				end
				object.y = y - 1
			end
			if (name:find('shadow')) then
				object.cast_shadow = true
			end
			table.insert(self.objects, object)
		end
    end
end


function Platform:update(dt, anim)

end


function Platform:draw()
    pass.push()
    local shader = gamestate.current().active_shader
    shader:send('modelMatrix', 'column', pass.transform)
    if shader:hasUniform('modelMatrixInverse') then
        shader:send('modelMatrixInverse', 'column', mat4():transpose(mat4():invert(pass.transform)))
    end	
	local t = gamestate.current().player.translation
	shader:send('centerPoint', {t.x, t.y, t.z})

	local triplanarable = shader:hasUniform('useTriplanar')
	for _, v in ipairs(self.objects) do
		if triplanarable then
			if v.no_triplanar then
				shader:send('useTriplanar', false)
				if v.color then graphics.set_color(v.color) end
			else
				shader:send('useTriplanar', true)
				shader:send('yTransition', v.y)
			end
		end
		love.graphics.draw(v.mesh)
		graphics.white()
	end
    pass.pop()
end

function Platform:draw_minimal()
    pass.push()
    local shader = gamestate.current().active_shader
    shader:send('modelMatrix', 'column', pass.transform)
    if shader:hasUniform('modelMatrixInverse') then
        shader:send('modelMatrixInverse', 'column', mat4():transpose(mat4():invert(pass.transform)))
    end	
	love.graphics.draw(self.minimal)
	-- for _, v in ipairs(self.objects) do love.graphics.draw(v.mesh) end
    pass.pop()
end


function Platform:draw_cast_shadow()
	pass.push()
    local shader = gamestate.current().active_shader
    shader:send('modelMatrix', 'column', pass.transform)
    if shader:hasUniform('modelMatrixInverse') then
        shader:send('modelMatrixInverse', 'column', mat4():transpose(mat4():invert(pass.transform)))
    end

	for _, v in ipairs(self.objects) do
		if v.cast_shadow then love.graphics.draw(v.mesh) end
	end
    pass.pop()
end

function Platform:init_animation()
	self.anim = anim9(self.anims)
	self.anim.anim_tracks = {}
end

-- function Platform:set_animation(anim)
-- 	self.anim = anim
-- end

function Platform:register_track(name, weight, rate)
	self.anim.anim_tracks[name] = self.anim:new_track(name, weight, rate)
end

function Platform:play_animation(name)
	self.anim:play(self.anim.anim_tracks[name])
	self.anim:update(0)
end

function Platform:stop_animation(name)
	self.anim:stop(self.anim.anim_tracks[name])
	self.anim:update(0)
end

function Platform:transition_animation(name, length)
	self.anim:transition(self.anim.anim_tracks[name],length)
	self.anim:update(0)
end

function Platform:reset_animation(clear_locked)
	--Will delete all animation tracks
	self.anim:reset(clear_locked)
	self.anim:update(0)
end


return Platform