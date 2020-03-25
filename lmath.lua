--[[
MIT License

Copyright (c) 2020 ShoesForClues

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
	_version={0,1,2};
}

--Primitives
local sqrt  = math.sqrt
local floor = math.floor
local sin   = math.sin
local cos   = math.cos
local tan   = math.tan
local rad   = math.rad
local atan  = math.atan
local atan2 = math.atan2
local asin  = math.asin
local acos  = math.acos
local pi    = math.pi
local tpi   = pi*2

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
lmath.alerp=function(start,goal,percent)
	local shortest_angle=((((goal-start)%tpi)+rad(540))%tpi)-pi
	return start+(shortest_angle*percent)%tpi
end

lmath.round=function(num,decimal_place)
	local mult=10^(decimal_place or 0)
	return floor(num*mult+0.5)/mult
end
lmath.round_multiple=function(num,multiple)
	return floor(num/multiple+0.5)*multiple
end

lmath.rotate_point=function(x1,y1,x2,y2,angle) --Point, Origin, Radians
	local s=sin(angle)
	local c=cos(angle)
	x1=x1-x2
	y1=y1-y2
	return (x1*c-y1*s)+x2,(x1*s+y1*c)+y2
end

--Data Types
local vector2 = {}
local vector3 = {}
local mat4    = {}
local quat    = {}
local cframe  = {}
local rect    = {}
local udim    = {}
local udim2   = {}
local color3  = {}
local color4  = {}

--Constants
local unit_x,unit_y,unit_z

--Temp
local temp_mat4
local temp_vector2_1
local temp_vector2_2
local temp_vector3_1
local temp_vector3_2

------------------------------[Vector2]------------------------------
vector2.__index=vector2
vector2.new=function(x,y)
	return setmetatable({
		x=x or 0,
		y=y or 0
	},vector2)
end
vector2.__tostring=function(a)
	return ("%f, %f"):format(a:unpack())
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
vector2.magnitude=function(a)
	return sqrt(a.x^2+a.y^2)
end
vector2.normalize=function(a)
	return vector2.__div(a,a:magnitude())
end
vector2.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)
end
vector2.cross=function(a,b)
	return (a.x*b.y)-(a.y*b.x);
end
vector2.rotate=function(a,b,angle)
	return vector2.new(lmath.rotate(a.x,a.y,b.x,b.y,angle))
end
vector2.unpack=function(a)
	return a.x,a.y
end
vector2.lerp=function(a,b,t)
	return vector2.__add(
		vector2.__mul(a,(1-t),temp_vector2_1),
		vector2.__mul(b,t,temp_vector2_2)
	)
end

------------------------------[Vector3]------------------------------
vector3.__index=vector3
vector3.new=function(x,y,z)
	return setmetatable({
		x=x or 0,
		y=y or 0,
		z=z or 0
	},vector3)
end
vector3.__tostring=function(a)
	return ("%f, %f, %f"):format(a:unpack())
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
	elseif getmetatable(b)==mat4 then
		local x=a.x*b[1][1]+a.y*b[2][1]+a.z*b[3][1]+b[4][1]
		local y=a.x*b[1][2]+a.y*b[2][2]+a.z*b[3][2]+b[4][2]
		local z=a.x*b[1][3]+a.y*b[2][3]+a.z*b[3][3]+b[4][3]
		local w=a.x*b[1][4]+a.y*b[2][4]+a.z*b[3][4]+b[4][4]
		if w~=0 then
			x=x/w
			y=y/w
			z=z/w
		end
		return vector3.new(x,y,z)
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
vector3.magnitude=function(a)
	return sqrt(a.x^2+a.y^2+a.z^2)
end
vector3.normalize=function(a)
	return vector3.__div(a,a:magnitude())
end
vector3.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)+(a.z*b.z)
end
vector3.cross=function(a,b)
	return vector3.new(
		a.y*b.z-a.z*b.y,
		a.z*b.x-a.x*b.z,
		a.x*b.y-a.y*b.x
	)
end
vector3.unpack=function(a)
	return a.x,a.y,a.z
end
vector3.lerp=function(a,b,t)
	return vector3.__add(
		vector3.__mul(a,(1-t),temp_vector3_1),
		vector3.__mul(b,t,temp_vector3_2)
	)
end

------------------------------[Mat4]------------------------------
mat4.__index=mat4
mat4.new=function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16)
	return setmetatable({
		{a1 or 0,a2 or 0,a3 or 0,a4 or 0},
		{a5 or 0,a6 or 0,a7 or 0,a8 or 0},
		{a9 or 0,a10 or 0,a11 or 0,a12 or 0},
		{a13 or 0,a14 or 0,a15 or 0,a16 or 0}
	},mat4)
end
mat4.from_perspective=function(fov,aspect,near,far)
	local scale=tan(rad(fov)/2)
	return mat4.new(
		1/(scale*aspect),0,0,0,
		0,1/scale,0,0,
		0,0,-(far+near)/(far-near),-1,
		0,0,-(2*far*near)/(far-near),0
	)
end
mat4.from_orthographic=function(left,right,top,bottom,near,far)
	return mat4.new(
		2/(right-left),0,0,0,
		0,2/(top-bottom),0,0,
		0,0,-2/(far-near),0,
		-((right+left)/(right-left)),
		-((top+bottom)/(top-bottom)),
		-((far+near)/(far-near)),1
	)
end
mat4.from_identity=function()
	return mat4.new(
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,1
	)
end
mat4.__tostring=function(a)
	return ("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f"):format(a:unpack())
end
mat4.__unm=function(a)
	return mat4.new(
		-a[1][1],-a[1][2],-a[1][3],-a[1][4],
		-a[2][1],-a[2][2],-a[2][3],-a[2][4],
		-a[3][1],-a[3][2],-a[3][3],-a[3][4],
		-a[4][1],-a[4][2],-a[4][3],-a[4][4]
	)
end
mat4.__add=function(a,b)
	return mat4.new(
		a[1][1]+b[1][1],a[1][2]+b[1][2],a[1][3]+b[1][3],a[1][4]+b[1][4],
		a[2][1]+b[2][1],a[2][2]+b[2][2],a[2][3]+b[2][3],a[2][4]+b[2][4],
		a[3][1]+b[3][1],a[3][2]+b[3][2],a[3][3]+b[3][3],a[3][4]+b[3][4],
		a[4][1]+b[4][1],a[4][2]+b[4][2],a[4][3]+b[4][3],a[4][4]+b[4][4]
	)
end
mat4.__sub=function(a,b)
	return mat4.new(
		a[1][1]-b[1][1],a[1][2]-b[1][2],a[1][3]-b[1][3],a[1][4]-b[1][4],
		a[2][1]-b[2][1],a[2][2]-b[2][2],a[2][3]-b[2][3],a[2][4]-b[2][4],
		a[3][1]-b[3][1],a[3][2]-b[3][2],a[3][3]-b[3][3],a[3][4]-b[3][4],
		a[4][1]-b[4][1],a[4][2]-b[4][2],a[4][3]-b[4][3],a[4][4]-b[4][4]
	)
end
mat4.__mul=function(a,b)
	if type(a)=="number" then
		return mat4.new(
			a*b[1][1],a*b[1][2],a*b[1][3],a*b[1][4],
			a*b[2][1],a*b[2][2],a*b[2][3],a*b[2][4],
			a*b[3][1],a*b[3][2],a*b[3][3],a*b[3][4],
			a*b[4][1],a*b[4][2],a*b[4][3],a*b[4][4]
		)
	elseif type(b)=="number" then
		return mat4.new(
			b*a[1][1],b*a[1][2],b*a[1][3],b*a[1][4],
			b*a[2][1],b*a[2][2],b*a[2][3],b*a[2][4],
			b*a[3][1],b*a[3][2],b*a[3][3],b*a[3][4],
			b*a[4][1],b*a[4][2],b*a[4][3],b*a[4][4]
		)
	elseif getmetatable(b)==vector3 then
		return mat4.new(
			a[1][1]*b.x,a[1][2],a[1][3],a[1][4],
			a[2][1],a[2][2]*b.y,a[2][3],a[2][4],
			a[3][1],a[3][2],a[3][3]*b.z,a[3][4],
			a[4][1],a[4][2],a[4][3],a[4][4]
		)
	else
		return mat4.new(
			a[1][1]*b[1][1]+a[1][2]*b[2][1]+a[1][3]*b[3][1]+a[1][4]*b[4][1],
			a[1][1]*b[1][2]+a[1][2]*b[2][2]+a[1][3]*b[3][2]+a[1][4]*b[4][2],
			a[1][1]*b[1][3]+a[1][2]*b[2][3]+a[1][3]*b[3][3]+a[1][4]*b[4][3],
			a[1][1]*b[1][4]+a[1][2]*b[2][4]+a[1][3]*b[3][4]+a[1][4]*b[4][4],
			a[2][1]*b[1][1]+a[2][2]*b[2][1]+a[2][3]*b[3][1]+a[2][4]*b[4][1],
			a[2][1]*b[1][2]+a[2][2]*b[2][2]+a[2][3]*b[3][2]+a[2][4]*b[4][2],
			a[2][1]*b[1][3]+a[2][2]*b[2][3]+a[2][3]*b[3][3]+a[2][4]*b[4][3],
			a[2][1]*b[1][4]+a[2][2]*b[2][4]+a[2][3]*b[3][4]+a[2][4]*b[4][4],
			a[3][1]*b[1][1]+a[3][2]*b[2][1]+a[3][3]*b[3][1]+a[3][4]*b[4][1],
			a[3][1]*b[1][2]+a[3][2]*b[2][2]+a[3][3]*b[3][2]+a[3][4]*b[4][2],
			a[3][1]*b[1][3]+a[3][2]*b[2][3]+a[3][3]*b[3][3]+a[3][4]*b[4][3],
			a[3][1]*b[1][4]+a[3][2]*b[2][4]+a[3][3]*b[3][4]+a[3][4]*b[4][4],
			a[4][1]*b[1][1]+a[4][2]*b[2][1]+a[4][3]*b[3][1]+a[4][4]*b[4][1],
			a[4][1]*b[1][2]+a[4][2]*b[2][2]+a[4][3]*b[3][2]+a[4][4]*b[4][2],
			a[4][1]*b[1][3]+a[4][2]*b[2][3]+a[4][3]*b[3][3]+a[4][4]*b[4][3],
			a[4][1]*b[1][4]+a[4][2]*b[2][4]+a[4][3]*b[3][4]+a[4][4]*b[4][4]
		)
	end
end
mat4.__div=function(a,b)
	if type(a)=="number" then
		return mat4.new(
			a/b[1][1],a/b[1][2],a/b[1][3],a/b[1][4],
			a/b[2][1],a/b[2][2],a/b[2][3],a/b[2][4],
			a/b[3][1],a/b[3][2],a/b[3][3],a/b[3][4],
			a/b[4][1],a/b[4][2],a/b[4][3],a/b[4][4]
		)
	elseif type(b)=="number" then
		return mat4.new(
			b/a[1][1],b/a[1][2],b/a[1][3],b/a[1][4],
			b/a[2][1],b/a[2][2],b/a[2][3],b/a[2][4],
			b/a[3][1],b/a[3][2],b/a[3][3],b/a[3][4],
			b/a[4][1],b/a[4][2],b/a[4][3],b/a[4][4]
		)
	else
		return mat4.new(
			
		)
	end
end
mat4.__eq=function(a,b)
	return (
		a[1][1]==b[1][1] and a[1][2]==b[1][2] and a[1][3]==b[1][3] and a[1][4]==b[1][4] and
		a[2][1]==b[2][1] and a[2][2]==b[2][2] and a[2][3]==b[2][3] and a[2][4]==b[2][4] and
		a[3][1]==b[3][1] and a[3][2]==b[3][2] and a[3][3]==b[3][3] and a[3][4]==b[3][4] and
		a[4][1]==b[4][1] and a[4][2]==b[4][2] and a[4][3]==b[4][3] and a[4][4]==b[4][4]
	)
end
mat4.rotate=function(a,angle,axis)
	local l=axis:magnitude()
	if l==0 then
		return a
	end
	local x,y,z=axis.x/l,axis.y/l,axis.z/l
	local c=cos(angle)
	local s=sin(angle)
	temp_mat4[1][1]=x^2*(1-c)+c
	temp_mat4[1][2]=y*x*(1-c)+z*s
	temp_mat4[1][3]=x*z*(1-c)-y*s
	temp_mat4[1][4]=0
	temp_mat4[2][1]=x*y*(1-c)-z*s
	temp_mat4[2][2]=y^2*(1-c)+c
	temp_mat4[2][3]=y*z*(1-c)+x*s
	temp_mat4[2][4]=0
	temp_mat4[3][1]=x*z*(1-c)+y*s
	temp_mat4[3][2]=y*z*(1-c)-x*s
	temp_mat4[3][3]=z*z*(1-c)+c
	temp_mat4[3][4]=0
	temp_mat4[4][1]=0
	temp_mat4[4][2]=0
	temp_mat4[4][3]=0
	temp_mat4[4][4]=1
	return a*temp_mat4
end
mat4.translate=function(a,x,y,z)
	temp_mat4[1][1],temp_mat4[1][2],temp_mat4[1][3],temp_mat4[1][4]=1,0,0,0
	temp_mat4[2][1],temp_mat4[2][2],temp_mat4[2][3],temp_mat4[2][4]=0,1,0,0
	temp_mat4[3][1],temp_mat4[3][2],temp_mat4[3][3],temp_mat4[3][4]=0,0,1,0
	temp_mat4[4][1],temp_mat4[4][2],temp_mat4[4][3],temp_mat4[4][4]=x,y,z,1
	return a*temp_mat4
end
mat4.scale=function(a,x,y,z)
	return a*mat4.new(
		x,0,0,0,
		0,y,0,0,
		0,0,z,0,
		0,0,0,1
	)
end
mat4.transpose=function(a)
	return mat4.new(
		a[1][1],a[2][1],a[3][1],a[4][1],
		a[1][2],a[2][2],a[3][2],a[4][2],
		a[1][3],a[2][3],a[3][3],a[4][3],
		a[1][4],a[2][4],a[3][4],a[4][4]
	)
end
mat4.unpack=function(a)
	return
		a[1][1],a[1][2],a[1][3],a[1][4],
		a[2][1],a[2][2],a[2][3],a[2][4],
		a[3][1],a[3][2],a[3][3],a[3][4],
		a[4][1],a[4][2],a[4][3],a[4][4]
end

------------------------------[Quat]------------------------------
quat.__index=quat
quat.new=function(x,y,z,w)
	return setmetatable({
		x=x or 0,
		y=y or 0,
		z=z or 0,
		w=w or 0
	},quat)
end
quat.from_euler=function(x,y,z)
	local sx,cx=sin(x/2),cos(x/2)
	local sy,cy=sin(y/2),cos(y/2)
	local sz,cz=sin(z/2),cos(z/2)
	return quat.new(
		sz*cy*cx-cz*sy*sx,
		cz*sy*cx+sz*cy*sx,
		cz*cy*sx-sz*sy*cx,
		cz*cy*cx+sz*sy*sx
	)
end
quat.from_axis=function(x,y,z,a)
	local s=sin(a/2)
	return quat.new(x*s,y*s,z*s,cos(a/2))
end
quat.__tostring=function(a)
	return ("%f, %f, %f, %f"):format(a:unpack())
end
quat.unpack=function(a)
	return a.x,a.y,a.z,a.w
end

------------------------------[CFrame]------------------------------
cframe.__index=cframe
cframe.new=function(x,y,z,r11,r12,r13,r21,r22,r23,r31,r32,r33)
	return setmetatable({
		x=x or 0,y=y or 0,z=z or 0,
		r11=r11 or 1,r12=r12 or 0,r13=r13 or 0,
		r21=r21 or 0,r22=r22 or 1,r23=r23 or 0,
		r31=r31 or 0,r32=r32 or 0,r33=r33 or 1
	},cframe)
end
cframe.from_matrix=function(position,front,up)
	local x_axis=up:cross(front):normalize()
	local y_axis=front:cross(x_axis):normalize()
	return cframe.new(
		position.x,position.y,position.z,
		x_axis.x,y_axis.x,front.x,
		x_axis.y,y_axis.y,front.y,
		x_axis.z,y_axis.z,front.z
	)
end
cframe.from_look=function(eye,look)
	local front=(eye-look):normalize()
    local right=unit_y:cross(front):normalize()
    local up=front:cross(right):normalize()
    return cframe.new(
		eye.x,eye.y,eye.z,
		right.x,right.y,right.z,
		up.x,up.y,up.z,
		front.x,front.y,front.z
	)
end
cframe.from_euler=function(x,y,z)
	local cx,sx=cos(x),sin(x)
	local cy,sy=cos(y),sin(y)
	local cz,sz=cos(z),sin(z)
	return cframe.new(
		0,0,0,
		cy*cz,
		-cy*sz,
		sy,
		cz*sx*sy+cx*sz,
		cx*cz-sx*sy*sz,
		-cy*sx,
		sx*sz-cx*cz*sy,
		cz*sx+cx*sy*sz,
		cx*cy
	)
end
cframe.from_axis=function(x,y,z,t)
	local axis=vector3.new(x,y,z):normalize()
	local ca,sa=cos(t),sin(t)
	local r=unit_x*ca+unit_x:dot(axis)*axis*(1-ca)+axis:cross(unit_x)*sa
	local t=unit_y*ca+unit_y:dot(axis)*axis*(1-ca)+axis:cross(unit_y)*sa
	local b=unit_z*ca+unit_z:dot(axis)*axis*(1-ca)+axis:cross(unit_z)*sa
	return cframe.new(
		0,0,0,
		r.x,t.x,b.x,
		r.y,t.y,b.y,
		r.z,t.z,b.z
	);
end
cframe.from_quat=function(x,y,z,w)
	return cframe.new(
		0,0,0,
		1-2*y^2-2*z^2,
		2*(x*y-z*w),
		2*(x*z+y*w),
		2*(x*y+z*w),
		1-2*x^2-2*z^2,
		2*(y*z-x*w),
		2*(x*z-y*w),
		2*(y*z+x*w),
		1-2*x^2-2*y^2
	)
end
cframe.__tostring=function(a)
	return ("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f"):format(a:unpack())
end
cframe.__unm=function(a)
	return cframe.new(
		-a.x,-a.y,-a.z,
		-a.r11,-a.r12,-a.r13,
		-a.r21,-a.r22,-a.r23,
		-a.r31,-a.r32,-a.r33
	)
end
cframe.__add=function(a,b) --b must be vector3
	return cframe.new(
		a.x+b.x,a.y+b.y,a.z+b.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33
	)
end
cframe.__sub=function(a,b) --b must be vector3
	return cframe.new(
		a.x-b.x,a.y-b.y,a.z-b.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33
	)
end
cframe.__mul=function(a,b)
	if getmetatable(b)==vector3 then
		return vector3.new(
			a.x+b.x*a.r11+b.y*a.r12+b.z*a.r13,
			a.y+b.x*a.r21+b.y*a.r22+b.z*a.r23,
			a.z+b.x*a.r31+b.y*a.r32+b.z*a.r33
		)
	else
		local mat=mat4.new(
			a.r11,a.r12,a.r13,a.x,
			a.r21,a.r22,a.r23,a.y,
			a.r31,a.r32,a.r33,a.z,
			0,0,0,1
		)*mat4.new(
			b.r11,b.r12,b.r13,b.x,
			b.r21,b.r22,b.r23,b.y,
			b.r31,b.r32,b.r33,b.z,
			0,0,0,1
		)
		return cframe.new(
			mat[1][4],mat[2][4],mat[3][4],
			mat[1][1],mat[1][2],mat[1][3],
			mat[2][1],mat[2][2],mat[2][3],
			mat[3][1],mat[3][2],mat[3][3]
		)
	end
end
cframe.inverse=function(a)
	local a14,a24,a34,a11,a12,a13,a21,a22,a23,a31,a32,a33=a:unpack()
	local det=(
		a11*a22*a33*1+a11*a23*a34*0+a11*a24*a32*0+
		a12*a21*a34*0+a12*a23*a31*1+a12*a24*a33*0+
		a13*a21*a32*1+a13*a22*a34*0+a13*a24*a31*0+
		a14*a21*a33*0+a14*a22*a31*0+a14*a23*a32*0-
		a11*a22*a34*0-a11*a23*a32*1-a11*a24*a33*0-
		a12*a21*a33*1-a12*a23*a34*0-a12*a24*a31*0-
		a13*a21*a34*0-a13*a22*a31*1-a13*a24*a32*0-
		a14*a21*a32*0-a14*a22*a33*0-a14*a23*a31*0
	)
	if det==0 then
		return a
	end
	return cframe.new(
		(a12*a24*a33+a13*a22*a34+a14*a23*a32-a12*a23*a34-a13*a24*a32-a14*a22*a33)/det,
		(a11*a23*a34+a13*a24*a31+a14*a21*a33-a11*a24*a33-a13*a21*a34-a14*a23*a31)/det,
		(a11*a24*a32+a12*a21*a34+a14*a22*a31-a11*a22*a34-a12*a24*a31-a14*a21*a32)/det,
		(a22*a33*1+a23*a34*0+a24*a32*0-a22*a34*0-a23*a32*1-a24*a33*0)/det,
		(a12*a34*0+a13*a32*1+a14*a33*0-a12*a33*1-a13*a34*0-a14*a32*0)/det,
		(a12*a23*1+a13*a24*0+a14*a22*0-a12*a24*0-a13*a22*1-a14*a23*0)/det,
		(a21*a34*0+a23*a31*1+a24*a33*0-a21*a33*1-a23*a34*0-a24*a31*0)/det,
		(a11*a33*1+a13*a34*0+a14*a31*0-a11*a34*0-a13*a31*1-a14*a33*0)/det,
		(a11*a24*0+a13*a21*1+a14*a23*0-a11*a23*1-a13*a24*0-a14*a21*0)/det,
		(a21*a32*1+a22*a34*0+a24*a31*0-a21*a34*0-a22*a31*1-a24*a32*0)/det,
		(a11*a34*0+a12*a31*1+a14*a32*0-a11*a32*1-a12*a34*0-a14*a31*0)/det,
		(a11*a22*1+a12*a24*0+a14*a21*0-a11*a24*0-a12*a21*1-a14*a22*0)/det
	)
end
cframe.to_euler=function(a)
	return
		atan2(-a.r23,a.r33),
		asin(a.r13),
		atan2(-a.r12,a.r11)
end
cframe.to_axis=function(a)
	return
		(a.r32-a.r23)/sqrt((a.r32-a.r23)^2+(a.r13-a.r31)^2+(a.r21-a.r12)^2),
		(a.r13-a.r31)/sqrt((a.r32-a.r23)^2+(a.r13-a.r31)^2+(a.r21-a.r12)^2),
		(a.r21-a.r12)/sqrt((a.r32-a.r23)^2+(a.r13-a.r31)^2+(a.r21-a.r12)^2),
		acos((a.r11+a.r22+a.r33-1)/2)
end
cframe.to_front=function(a)
	return vector3.new(a.r13,a.r23,a.r33)
end
cframe.to_up=function(a)
	return vector3.new(a.r12,a.r22,a.r32)
end
cframe.to_right=function(a)
	return vector3.new(a.r11,a.r21,a.r31)
end
cframe.to_position=function(a)
	return vector3.new(a.x,a.y,a.z)
end
cframe.to_mat4=function(a)
	return mat4.new(
		a.r11,a.r12,a.r13,0,
		a.r21,a.r22,a.r23,0,
		a.r31,a.r32,a.r33,0,
		a.x,a.y,a.z,1
	)
end
cframe.to_mat4_view=function(a)
	return mat4.new(
		a.r11,a.r12,a.r13,0,
		a.r21,a.r22,a.r23,0,
		a.r31,a.r32,a.r33,0,
		0,0,0,1
	)
end
cframe.unpack=function(a)
	return
		a.x,a.y,a.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33
end
cframe.lerp=function(a,b,t)
	
end

------------------------------[UDim2]------------------------------
udim2.__index=udim2
udim2.new=function(x_scale,x_offset,y_scale,y_offset,o)
	return setmetatable({
		x={scale=x_scale or 0,offset=x_offset or 0},
		y={scale=y_scale or 0,offset=y_offset or 0}
	},udim2)
end
udim2.__tostring=function(a)
	return ("%f, %d, %f, %d"):format(a:unpack())
end
udim2.__unm=function(a)
	return udim2.new(-a.x.scale,-a.x.offset,-a.y.scale,-a.y.offset)
end
udim2.__add=function(a,b)
	return udim2.new(
		a.x.scale+b.x.scale,a.x.offset+b.x.offset,
		a.y.scale+b.y.scale,a.y.offset+b.y.offset
	)
end
udim2.__sub=function(a,b)
	return udim2.new(
		a.x.scale-b.x.scale,a.x.offset-b.x.offset,
		a.y.scale-b.y.scale,a.y.offset-b.y.offset
	)
end
udim2.__mul=function(a,b)
	if type(a)=="number" then
		return udim2.new(a*b.x.scale,a*b.x.offset,a*b.y.scale,a*b.y.offset)
	elseif type(b)=="number" then
		return udim2.new(a.x.scale*b,a.x.offset*b,a.y.scale*b,a.y.offset*b)
	else
		return udim2.new(
			a.x.scale*b.x.scale,a.x.offset*b.x.offset,
			a.y.scale*b.y.scale,a.y.offset*b.y.offset
		)
	end
end
udim2.__div=function(a,b,o)
	if type(a)=="number" then
		return udim2.new(a/b.x.scale,a/b.x.offset,a/b.y.scale,a/b.y.offset)
	elseif type(b)=="number" then
		return udim2.new(a.x.scale/b,a.x.offset/b,a.y.scale/b,a.y.offset/b)
	else
		return udim2.new(
			a.x.scale/b.x.scale,a.x.offset/b.x.offset,
			a.y.scale/b.y.scale,a.y.offset/b.y.offset
		)
	end
end
udim2.__eq=function(a,b)
	return (
		a.x.scale==b.x.scale and a.x.offset==b.x.offset and 
		a.y.scale==b.y.scale and a.y.offset==b.y.offset
	)
end
udim2.unpack=function(a)
	return a.x.scale,a.x.offset,a.y.scale,a.y.offset
end
udim2.lerp=function(a,b,t)
	return udim2.__add(
		udim2.__mul(a,(1-t)),
		udim2.__mul(b,t)
	)
end

------------------------------[Rect]------------------------------
rect.__index=rect
rect.new=function(min_x,min_y,max_x,max_y,o)
	return setmetatable({
		min_x=min_x or 0,min_y=min_y or 0,
		max_x=max_x or 0,max_y=max_y or 0
	},rect)
end
rect.__tostring=function(a)
	return ("%d, %d, %d, %d"):format(a:unpack())
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
	return (
		a.min_x==b.min_x and a.min_y==b.min_y and 
		a.max_x==b.max_x and a.max_y==b.max_y
	)
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
rect.lerp=function(a,b,t)
	return rect.__add(
		rect.__mul(a,(1-t)),
		rect.__mul(b,t)
	)
end

------------------------------[Color3]------------------------------
color3.__index=color3
color3.new=function(r,g,b)
	return setmetatable({
		r=r or 0,
		g=g or 0,
		b=b or 0
	},color3)
end
color3.hex=function(hex)
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
color3.lerp=function(a,b,t)
	return color3.__add(
		color3.__mul(a,(1-t)),
		color3.__mul(b,t)
	)
end

--Initialize Data Types
lmath.vector2 = setmetatable(vector2,vector2)
lmath.vector3 = setmetatable(vector3,vector3)
lmath.mat4    = setmetatable(mat4,mat4)
lmath.quat    = setmetatable(quat,quat)
lmath.cframe  = setmetatable(cframe,cframe)
lmath.rect    = setmetatable(rect,rect)
lmath.udim2   = setmetatable(udim2,udim2)
lmath.color3  = setmetatable(color3,color3)

--Initialize Constants
unit_x = lmath.vector3.new(1,0,0)
unit_y = lmath.vector3.new(0,1,0)
unit_z = lmath.vector3.new(0,0,1)

--Initialize Temps
temp_mat4      = lmath.mat4.new()
temp_vector2_1 = lmath.vector2.new()
temp_vector2_2 = lmath.vector2.new()
temp_vector3_1 = lmath.vector3.new()
temp_vector3_2 = lmath.vector3.new()

return lmath