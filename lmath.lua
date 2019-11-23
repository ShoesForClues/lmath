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
	_version={0,0,2};
}

--[Primitives]
local sqrt  = math.sqrt
local floor = math.floor

--[Functions]
lmath.clamp=function(v,min,max)
	if v<min or v~=v then
		return min
	elseif v>max then
		return max
	end
	return v
end

lmath.lerp=function(start,goal,percent)
	return start*(1-percent)+goal*percent
end

--[Data Types]
local vector2 = {lerp=lmath.lerp};vector2.__index=vector2
local vector3 = {lerp=lmath.lerp};vector3.__index=vector3
local rect    = {lerp=lmath.lerp};rect.__index=rect
local udim2   = {lerp=lmath.lerp};udim2.__index=udim2
local rgb     = {lerp=lmath.lerp};rgb.__index=rgb
local rgba    = {lerp=lmath.lerp};rgba.__index=rgba

--Vector2
function vector2:__call(x,y)
	return setmetatable({
		x=x or 0,
		y=y or 0,
		magnitude=sqrt((x or 0)^2+(y or 0)^2)
	},self)
end
function vector2:dot(b)
	return (self.x*b.x)+(self.y*b.y)
end
function vector2:__tostring()
	return ("%f, %f"):format(self.x,self.y)
end
function vector2:__unm()
	return vector2(-self.x,-self.y)
end
function vector2:__add(b)
	return vector2(self.x+b.x,self.y+b.y)
end
function vector2:__sub(b)
	return vector2(self.x-b.x,self.y-b.y)
end
function vector2:__mul(b)
	if type(b)=="number" then
		return vector2(self.x*b,self.y*b)
	elseif getmetatable(b)==vector2 then
		return vector2(self.x*b.x,self.y*b.y)
	end
end
function vector2:__div(b)
	if type(b)=="number" then
		return vector2(self.x/b,self.y/b)
	elseif getmetatable(b)==vector2 then
		return vector2(self.x/b.x,self.y/b.y)
	end
end
function vector2:__eq(b)
	return self.x==b.x and self.y==b.y
end

--Vector3
function vector3:__call(x,y,z)
	return setmetatable({
		x=x or 0,
		y=y or 0,
		z=z or 0,
		magnitude=sqrt((x or 0)^2+(y or 0)^2+(z or 0)^2)
	},self)
end
function vector3:dot(b)
	return (self.x*b.x)+(self.y*b.y)+(self.z*b.z)
end
function vector3:cross(b)
	return vector3(self.y*b.z-self.z*b.y,self.z*b.x-self.x*b.z,self.x*b.y-self.y*b.x)
end
function vector3:__tostring()
	return ("%f, %f, %f"):format(self.x,self.y,self.z)
end
function vector3:__unm()
	return vector3(-self.x,-self.y,-self.z)
end
function vector3:__add(b)
	return vector3(self.x+b.x,self.y+b.y,self.z+b.z)
end
function vector3:__sub(b)
	return vector3(self.x-b.x,self.y-b.y,self.z-b.z)
end
function vector3:__mul(b)
	if type(b)=="number" then
		return vector3(self.x*b,self.y*b,self.z*b)
	elseif getmetatable(b)==vector3 then
		return vector3(self.x*b.x,self.y*b.y,self.z*b.z)
	end
end
function vector3:__div(b)
	if type(b)=="number" then
		return vector3(self.x/b,self.y/b,self.z/b)
	elseif getmetatable(b)==vector3 then
		return vector3(self.x/b.x,self.y/b.y,self.z/b.z)
	end
end
function vector3:__eq(b)
	return self.x==b.x and self.y==b.y and self.z==b.z
end

--UDim2
function udim2:__call(x_scale,x_offset,y_scale,y_offset)
	return setmetatable({
		x={offset=x_offset or 0,scale=x_scale or 0},
		y={offset=y_offset or 0,scale=y_scale or 0}
	},self)
end
function udim2:__tostring()
	return ("%f, %d, %f, %d"):format(self.x.scale,self.x.offset,self.y.scale,self.y.offset)
end
function udim2:__unm()
	return udim2(-self.x.scale,-self.x.offset,-self.y.scale,-self.y.offset)
end
function udim2:__add(b)
	return udim2(self.x.scale+b.x.scale,self.x.offset+b.x.offset,self.y.scale+b.y.scale,self.y.offset+b.y.offset)
end
function udim2:__sub(b)
	return udim2(self.x.scale-b.x.scale,self.x.offset-b.x.offset,self.y.scale-b.y.scale,self.y.offset-b.y.offset)
end
function udim2:__mul(b)
	if type(b)=="number" then
		return udim2(self.x.scale*b,self.x.offset*b,self.y.scale*b,self.y.offset*b)
	elseif getmetatable(b)==udim2 then
		return udim2(self.x.scale*b.x.scale,self.x.offset*b.x.offset,self.y.scale*b.y.scale,self.y.offset*b.y.offset)
	end
end
function udim2:__div(b)
	if type(b)=="number" then
		return udim2(self.x.scale/b,self.x.offset/b,self.y.scale/b,self.y.offset/b)
	elseif getmetatable(b)==udim2 then
		return udim2(self.x.scale/b.x.scale,self.x.offset/b.x.offset,self.y.scale/b.y.scale,self.y.offset/b.y.offset)
	end
end
function udim2:__eq(b)
	return self.x.scale==b.x.scale and self.x.offset==b.x.offset and self.y.scale==b.y.scale and self.y.offset==b.y.offset
end

--Rect
function rect:__call(min_x,min_y,max_x,max_y)
	return setmetatable({
		min_x=min_x or 0,
		min_y=min_y or 0,
		max_x=max_x or 0,
		max_y=max_y or 0
	},self)
end
function rect:__tostring()
	return ("%d, %d, %d, %d"):format(self.min_x,self.min_y,self.max_x,self.max_y)
end
function rect:__unm()
	return rect(-self.min_x,-self.min_y,-self.max_x,-self.max_y)
end
function rect:__add(b)
	return rect(self.min_x+b.min_x,self.min_y+b.min_y,self.max_x+b.max_x,self.max_y+b.max_y)
end
function rect:__sub(b)
	return rect(self.min_x-b.min_x,self.min_y-b.min_y,self.max_x-b.max_x,self.max_y-b.max_y)
end
function rect:__mul(b)
	if type(b)=="number" then
		return rect(self.min_x*b,self.min_y*b,self.max_x*b,self.max_y*b)
	elseif getmetatable(b)==rect then
		return rect(self.min_x*b.min_x,self.min_y*b.min_y,self.max_x*b.max_x,self.max_y*b.max_y)
	end
end
function rect:__div(b)
	if type(b)=="number" then
		return rect(self.min_x/b,self.min_y/b,self.max_x/b,self.max_y/b)
	elseif getmetatable(b)==rect then
		return rect(self.min_x/b.min_x,self.min_y/b.min_y,self.max_x/b.max_x,self.max_y/b.max_y)
	end
end
function rect:__eq(b)
	return self.min_x==b.min_x and self.min_y==b.min_y and self.max_x==b.max_x and self.max_y==b.max_y
end

--rgb
function rgb:__call(r,g,b)
	return setmetatable({
		r=r or 0,
		g=g or 0,
		b=b or 0
	},self)
end
function rgb:unpack()
	return {self.r,self.g,self.b}
end
function rgb:__tostring()
	return ("%d, %d, %d"):format(floor(self.r*255),floor(self.g*255),floor(self.b*255))
end
function rgb:__unm()
	return rgb(-self.r,-self.g,-self.b)
end
function rgb:__add(b)
	return rgb(self.r+b.r,self.g+b.g,self.b+b.b)
end
function rgb:__sub(b)
	return rgb(self.r-b.r,self.g-b.g,self.b-b.b)
end
function rgb:__mul(b)
	if type(b)=="number" then
		return rgb(self.r*b,self.g*b,self.b*b)
	elseif getmetatable(b)==rgb then
		return rgb(self.r*b.r,self.g*b.g,self.b*b.b)
	end
end
function rgb:__div(b)
	if type(b)=="number" then
		return rgb(self.r/b,self.g/b,self.b/b)
	elseif getmetatable(b)==rgb then
		return rgb(self.r/b.r,self.g/b.g,self.b/b.b)
	end
end
function rgb:__eq(b)
	return self.r==b.r and self.g==b.g and self.b==b.b
end

lmath.vector2 = setmetatable(vector2,vector2)
lmath.vector3 = setmetatable(vector3,vector3)
lmath.rect    = setmetatable(rect,rect)
lmath.udim2   = setmetatable(udim2,udim2)
lmath.rgb     = setmetatable(rgb,rgb)

return lmath
