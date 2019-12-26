--[[
Light Math library created by ShoesForClues Copyright (c) 2019

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local lmath={
	_version={0,0,5};
}

--Primitives
local sqrt  = math.sqrt
local floor = math.floor
local tan   = math.tan
local rad   = math.rad
local pi    = math.pi

--Functions
lmath.clamp=function(v,min,max)
	if v<min or v~=v then
		return min
	elseif v>max then
		return max
	end
	return v
end

lmath.lerp=function(start,goal,t)
	return start*(1-t)+goal*t
end

--Data Types
local vector2  = {}; vector2.__index  = vector2
local vector3  = {}; vector3.__index  = vector3
local matrix44 = {}; matrix44.__index = matrix44
local quat     = {}; quat.__index     = quat
local rect     = {}; rect.__index     = rect
local udim2    = {}; udim2.__index    = udim2
local color3   = {}; color3.__index   = color3
local color4   = {}; color4.__index   = color4

------------------------------[Vector2]------------------------------
vector2.new=function(x,y)
	return setmetatable({
		x=x or 0,
		y=y or 0
	},vector2)
end
vector2.__tostring=function(a)
	return ("%f, %f"):format(a.x,a.y)
end
vector2.__unm=function(a)
	return vector2.new(-a.x,-a.y)
end
vector2.__add=function(a,b)
	return vector2.new(a.x+b.x,a.y+b.y)
end
vector2.__sub=function(a,b)
	return vector2.new(a.x-b.x,a.y-b.y)
end
vector2.__mul=function(a,b)
	if type(a)=="number" then
		return vector2.new(a*b.x,a*b.y)
	elseif type(b)=="number" then
		return vector2.new(a.x*b,a.y*b)
	else
		return vector2.new(a.x*b.x,a.y*b.y)
	end
end
vector2.__div=function(a,b)
	if type(a)=="number" then
		return vector2.new(a/b.x,a/b.y)
	elseif type(b)=="number" then
		return vector2.new(a.x/b,a.y/b)
	else
		return vector2.new(a.x/b.x,a.y/b.y)
	end
end
vector2.__eq=function(a,b)
	return a.x==b.x and a.y==b.y
end
vector2.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)
end
vector2.unpack=function(a)
	return a.x,a.y
end
vector2.lerp=lmath.lerp

------------------------------[Vector3]------------------------------
vector3.new=function(x,y,z)
	return setmetatable({
		x=x or 0,
		y=y or 0,
		z=z or 0
	},vector3)
end
vector3.__tostring=function(a)
	return ("%f, %f, %f"):format(a.x,a.y,a.z)
end
vector3.__unm=function(a)
	return vector3.new(-a.x,-a.y,-a.z)
end
vector3.__add=function(a,b)
	return vector3.new(a.x+b.x,a.y+b.y,a.z+b.z)
end
vector3.__sub=function(a,b)
	return vector3.new(a.x-b.x,a.y-b.y,a.z-b.z)
end
vector3.__mul=function(a,b)
	if type(a)=="number" then
		return vector3.new(a*b.x,a*b.y,a*b.z)
	elseif type(b)=="number" then
		return vector3.new(a.x*b,a.y*b,a.z*b)
	else
		return vector3.new(a.x*b.x,a.y*b.y,a.z*b.z)
	end
end
vector3.__div=function(a,b)
	if type(a)=="number" then
		return vector3.new(a/b.x,a/b.y,a/b.z)
	elseif type(b)=="number" then
		return vector3.new(a.x/b,a.y/b,a.z/b)
	else
		return vector3.new(a.x/b.x,a.y/b.y,a.z/b.z)
	end
end
vector3.__eq=function(a,b)
	return a.x==b.x and a.y==b.y and a.z==b.z
end
vector3.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)+(a.z*b.z)
end
vector3.cross=function(a,b)
	return vector3.new(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x)
end
vector3.unpack=function(a)
	return a.x,a.y,a.z
end
vector3.lerp=lmath.lerp

------------------------------[Matrix 4x4]------------------------------
matrix44.new=function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16)
	return setmetatable({
		{a1 or 0,a2 or 0,a3 or 0,a4 or 0},
		{a5 or 0,a6 or 0,a7 or 0,a8 or 0},
		{a9 or 0,a10 or 0,a11 or 0,a12 or 0},
		{a13 or 0,a14 or 0,a15 or 0,a16 or 0}
	},matrix44)
end
matrix44.from_perspective=function(fov,aspect,near,far)
	local scale=tan(rad(fov)/2)
	return matrix44.new(
		1/(scale*aspect),0,0,0,
		0,1/scale,0,0,
		0,0,-(far+near)/(far-near),-1,
		0,0,-(2*far*near)/(far-near),0
	)
end
matrix44.__tostring=function(a)
	return ("%f, %f, %f, %f\t%f, %f, %f, %f\t%f, %f, %f, %f\t%f, %f, %f, %f"):format(
		a[1][1],a[1][2],a[1][3],a[1][4],
		a[2][1],a[2][2],a[2][3],a[2][4],
		a[3][1],a[3][2],a[3][3],a[3][4],
		a[4][1],a[4][2],a[4][3],a[4][4]
	)
end
matrix44.__unm=function(a)
	return matrix44.new(
		-a[1][1],-a[1][2],-a[1][3],-a[1][4],
		-a[2][1],-a[2][2],-a[2][3],-a[2][4],
		-a[3][1],-a[3][2],-a[3][3],-a[3][4],
		-a[4][1],-a[4][2],-a[4][3],-a[4][4]
	)
end
matrix44.__add=function(a,b)
	return matrix44.new(
		a[1][1]+b[1][1],a[1][2]+b[1][2],a[1][3]+b[1][3],a[1][4]+b[1][4],
		a[2][1]+b[2][1],a[2][2]+b[2][2],a[2][3]+b[2][3],a[2][4]+b[2][4],
		a[3][1]+b[3][1],a[3][2]+b[3][2],a[3][3]+b[3][3],a[3][4]+b[3][4],
		a[4][1]+b[4][1],a[4][2]+b[4][2],a[4][3]+b[4][3],a[4][4]+b[4][4]
	)
end
matrix44.__sub=function(a,b)
	return matrix44.new(
		a[1][1]-b[1][1],a[1][2]-b[1][2],a[1][3]-b[1][3],a[1][4]-b[1][4],
		a[2][1]-b[2][1],a[2][2]-b[2][2],a[2][3]-b[2][3],a[2][4]-b[2][4],
		a[3][1]-b[3][1],a[3][2]-b[3][2],a[3][3]-b[3][3],a[3][4]-b[3][4],
		a[4][1]-b[4][1],a[4][2]-b[4][2],a[4][3]-b[4][3],a[4][4]-b[4][4]
	)
end
matrix44.__mul=function(a,b)
	if type(a)=="number" then
		return matrix44.new(
			a*b[1][1],a*b[1][2],a*b[1][3],a*b[1][4],
			a*b[2][1],a*b[2][2],a*b[2][3],a*b[2][4],
			a*b[3][1],a*b[3][2],a*b[3][3],a*b[3][4],
			a*b[4][1],a*b[4][2],a*b[4][3],a*b[4][4]
		)
	elseif type(b)=="number" then
		return matrix44.new(
			b*a[1][1],b*a[1][2],b*a[1][3],b*a[1][4],
			b*a[2][1],b*a[2][2],b*a[2][3],b*a[2][4],
			b*a[3][1],b*a[3][2],b*a[3][3],b*a[3][4],
			b*a[4][1],b*a[4][2],b*a[4][3],b*a[4][4]
		)
	else
		return matrix44.new(
			
		)
	end
end
matrix44.__div=function(a,b)
	if type(a)=="number" then
		return matrix44.new(
			a/b[1][1],a/b[1][2],a/b[1][3],a/b[1][4],
			a/b[2][1],a/b[2][2],a/b[2][3],a/b[2][4],
			a/b[3][1],a/b[3][2],a/b[3][3],a/b[3][4],
			a/b[4][1],a/b[4][2],a/b[4][3],a/b[4][4]
		)
	elseif type(b)=="number" then
		return matrix44.new(
			b/a[1][1],b/a[1][2],b/a[1][3],b/a[1][4],
			b/a[2][1],b/a[2][2],b/a[2][3],b/a[2][4],
			b/a[3][1],b/a[3][2],b/a[3][3],b/a[3][4],
			b/a[4][1],b/a[4][2],b/a[4][3],b/a[4][4]
		)
	else
		return matrix44.new(
			
		)
	end
end
matrix44.__eq=function(a,b)
	return (
		a[1][1]==b[1][1] and a[1][2]==b[1][2] and a[1][3]==b[1][3] and a[1][4]==b[1][4] and
		a[2][1]==b[2][1] and a[2][2]==b[2][2] and a[2][3]==b[2][3] and a[2][4]==b[2][4] and
		a[3][1]==b[3][1] and a[3][2]==b[3][2] and a[3][3]==b[3][3] and a[3][4]==b[3][4] and
		a[4][1]==b[4][1] and a[4][2]==b[4][2] and a[4][3]==b[4][3] and a[4][4]==b[4][4]
	)
end
matrix44.unpack=function(a)
	return a[1][1],a[1][2],a[1][3],a[1][4],
		a[2][1],a[2][2],a[2][3],a[2][4],
		a[3][1],a[3][2],a[3][3],a[3][4],
		a[4][1],a[4][2],a[4][3],a[4][4]
end

------------------------------[UDim2]------------------------------
udim2.new=function(x_scale,x_offset,y_scale,y_offset)
	return setmetatable({
		x={offset=x_offset or 0,scale=x_scale or 0},
		y={offset=y_offset or 0,scale=y_scale or 0}
	},udim2)
end
udim2.__tostring=function(a)
	return ("%f, %d, %f, %d"):format(a.x.scale,a.x.offset,a.y.scale,a.y.offset)
end
udim2.__unm=function(a)
	return udim2.new(-a.x.scale,-a.x.offset,-a.y.scale,-a.y.offset)
end
udim2.__add=function(a,b)
	return udim2.new(a.x.scale+b.x.scale,a.x.offset+b.x.offset,a.y.scale+b.y.scale,a.y.offset+b.y.offset)
end
udim2.__sub=function(a,b)
	return udim2.new(a.x.scale-b.x.scale,a.x.offset-b.x.offset,a.y.scale-b.y.scale,a.y.offset-b.y.offset)
end
udim2.__mul=function(a,b)
	if type(a)=="number" then
		return udim2.new(a*b.x.scale,a*b.x.offset,a*b.y.scale,a*b.y.offset)
	elseif type(b)=="number" then
		return udim2.new(a.x.scale*b,a.x.offset*b,a.y.scale*b,a.y.offset*b)
	else
		return udim2.new(a.x.scale*b.x.scale,a.x.offset*b.x.offset,a.y.scale*b.y.scale,a.y.offset*b.y.offset)
	end
end
udim2.__div=function(a,b)
	if type(a)=="number" then
		return udim2.new(a/b.x.scale,a/b.x.offset,a/b.y.scale,a/b.y.offset)
	elseif type(b)=="number" then
		return udim2.new(a.x.scale/b,a.x.offset/b,a.y.scale/b,a.y.offset/b)
	else
		return udim2.new(a.x.scale/b.x.scale,a.x.offset/b.x.offset,a.y.scale/b.y.scale,a.y.offset/b.y.offset)
	end
end
udim2.__eq=function(a,b)
	return a.x.scale==b.x.scale and a.x.offset==b.x.offset and a.y.scale==b.y.scale and a.y.offset==b.y.offset
end
udim2.unpack=function(a)
	return a.x.scale,a.x.offset,a.y.scale,a.y.offset
end
udim2.lerp=lmath.lerp

------------------------------[Rect]------------------------------
rect.new=function(min_x,min_y,max_x,max_y)
	return setmetatable({
		min_x=min_x or 0,
		min_y=min_y or 0,
		max_x=max_x or 0,
		max_y=max_y or 0
	},rect)
end
rect.__tostring=function(a)
	return ("%d, %d, %d, %d"):format(a.min_x,a.min_y,a.max_x,a.max_y)
end
rect.__unm=function(a)
	return rect.new(-a.min_x,-a.min_y,-a.max_x,-a.max_y)
end
rect.__add=function(a,b)
	return rect.new(a.min_x+b.min_x,a.min_y+b.min_y,a.max_x+b.max_x,a.max_y+b.max_y)
end
rect.__sub=function(a,b)
	return rect.new(a.min_x-b.min_x,a.min_y-b.min_y,a.max_x-b.max_x,a.max_y-b.max_y)
end
rect.__mul=function(a,b)
	if type(a)=="number" then
		return rect.new(a*b.min_x,a*b.min_y,a*b.max_x,a*b.max_y)
	elseif type(b)=="number" then
		return rect.new(a.min_x*b,a.min_y*b,a.max_x*b,a.max_y*b)
	else
		return rect.new(a.min_x*b.min_x,a.min_y*b.min_y,a.max_x*b.max_x,a.max_y*b.max_y)
	end
end
rect.__div=function(a,b)
	if type(a)=="number" then
		return rect.new(a/b.min_x,a/b.min_y,a/b.max_x,a/b.max_y)
	elseif type(b)=="number" then
		return rect.new(a.min_x/b,a.min_y/b,a.max_x/b,a.max_y/b)
	else
		return rect.new(a.min_x/b.min_x,a.min_y/b.min_y,a.max_x/b.max_x,a.max_y/b.max_y)
	end
end
rect.__eq=function(a,b)
	return a.min_x==b.min_x and a.min_y==b.min_y and a.max_x==b.max_x and a.max_y==b.max_y
end
rect.clamp=function(a,b)
	return rect.new(
		lmath.clamp(a.min_x,b.min_x,b.max_x),
		lmath.clamp(a.min_y,b.min_y,b.max_y),
		lmath.clamp(a.max_x,b.min_x,b.max_x),
		lmath.clamp(a.max_y,b.min_y,b.max_y)
	)
end
rect.unpack=function(a)
	return a.min_x,a.min_y,a.max_x,a.max_y
end
rect.lerp=lmath.lerp

------------------------------[Color3]------------------------------
color3.new=function(r,g,b)
	return setmetatable({
		r=r or 0,
		g=g or 0,
		b=b or 0
	},color3)
end
color3.from_hex=function(hex)
	hex=hex:gsub("#","")
	return color3.new(
		tonumber("0x"..hex:sub(1,2))/255,
		tonumber("0x"..hex:sub(3,4))/255,
		tonumber("0x"..hex:sub(5,6))/255
	)
end
color3.__tostring=function(a)
	return ("%d, %d, %d"):format(a.r*255,a.g*255,a.b*255)
end
color3.__unm=function(a)
	return color3.new(-a.r,-a.g,-a.b)
end
color3.__add=function(a,b)
	return color3.new(a.r+b.r,a.g+b.g,a.b+b.b)
end
color3.__sub=function(a,b)
	return color3.new(a.r-b.r,a.g-b.g,a.b-b.b)
end
color3.__mul=function(a,b)
	if type(a)=="number" then
		return color3.new(a*b.r,a*b.g,a*b.b)
	elseif type(b)=="number" then
		return color3.new(a.r*b,a.g*b,a.b*b)
	else
		return color3.new(a.r*b.r,a.g*b.g,a.b*b.b)
	end
end
color3.__div=function(a,b)
	if type(a)=="number" then
		return color3.new(a/b.r,a/b.g,a/b.b)
	elseif type(b)=="number" then
		return color3.new(a.r/b,a.g/b,a.b/b)
	else
		return color3.new(a.r/b.r,a.g/b.g,a.b/b.b)
	end
end
color3.__eq=function(a,b)
	return a.r==b.r and a.g==b.g and a.b==b.b
end
color3.unpack=function(a)
	return a.r,a.g,a.b
end
color3.lerp=lmath.lerp

lmath.vector2  = setmetatable(vector2,vector2)
lmath.vector3  = setmetatable(vector3,vector3)
lmath.matrix44 = setmetatable(matrix44,matrix44)
lmath.rect     = setmetatable(rect,rect)
lmath.udim2    = setmetatable(udim2,udim2)
lmath.color3   = setmetatable(color3,color3)

return lmath