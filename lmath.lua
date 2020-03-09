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
	_version={0,1,0};
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
local temp_vector3

------------------------------[Vector2]------------------------------
vector2.__index=vector2
vector2.new=function(x,y,o)
	o=o or setmetatable({x=0,y=0},vector2)
	o.x,o.y=x or 0,y or 0
	return o
end
vector2.__tostring=function(a)
	return ("%f, %f"):format(a:unpack())
end
vector2.__unm=function(a,o)
	return vector2.new(-a.x,-a.y,o)
end
vector2.__add=function(a,b,o)
	return vector2.new(a.x+b.x,a.y+b.y,o)
end
vector2.__sub=function(a,b,o)
	return vector2.new(a.x-b.x,a.y-b.y,o)
end
vector2.__mul=function(a,b,o)
	if type(a)=="number" then
		return vector2.new(a*b.x,a*b.y,o)
	elseif type(b)=="number" then
		return vector2.new(a.x*b,a.y*b,o)
	else
		return vector2.new(a.x*b.x,a.y*b.y,o)
	end
end
vector2.__div=function(a,b,o)
	if type(a)=="number" then
		return vector2.new(a/b.x,a/b.y,o)
	elseif type(b)=="number" then
		return vector2.new(a.x/b,a.y/b,o)
	else
		return vector2.new(a.x/b.x,a.y/b.y,o)
	end
end
vector2.__eq=function(a,b)
	return a.x==b.x and a.y==b.y
end
vector2.magnitude=function(a)
	return sqrt(a.x^2+a.y^2)
end
vector2.normalize=function(a,o)
	return vector2.__div(a,a:magnitude(),o)
end
vector2.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)
end
vector2.cross=function(a,b)
	return (a.x*b.y)-(a.y*b.x);
end
vector2.rotate=function(a,b,angle,o)
	return vector2.new(lmath.rotate(a.x,a.y,b.x,b.y,angle),o)
end
vector2.unpack=function(a)
	return a.x,a.y
end
vector2.lerp=function(a,b,t,o)
	return vector2.__add(
		vector2.__mul(a,(1-t)),
		vector2.__mul(b,t),o
	)
end

------------------------------[Vector3]------------------------------
vector3.__index=vector3
vector3.new=function(x,y,z,o)
	o=o or setmetatable({x=0,y=0,z=0},vector3)
	o.x,o.y,o.z=x or 0,y or 0,z or 0
	return o
end
vector3.__tostring=function(a)
	return ("%f, %f, %f"):format(a:unpack())
end
vector3.__unm=function(a,o)
	return vector3.new(-a.x,-a.y,-a.z,o)
end
vector3.__add=function(a,b,o)
	return vector3.new(a.x+b.x,a.y+b.y,a.z+b.z,o)
end
vector3.__sub=function(a,b,o)
	return vector3.new(a.x-b.x,a.y-b.y,a.z-b.z,o)
end
vector3.__mul=function(a,b,o)
	if type(a)=="number" then
		return vector3.new(a*b.x,a*b.y,a*b.z,o)
	elseif type(b)=="number" then
		return vector3.new(a.x*b,a.y*b,a.z*b,o)
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
		return vector3.new(x,y,z,o)
	else
		return vector3.new(a.x*b.x,a.y*b.y,a.z*b.z,o)
	end
end
vector3.__div=function(a,b,o)
	if type(a)=="number" then
		return vector3.new(a/b.x,a/b.y,a/b.z,o)
	elseif type(b)=="number" then
		return vector3.new(a.x/b,a.y/b,a.z/b,o)
	else
		return vector3.new(a.x/b.x,a.y/b.y,a.z/b.z,o)
	end
end
vector3.__eq=function(a,b)
	return a.x==b.x and a.y==b.y and a.z==b.z
end
vector3.magnitude=function(a)
	return sqrt(a.x^2+a.y^2+a.z^2)
end
vector3.normalize=function(a,o)
	return vector3.__div(a,a:magnitude(),o)
end
vector3.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)+(a.z*b.z)
end
vector3.cross=function(a,b,o)
	return vector3.new(
		a.y*b.z-a.z*b.y,
		a.z*b.x-a.x*b.z,
		a.x*b.y-a.y*b.x,
		o
	)
end
vector3.unpack=function(a)
	return a.x,a.y,a.z
end
vector3.lerp=function(a,b,t,o)
	return vector3.__add(
		vector3.__mul(a,(1-t)),
		vector3.__mul(b,t),o
	)
end

------------------------------[Mat4]------------------------------
mat4.__index=mat4
mat4.new=function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,o)
	o=o or setmetatable({
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0}
	},mat4)
	o[1][1],o[1][2],o[1][3],o[1][4]=a1 or 0,a2 or 0,a3 or 0,a4 or 0
	o[2][1],o[2][2],o[2][3],o[2][4]=a5 or 0,a6 or 0,a7 or 0,a8 or 0
	o[3][1],o[3][2],o[3][3],o[3][4]=a9 or 0,a10 or 0,a11 or 0,a12 or 0
	o[4][1],o[4][2],o[4][3],o[4][4]=a13 or 0,a14 or 0,a15 or 0,a16 or 0
	return o
end
mat4.from_perspective=function(fov,aspect,near,far,o)
	local scale=tan(rad(fov)/2)
	return mat4.new(
		1/(scale*aspect),0,0,0,
		0,1/scale,0,0,
		0,0,-(far+near)/(far-near),-1,
		0,0,-(2*far*near)/(far-near),0,
		o
	)
end
mat4.from_orthographic=function()
	
end
mat4.from_identity=function(o)
	return mat4.new(
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,1,
		o
	)
end
mat4.__tostring=function(a)
	return ("%f, %f, %f, %f\t%f, %f, %f, %f\t%f, %f, %f, %f\t%f, %f, %f, %f"):format(a:unpack())
end
mat4.__unm=function(a)
	return mat4.new(
		-a[1][1],-a[1][2],-a[1][3],-a[1][4],
		-a[2][1],-a[2][2],-a[2][3],-a[2][4],
		-a[3][1],-a[3][2],-a[3][3],-a[3][4],
		-a[4][1],-a[4][2],-a[4][3],-a[4][4],
		o
	)
end
mat4.__add=function(a,b)
	return mat4.new(
		a[1][1]+b[1][1],a[1][2]+b[1][2],a[1][3]+b[1][3],a[1][4]+b[1][4],
		a[2][1]+b[2][1],a[2][2]+b[2][2],a[2][3]+b[2][3],a[2][4]+b[2][4],
		a[3][1]+b[3][1],a[3][2]+b[3][2],a[3][3]+b[3][3],a[3][4]+b[3][4],
		a[4][1]+b[4][1],a[4][2]+b[4][2],a[4][3]+b[4][3],a[4][4]+b[4][4],
		o
	)
end
mat4.__sub=function(a,b,o)
	return mat4.new(
		a[1][1]-b[1][1],a[1][2]-b[1][2],a[1][3]-b[1][3],a[1][4]-b[1][4],
		a[2][1]-b[2][1],a[2][2]-b[2][2],a[2][3]-b[2][3],a[2][4]-b[2][4],
		a[3][1]-b[3][1],a[3][2]-b[3][2],a[3][3]-b[3][3],a[3][4]-b[3][4],
		a[4][1]-b[4][1],a[4][2]-b[4][2],a[4][3]-b[4][3],a[4][4]-b[4][4],
		o
	)
end
mat4.__mul=function(a,b,o)
	if type(a)=="number" then
		return mat4.new(
			a*b[1][1],a*b[1][2],a*b[1][3],a*b[1][4],
			a*b[2][1],a*b[2][2],a*b[2][3],a*b[2][4],
			a*b[3][1],a*b[3][2],a*b[3][3],a*b[3][4],
			a*b[4][1],a*b[4][2],a*b[4][3],a*b[4][4],
			o
		)
	elseif type(b)=="number" then
		return mat4.new(
			b*a[1][1],b*a[1][2],b*a[1][3],b*a[1][4],
			b*a[2][1],b*a[2][2],b*a[2][3],b*a[2][4],
			b*a[3][1],b*a[3][2],b*a[3][3],b*a[3][4],
			b*a[4][1],b*a[4][2],b*a[4][3],b*a[4][4],
			o
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
			a[4][1]*b[1][4]+a[4][2]*b[2][4]+a[4][3]*b[3][4]+a[4][4]*b[4][4],
			o
		)
	end
end
mat4.__div=function(a,b,o)
	if type(a)=="number" then
		return mat4.new(
			a/b[1][1],a/b[1][2],a/b[1][3],a/b[1][4],
			a/b[2][1],a/b[2][2],a/b[2][3],a/b[2][4],
			a/b[3][1],a/b[3][2],a/b[3][3],a/b[3][4],
			a/b[4][1],a/b[4][2],a/b[4][3],a/b[4][4],
			o
		)
	elseif type(b)=="number" then
		return mat4.new(
			b/a[1][1],b/a[1][2],b/a[1][3],b/a[1][4],
			b/a[2][1],b/a[2][2],b/a[2][3],b/a[2][4],
			b/a[3][1],b/a[3][2],b/a[3][3],b/a[3][4],
			b/a[4][1],b/a[4][2],b/a[4][3],b/a[4][4],
			o
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
mat4.rotate=function(a,angle,axis,o)
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
	return mat4.__mul(temp_mat4,a,o)
end
mat4.translate=function(a,t,o)
	temp_mat4[1][1],temp_mat4[1][2],temp_mat4[1][3],temp_mat4[1][4]=1,0,0,0
	temp_mat4[2][1],temp_mat4[2][2],temp_mat4[2][3],temp_mat4[2][4]=0,1,0,0
	temp_mat4[3][1],temp_mat4[3][2],temp_mat4[3][3],temp_mat4[3][4]=0,0,1,0
	temp_mat4[4][1],temp_mat4[4][2],temp_mat4[4][3],temp_mat4[4][4]=t.x,t.y,t.z,1
	return mat4.__mul(temp_mat4,a,o)
end
mat4.transpose=function(a,o)
	return mat4.new(
		a[1][1],a[2][1],a[3][1],a[4][1],
		a[1][2],a[2][2],a[3][2],a[4][2],
		a[1][3],a[2][3],a[3][3],a[4][3],
		a[1][4],a[2][4],a[3][4],a[4][4],
		o
	)
end
mat4.unpack=function(a)
	return a[1][1],a[1][2],a[1][3],a[1][4],
		a[2][1],a[2][2],a[2][3],a[2][4],
		a[3][1],a[3][2],a[3][3],a[3][4],
		a[4][1],a[4][2],a[4][3],a[4][4]
end

------------------------------[Quat]------------------------------
quat.__index=quat
quat.new=function(x,y,z,w,o)
	o=o or setmetatable({x=0,y=0,z=0,w=0},quat)
	o.x,o.y,o.z,o.w=x or 0,y or 0,z or 0,w or 0
	return o
end
quat.from_euler=function(x,y,z,o)
	local sx,cx=sin(x/2),cos(x/2)
	local sy,cy=sin(y/2),cos(y/2)
	local sz,cz=sin(z/2),cos(z/2)
	return quat.new(
		sz*cy*cx-cz*sy*sx,
		cz*sy*cx+sz*cy*sx,
		cz*cy*sx-sz*sy*cx,
		cz*cy*cx+sz*sy*sx,
		o
	)
end
quat.from_axis=function(x,y,z,a,o)
	local s=sin(a/2)
	return quat.new(x*s,y*s,z*s,cos(a/2),o)
end
quat.__tostring=function(a)
	return ("%f, %f, %f, %f"):format(a:unpack())
end
quat.unpack=function(a)
	return a.x,a.y,a.z,a.w
end

------------------------------[CFrame]------------------------------
cframe.__index=cframe
cframe.new=function(x,y,z,r11,r12,r13,r21,r22,r23,r31,r32,r33,o)
	o=o or setmetatable({
		x=0,y=0,z=0,
		r11=0,r12=0,r13=0,
		r21=0,r22=0,r23=0,
		r31=0,r32=0,r33=0
	},cframe)
	o.x,o.y,o.z=x or 0,y or 0,z or 0
	o.r11,o.r12,o.r13=r11 or 0,r12 or 0,r13 or 0
	o.r21,o.r22,o.r23=r21 or 0,r22 or 0,r23 or 0
	o.r31,o.r32,o.r33=r31 or 0,r32 or 0,r33 or 0
	return o
end
cframe.from_lookat=function(position,front,up,o)
	local x_axis=up:cross(front)
	x_axis=vector3.normalize(x_axis,x_axis)
	local y_axis=front:cross(x_axis)
	y_axis=vector3.normalize(y_axis,y_axis)
	return cframe.new(
		position.x,position.y,position.z,
		x_axis.x,y_axis.x,front.x,
		x_axis.y,y_axis.y,front.y,
		x_axis.z,y_axis.z,front.z,
		o
	)
end
cframe.from_euler=function(rx,ry,rz,o)
	local ch,sh=cos(rx),sin(rx)
	local ca,sa=cos(ry),sin(ry)
	local cb,sb=cos(rz),sin(rz)
	return cframe.new(
		0,0,0,
		ch*ca,sh*sb-ch*sa*cb,ch*sa*sb+sh*cb,
		sa,ca*cb,-ca*sb,
		-sh*ca,sh*sa*cb+ch*sb,-sh*sa*sb+ch*cb,
		o
	)
end
cframe.from_position=function(x,y,z,o)
	local ch,sh=cos(0),sin(0)
	local ca,sa=cos(0),sin(0)
	local cb,sb=cos(0),sin(0)
	return cframe.new(
		x,y,z,
		ch*ca,sh*sb-ch*sa*cb,ch*sa*sb+sh*cb,
		sa,ca*cb,-ca*sb,
		-sh*ca,sh*sa*cb+ch*sb,-sh*sa*sb+ch*cb,
		o
	)
end
cframe.from_position_euler=function(x,y,z,rx,ry,rz,o)
	local ch,sh=cos(rx),sin(rx)
	local ca,sa=cos(ry),sin(ry)
	local cb,sb=cos(rz),sin(rz)
	return cframe.new(
		x,y,z,
		ch*ca,sh*sb-ch*sa*cb,ch*sa*sb+sh*cb,
		sa,ca*cb,-ca*sb,
		-sh*ca,sh*sa*cb+ch*sb,-sh*sa*sb+ch*cb,
		o
	)
end
cframe.from_quat=function(i,j,k,w)
	return cframe.new(
		0,0,0,
		1-2*j^2-2*k^2,
		2*(i*j-k*w),
		2*(i*k+j*w),
		2*(i*j+k*w),
		1-2*i^2-2*k^2,
		2*(j*k-i*w),
		2*(i*k-j*w),
		2*(j*k+i*w),
		1-2*i^2-2*j^2,
		o
	)
end
cframe.__tostring=function(a)
	return ("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f"):format(a:unpack())
end
cframe.__unm=function(a,o)
	return cframe.new(
		-a.x,-a.y,-a.z,
		-a.r11,-a.r12,-a.r13,
		-a.r21,-a.r22,-a.r23,
		-a.r31,-a.r32,-a.r33,
		o
	)
end
cframe.__add=function(a,b,o) --b must be vector3
	return cframe.new(
		a.x-b.x,a.y-b.y,a.z-b.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33,
		o
	)
end
cframe.__sub=function(a,b,o) --b must be vector3
	return cframe.new(
		a.x-b.x,a.y-b.y,a.z-b.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33,
		o
	)
end
cframe.__mul=function(a,b,o)
	if getmetatable(b)==vector3 then
		local _,_,_,m11,m12,m13,m21,m22,m23,m31,m32,m33=a:unpack()
		local right=vector3.new(m11,m21,m31)
		local top=vector3.new(m12,m22,m32)
		local back=vector3.new(m13,m23,m33)
		return vector3.new((cf.p+b.x*right+b.y*top+b.z*back):unpack(),o)
	else
		local a14,a24,a34,a11,a12,a13,a21,a22,a23,a31,a32,a33=a:unpack()
		local b14,b24,b34,b11,b12,b13,b21,b22,b23,b31,b32,b33=b:unpack()
		local c=mat4.__mul(mat4.new(
			a11,a12,a13,a14,
			a21,a22,a23,a24,
			a31,a32,a33,a34,
			0,0,0,1
		),mat4.new(
			b11,b12,b13,b14,
			b21,b22,b23,b24,
			b31,b32,b33,b34,
			0,0,0,1
		))
		return cframe.new(
			c[1][4],c[2][4],c[3][4],
			c[1][1],c[1][2],c[1][3],
			c[2][1],c[2][2],c[2][3],
			c[3][1],c[3][2],c[3][3],
			o
		)
	end
end
cframe.to_euler=function(a,o)
	return
		atan2(a.r32,a.r33),
		atan2(-a.r31,sqrt(a.r32^2,a.r33^2)),
		atan2(a.r21,a.r11)
end
cframe.to_axis=function(a,o)
	
end
cframe.to_position=function(a,o)
	return vector3.new(a.x,a.y,a.z,o)
end
cframe.to_mat4=function(a,o)
	return mat4.new(
		a.r11,a.r12,a.r13,0,
		a.r21,a.r22,a.r23,0,
		a.r31,a.r32,a.r33,0,
		a.x,a.y,a.z,1,
		o
	)
end
cframe.unpack=function(a)
	return
		a.x,a.y,a.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33
end
cframe.lerp=function(a,b,t,o)
	
end

------------------------------[UDim2]------------------------------
udim2.__index=udim2
udim2.new=function(x_scale,x_offset,y_scale,y_offset,o)
	o=o or setmetatable({
		x={scale=0,offset=0},
		y={scale=0,offset=0}
	},udim2)
	o.x.scale=x_scale or 0
	o.x.offset=x_offset or 0
	o.y.scale=y_scale or 0
	o.y.offset=y_offset or 0
	return o
end
udim2.__tostring=function(a)
	return ("%f, %d, %f, %d"):format(a:unpack())
end
udim2.__unm=function(a,o)
	return udim2.new(-a.x.scale,-a.x.offset,-a.y.scale,-a.y.offset,o)
end
udim2.__add=function(a,b,o)
	return udim2.new(
		a.x.scale+b.x.scale,a.x.offset+b.x.offset,
		a.y.scale+b.y.scale,a.y.offset+b.y.offset,
		o
	)
end
udim2.__sub=function(a,b,o)
	return udim2.new(
		a.x.scale-b.x.scale,a.x.offset-b.x.offset,
		a.y.scale-b.y.scale,a.y.offset-b.y.offset,
		o
	)
end
udim2.__mul=function(a,b,o)
	if type(a)=="number" then
		return udim2.new(a*b.x.scale,a*b.x.offset,a*b.y.scale,a*b.y.offset,o)
	elseif type(b)=="number" then
		return udim2.new(a.x.scale*b,a.x.offset*b,a.y.scale*b,a.y.offset*b,o)
	else
		return udim2.new(
			a.x.scale*b.x.scale,a.x.offset*b.x.offset,
			a.y.scale*b.y.scale,a.y.offset*b.y.offset,
			o
		)
	end
end
udim2.__div=function(a,b,o)
	if type(a)=="number" then
		return udim2.new(a/b.x.scale,a/b.x.offset,a/b.y.scale,a/b.y.offset,o)
	elseif type(b)=="number" then
		return udim2.new(a.x.scale/b,a.x.offset/b,a.y.scale/b,a.y.offset/b,o)
	else
		return udim2.new(
			a.x.scale/b.x.scale,a.x.offset/b.x.offset,
			a.y.scale/b.y.scale,a.y.offset/b.y.offset,
			o
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
udim2.lerp=function(a,b,t,o)
	return udim2.__add(
		udim2.__mul(a,(1-t)),
		udim2.__mul(b,t),o
	)
end

------------------------------[Rect]------------------------------
rect.__index=rect
rect.new=function(min_x,min_y,max_x,max_y,o)
	o=o or setmetatable({
		min_x=0,min_y=0,
		max_x=0,max_y=0
	},rect)
	o.min_x=min_x or 0
	o.min_y=min_y or 0
	o.max_x=max_x or 0
	o.max_y=max_y or 0
	return o
end
rect.__tostring=function(a)
	return ("%d, %d, %d, %d"):format(a:unpack())
end
rect.__unm=function(a,o)
	return rect.new(-a.min_x,-a.min_y,-a.max_x,-a.max_y,o)
end
rect.__add=function(a,b,o)
	return rect.new(a.min_x+b.min_x,a.min_y+b.min_y,a.max_x+b.max_x,a.max_y+b.max_y,o)
end
rect.__sub=function(a,b,o)
	return rect.new(a.min_x-b.min_x,a.min_y-b.min_y,a.max_x-b.max_x,a.max_y-b.max_y,o)
end
rect.__mul=function(a,b,o)
	if type(a)=="number" then
		return rect.new(a*b.min_x,a*b.min_y,a*b.max_x,a*b.max_y,o)
	elseif type(b)=="number" then
		return rect.new(a.min_x*b,a.min_y*b,a.max_x*b,a.max_y*b,o)
	else
		return rect.new(a.min_x*b.min_x,a.min_y*b.min_y,a.max_x*b.max_x,a.max_y*b.max_y,o)
	end
end
rect.__div=function(a,b,o)
	if type(a)=="number" then
		return rect.new(a/b.min_x,a/b.min_y,a/b.max_x,a/b.max_y,o)
	elseif type(b)=="number" then
		return rect.new(a.min_x/b,a.min_y/b,a.max_x/b,a.max_y/b,o)
	else
		return rect.new(a.min_x/b.min_x,a.min_y/b.min_y,a.max_x/b.max_x,a.max_y/b.max_y,o)
	end
end
rect.__eq=function(a,b)
	return (
		a.min_x==b.min_x and a.min_y==b.min_y and 
		a.max_x==b.max_x and a.max_y==b.max_y
	)
end
rect.clamp=function(a,b,o)
	return rect.new(
		lmath.clamp(a.min_x,b.min_x,b.max_x),
		lmath.clamp(a.min_y,b.min_y,b.max_y),
		lmath.clamp(a.max_x,b.min_x,b.max_x),
		lmath.clamp(a.max_y,b.min_y,b.max_y),
		o
	)
end
rect.unpack=function(a)
	return a.min_x,a.min_y,a.max_x,a.max_y
end
rect.lerp=function(a,b,t,o)
	return rect.__add(
		rect.__mul(a,(1-t)),
		rect.__mul(b,t),o
	)
end

------------------------------[Color3]------------------------------
color3.__index=color3
color3.new=function(r,g,b,o)
	o=o or setmetatable({r=0,g=0,b=0},color3)
	o.r,o.g,o.b=r or 0,g or 0,b or 0
	return o
end
color3.hex=function(hex,o)
	hex=hex:gsub("#","")
	return color3.new(
		tonumber("0x"..hex:sub(1,2))/255,
		tonumber("0x"..hex:sub(3,4))/255,
		tonumber("0x"..hex:sub(5,6))/255,
		o
	)
end
color3.__tostring=function(a)
	return ("%d, %d, %d"):format(a.r*255,a.g*255,a.b*255)
end
color3.__unm=function(a,o)
	return color3.new(-a.r,-a.g,-a.b,o)
end
color3.__add=function(a,b,o)
	return color3.new(a.r+b.r,a.g+b.g,a.b+b.b,o)
end
color3.__sub=function(a,b,o)
	return color3.new(a.r-b.r,a.g-b.g,a.b-b.b,o)
end
color3.__mul=function(a,b,o)
	if type(a)=="number" then
		return color3.new(a*b.r,a*b.g,a*b.b,o)
	elseif type(b)=="number" then
		return color3.new(a.r*b,a.g*b,a.b*b,o)
	else
		return color3.new(a.r*b.r,a.g*b.g,a.b*b.b,o)
	end
end
color3.__div=function(a,b,o)
	if type(a)=="number" then
		return color3.new(a/b.r,a/b.g,a/b.b,o)
	elseif type(b)=="number" then
		return color3.new(a.r/b,a.g/b,a.b/b,o)
	else
		return color3.new(a.r/b.r,a.g/b.g,a.b/b.b,o)
	end
end
color3.__eq=function(a,b)
	return a.r==b.r and a.g==b.g and a.b==b.b
end
color3.unpack=function(a)
	return a.r,a.g,a.b
end
color3.lerp=function(a,b,t,o)
	return color3.__add(
		color3.__mul(a,(1-t)),
		color3.__mul(b,t),o
	)
end

------------------------------------------------------------

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
temp_mat4    = lmath.mat4.new()
temp_vector3 = lmath.vector3.new()

return lmath