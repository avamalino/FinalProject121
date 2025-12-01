-- watered down version of cpml.mat4
-- literally just for anim9, cuz i got not idea where the issues are with my modified version of cpml
local modules   = (...):gsub('%.[^%.]+$', '') .. "."
local vec3      = cpml.vec3
local sqrt      = math.sqrt
local cos       = math.cos
local sin       = math.sin
local tan       = math.tan
local rad       = math.rad
local mat4      = {}
local mat4_mt   = {}

-- Private constructor.
local function new(m)
	m = m or {
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	}
	m._m = m
	return setmetatable(m, mat4_mt)
end
 -- Convert matrix into identity
local function identity(m)
	m[1],  m[2],  m[3],  m[4]  = 1, 0, 0, 0
	m[5],  m[6],  m[7],  m[8]  = 0, 1, 0, 0
	m[9],  m[10], m[11], m[12] = 0, 0, 1, 0
	m[13], m[14], m[15], m[16] = 0, 0, 0, 1
	return m
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi, the_type
if type(jit) == "table" and jit.status() then
   --  status, ffi = pcall(require, "ffi")
    if status then
        ffi.cdef "typedef struct { double _m[16]; } cpml_mat4;"
        new = ffi.typeof("cpml_mat4")
    end
end

-- Statically allocate a temporary variable used in some of our functions.
local tmp = new()
local tm4 = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
local tv4 = { 0, 0, 0, 0 }
local forward, side, new_up = vec3(), vec3(), vec3()

--- The public constructor.
-- @param a Can be of four types: </br>
-- table Length 16 (4x4 matrix)
-- table Length 9 (3x3 matrix)
-- table Length 4 (4 vec4s)
-- nil
-- @treturn mat4 out
function mat4.new(a)
	local out = new()

	-- 4x4 matrix
	if type(a) == "table" and #a == 16 then
		for i = 1, 16 do
			out[i] = tonumber(a[i])
		end

	-- 3x3 matrix
	elseif type(a) == "table" and #a == 9 then
		out[1], out[2],  out[3]  = a[1], a[2], a[3]
		out[5], out[6],  out[7]  = a[4], a[5], a[6]
		out[9], out[10], out[11] = a[7], a[8], a[9]
		out[16] = 1

	-- 4 vec4s
	elseif type(a) == "table" and type(a[1]) == "table" then
		local idx = 1
		for i = 1, 4 do
			for j = 1, 4 do
				out[idx] = a[i][j]
				idx = idx + 1
			end
		end

	-- nil
	else
		out[1]  = 1
		out[6]  = 1
		out[11] = 1
		out[16] = 1
	end

	return out
end

--- Create an identity matrix.
-- @tparam mat4 a Matrix to overwrite
-- @treturn mat4 out
function mat4.identity(a)
	return identity(a or new())
end

--- Create a matrix from a transform.
-- @tparam vec3 trans Translation vector
-- @tparam quat rot Rotation quaternion
-- @tparam vec3 scale Scale vector
-- @treturn mat4 out
function mat4.from_transform(trans, rot, scale)
	local angle, axis = rot:to_angle_axis()
	local l = axis:len()

	if l == 0 then
		return new()
	end

	local x, y, z = axis.x / l, axis.y / l, axis.z / l
	local c = cos(angle)
	local s = sin(angle)

	return new {
		x*x*(1-c)+c,   y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
		x*y*(1-c)-z*s, y*y*(1-c)+c,   y*z*(1-c)+x*s, 0,
		x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c,   0,
		trans.x, trans.y, trans.z, 1
	}
end

--- Multiply two matrices.
-- @tparam mat4 out Matrix to store the result
-- @tparam mat4 a Left hand operand
-- @tparam mat4 b Right hand operand
-- @treturn mat4 out Matrix equivalent to "apply b, then a"
function mat4.mul(out, a, b)
	tm4[1]  = b[1]  * a[1] + b[2]  * a[5] + b[3]  * a[9]  + b[4]  * a[13]
	tm4[2]  = b[1]  * a[2] + b[2]  * a[6] + b[3]  * a[10] + b[4]  * a[14]
	tm4[3]  = b[1]  * a[3] + b[2]  * a[7] + b[3]  * a[11] + b[4]  * a[15]
	tm4[4]  = b[1]  * a[4] + b[2]  * a[8] + b[3]  * a[12] + b[4]  * a[16]
	tm4[5]  = b[5]  * a[1] + b[6]  * a[5] + b[7]  * a[9]  + b[8]  * a[13]
	tm4[6]  = b[5]  * a[2] + b[6]  * a[6] + b[7]  * a[10] + b[8]  * a[14]
	tm4[7]  = b[5]  * a[3] + b[6]  * a[7] + b[7]  * a[11] + b[8]  * a[15]
	tm4[8]  = b[5]  * a[4] + b[6]  * a[8] + b[7]  * a[12] + b[8]  * a[16]
	tm4[9]  = b[9]  * a[1] + b[10] * a[5] + b[11] * a[9]  + b[12] * a[13]
	tm4[10] = b[9]  * a[2] + b[10] * a[6] + b[11] * a[10] + b[12] * a[14]
	tm4[11] = b[9]  * a[3] + b[10] * a[7] + b[11] * a[11] + b[12] * a[15]
	tm4[12] = b[9]  * a[4] + b[10] * a[8] + b[11] * a[12] + b[12] * a[16]
	tm4[13] = b[13] * a[1] + b[14] * a[5] + b[15] * a[9]  + b[16] * a[13]
	tm4[14] = b[13] * a[2] + b[14] * a[6] + b[15] * a[10] + b[16] * a[14]
	tm4[15] = b[13] * a[3] + b[14] * a[7] + b[15] * a[11] + b[16] * a[15]
	tm4[16] = b[13] * a[4] + b[14] * a[8] + b[15] * a[12] + b[16] * a[16]

	for i=1, 16 do
		out[i] = tm4[i]
	end

	return out
end

--- Invert a matrix.
-- @tparam mat4 out Matrix to store the result
-- @tparam mat4 a Matrix to invert
-- @treturn mat4 out
function mat4.invert(out, a)
	tm4[1]  =  a[6] * a[11] * a[16] - a[6] * a[12] * a[15] - a[10] * a[7] * a[16] + a[10] * a[8] * a[15] + a[14] * a[7] * a[12] - a[14] * a[8] * a[11]
	tm4[2]  = -a[2] * a[11] * a[16] + a[2] * a[12] * a[15] + a[10] * a[3] * a[16] - a[10] * a[4] * a[15] - a[14] * a[3] * a[12] + a[14] * a[4] * a[11]
	tm4[3]  =  a[2] * a[7]  * a[16] - a[2] * a[8]  * a[15] - a[6]  * a[3] * a[16] + a[6]  * a[4] * a[15] + a[14] * a[3] * a[8]  - a[14] * a[4] * a[7]
	tm4[4]  = -a[2] * a[7]  * a[12] + a[2] * a[8]  * a[11] + a[6]  * a[3] * a[12] - a[6]  * a[4] * a[11] - a[10] * a[3] * a[8]  + a[10] * a[4] * a[7]
	tm4[5]  = -a[5] * a[11] * a[16] + a[5] * a[12] * a[15] + a[9]  * a[7] * a[16] - a[9]  * a[8] * a[15] - a[13] * a[7] * a[12] + a[13] * a[8] * a[11]
	tm4[6]  =  a[1] * a[11] * a[16] - a[1] * a[12] * a[15] - a[9]  * a[3] * a[16] + a[9]  * a[4] * a[15] + a[13] * a[3] * a[12] - a[13] * a[4] * a[11]
	tm4[7]  = -a[1] * a[7]  * a[16] + a[1] * a[8]  * a[15] + a[5]  * a[3] * a[16] - a[5]  * a[4] * a[15] - a[13] * a[3] * a[8]  + a[13] * a[4] * a[7]
	tm4[8]  =  a[1] * a[7]  * a[12] - a[1] * a[8]  * a[11] - a[5]  * a[3] * a[12] + a[5]  * a[4] * a[11] + a[9]  * a[3] * a[8]  - a[9]  * a[4] * a[7]
	tm4[9]  =  a[5] * a[10] * a[16] - a[5] * a[12] * a[14] - a[9]  * a[6] * a[16] + a[9]  * a[8] * a[14] + a[13] * a[6] * a[12] - a[13] * a[8] * a[10]
	tm4[10] = -a[1] * a[10] * a[16] + a[1] * a[12] * a[14] + a[9]  * a[2] * a[16] - a[9]  * a[4] * a[14] - a[13] * a[2] * a[12] + a[13] * a[4] * a[10]
	tm4[11] =  a[1] * a[6]  * a[16] - a[1] * a[8]  * a[14] - a[5]  * a[2] * a[16] + a[5]  * a[4] * a[14] + a[13] * a[2] * a[8]  - a[13] * a[4] * a[6]
	tm4[12] = -a[1] * a[6]  * a[12] + a[1] * a[8]  * a[10] + a[5]  * a[2] * a[12] - a[5]  * a[4] * a[10] - a[9]  * a[2] * a[8]  + a[9]  * a[4] * a[6]
	tm4[13] = -a[5] * a[10] * a[15] + a[5] * a[11] * a[14] + a[9]  * a[6] * a[15] - a[9]  * a[7] * a[14] - a[13] * a[6] * a[11] + a[13] * a[7] * a[10]
	tm4[14] =  a[1] * a[10] * a[15] - a[1] * a[11] * a[14] - a[9]  * a[2] * a[15] + a[9]  * a[3] * a[14] + a[13] * a[2] * a[11] - a[13] * a[3] * a[10]
	tm4[15] = -a[1] * a[6]  * a[15] + a[1] * a[7]  * a[14] + a[5]  * a[2] * a[15] - a[5]  * a[3] * a[14] - a[13] * a[2] * a[7]  + a[13] * a[3] * a[6]
	tm4[16] =  a[1] * a[6]  * a[11] - a[1] * a[7]  * a[10] - a[5]  * a[2] * a[11] + a[5]  * a[3] * a[10] + a[9]  * a[2] * a[7]  - a[9]  * a[3] * a[6]

	for i=1, 16 do
		out[i] = tm4[i]
	end

	local det = a[1] * out[1] + a[2] * out[5] + a[3] * out[9] + a[4] * out[13]

	if det == 0 then return a end

	det = 1 / det

	for i = 1, 16 do
		out[i] = out[i] * det
	end

	return out
end

--- Return a boolean showing if a table is or is not a mat4.
-- @tparam mat4 a Matrix to be tested
-- @treturn boolean is_mat4
function mat4.is_mat4(a)
	if type(a) == "cdata" then
		return ffi.istype("cpml_mat4", a)
	end

	if type(a) ~= "table" then
		return false
	end

	for i = 1, 16 do
		if type(a[i]) ~= "number" then
			return false
		end
	end

	return true
end

--- Convert a matrix to row vec4s.
-- @tparam mat4 a Matrix to be converted
-- @treturn table vec4s
function mat4.to_vec4s(a)
	return {
		{ a[1],  a[2],  a[3],  a[4]  },
		{ a[5],  a[6],  a[7],  a[8]  },
		{ a[9],  a[10], a[11], a[12] },
		{ a[13], a[14], a[15], a[16] }
	}
end


function mat4_mt.__index(t, k)
	if type(t) == "cdata" then
		if type(k) == "number" then
			return t._m[k-1]
		end
	end

	return rawget(mat4, k)
end

function mat4_mt.__newindex(t, k, v)
	if type(t) == "cdata" then
		if type(k) == "number" then
			t._m[k-1] = v
		end
	end
end

mat4_mt.__tostring = mat4.to_string

function mat4_mt.__call(_, a)
	return mat4.new(a)
end

function mat4_mt.__unm(a)
	return new():invert(a)
end

function mat4_mt.__eq(a, b)
	if not mat4.is_mat4(a) or not mat4.is_mat4(b) then
		return false
	end

	for i = 1, 16 do
		if not utils.tolerance(b[i]-a[i], constants.FLT_EPSILON) then
			return false
		end
	end

	return true
end

function mat4_mt.__mul(a, b)
	assert(mat4.is_mat4(a), "__mul: Wrong argument type for left hand operand. (<cpml.mat4> expected)")

	if vec3.is_vec3(b) then
		return vec3(mat4.mul_vec4({}, a, { b.x, b.y, b.z, 1 }))
	end

	assert(mat4.is_mat4(b) or #b == 4, "__mul: Wrong argument type for right hand operand. (<cpml.mat4> or table #4 expected)")

	if mat4.is_mat4(b) then
		return new():mul(a, b)
	end

	return mat4.mul_vec4({}, a, b)
end

if status then
	xpcall(function() -- Allow this to silently fail; assume failure means someone messed with package.loaded
		ffi.metatype(new, mat4_mt)
	end, function() end)
end

return setmetatable({}, mat4_mt)
