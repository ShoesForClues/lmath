--[[
MIT License

Copyright (c) 2020 Shoelee

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

local min   = math.min
local max   = math.max
local abs   = math.abs
local fmod  = math.fmod
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

local lmath={
	_version={0,1,6}
}

lmath.clamp=function(v,min,max)
	if v<min or v~=v then
		return min
	elseif v>max then
		return max
	end
	return v
end

lmath.sign=function(n)
	return (n>0 and 1) or (n<0 and -1) or 0
end
lmath.csign=function(m,s)
	return abs(m)*lmath.sign(s)
end

lmath.lerp=function(a,b,t)
	return a*(1-t)+b*t
end
lmath.alerp=function(a,b,t)
	return a+((((b-a)%tpi+rad(540))%tpi-pi)*t)%tpi
end
lmath.bezier_lerp=function(points,t)
	local pointsTB=points
	while #pointsTB~=1 do
		local ntb={}
		for k,v in ipairs(pointsTB) do
			if k~=1 then
				ntb[k-1]=pointsTB[k-1]:lerp(v,t)
			end
		end
		pointsTB=ntb
	end
	return pointsTB[1]
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
local quat    = {}
local mat4    = {}
local cframe  = {}
local rect    = {}
local udim    = {}
local udim2   = {}
local color3  = {}

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
	return a/a:magnitude()
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
vector2.lerp=function(a,b,t)
	return vector2.new(
		a.x*(1-t)+b.x*t,
		a.y*(1-t)+b.y*t
	)
end
vector2.unpack=function(a)
	return a.x,a.y
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
	return a/a:magnitude()
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
vector3.lerp=function(a,b,t)
	return vector3.new(
		a.x*(1-t)+b.x*t,
		a.y*(1-t)+b.y*t,
		a.z*(1-t)+b.z*t
	)
end
vector3.unpack=function(a)
	return a.x,a.y,a.z
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
quat.__add=function(a,b)
	if type(a)=="number" then
		return quat.new(a+b.x,a+b.y,a+b.z,a+b.w)
	elseif type(b)=="number" then
		return quat.new(a.x+b,a.y+b,a.z+b,a.w+b)
	else
		return quat.new(a.x+b.x,a.y+b.y,a.z+b.z,a.w+b.w)
	end
end
quat.__sub=function(a,b)
	if type(a)=="number" then
		return quat.new(a-b.x,a-b.y,a-b.z,a-b.w)
	elseif type(b)=="number" then
		return quat.new(a.x-b,a.y-b,a.z-b,a.w-b)
	else
		return quat.new(a.x-b.x,a.y-b.y,a.z-b.z,a.w-b.w)
	end
end
quat.__mul=function(a,b)
	if type(a)=="number" then
		return quat.new(a*b.x,a*b.y,a*b.z,a*b.w)
	elseif type(b)=="number" then
		return quat.new(a.x*b,a.y*b,a.z*b,a.w*b)
	else
		return quat.new(a.x*b.x,a.y*b.y,a.z*b.z,a.w*b.w)
	end
end
quat._div=function(a,b)
	if type(a)=="number" then
		return quat.new(a/b.x,a/b.y,a/b.z,a/b.w)
	elseif type(b)=="number" then
		return quat.new(a.x/b,a.y/b,a.z/b,a.w/b)
	else
		return quat.new(a.x/b.x,a.y/b.y,a.z/b.z,a.w/b.w)
	end
end
quat.__unm=function(a)
	return quat.new(-a.x,-a.y,-a.z,-a.w)
end
quat.to_euler=function(a)
	local pitch,roll,yaw
	
	local sinr_cosp=2*(a.w*a.x+a.y*a.z)
	local cosr_cosp=1-2*(a.x*a.x+a.y*a.y)
	local sinp=2*(a.w*a.y-a.z*a.x)
	
	roll=atan2(sinr_cosp,cosr_cosp)
	
	if abs(sinp)>=1 then
		pitch=lmath.csign(pi/2,sinp)
	else
		pitch=asin(sinp)
	end
	
	local siny_cosp=2*(a.w*a.z+a.x*a.y)
	local cosy_cosp=1-2*(a.y*a.y+a.z*a.z)
	
	yaw=atan2(siny_cosp,cosy_cosp)
	
	return pitch,roll,yaw
end
quat.magnitude=function(a)
	return sqrt(a.x^2+a.y^2+a.z^2+a.w^2)
end
quat.normalize=function(a)
	local m=a:magnitude()
	return quat.new(a.x/m,a.y/m,a.z/m,a.w/m)
end
quat.dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)+(a.z*b.z)+(a.w*b.w)
end
quat.slerp=function(a,b,t)
	local v0=a:normalize()
	local v1=b:normalize()
	
	local dot=v0:dot(v1)
	
	if dot<0 then
		v1=-v1
		dot=-dot
	end
	
	if dot>0.9995 then
		return (v0+t*(v1-v0)):normalize()
	end
	
	local theta_0=acos(dot)
	local theta=theta_0*t
	local sin_theta=sin(theta)
	local sin_theta_0=sin(theta_0)
	
	local s0=cos(theta)-dot*sin_theta/sin_theta_0
	local s1=sin_theta/sin_theta_0
	
	return (s0*v0)+(s1*v1)
end
quat.unpack=function(a)
	return a.x,a.y,a.z,a.w
end

------------------------------[Mat4]------------------------------
mat4.__index=mat4
mat4.identity=setmetatable({
	1,0,0,0,
	0,1,0,0,
	0,0,1,0,
	0,0,0,1
},mat4)
mat4.new=function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16)
	return setmetatable({
		a1 or 0,a2 or 0,a3 or 0,a4 or 0,
		a5 or 0,a6 or 0,a7 or 0,a8 or 0,
		a9 or 0,a10 or 0,a11 or 0,a12 or 0,
		a13 or 0,a14 or 0,a15 or 0,a16 or 0
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
mat4.__tostring=function(a)
	return ("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f"):format(a:unpack())
end
mat4.__unm=function(a)
	return mat4.new(
		-a[1],-a[2],-a[3],-a[4],
		-a[5],-a[6],-a[7],-a[8],
		-a[9],-a[10],-a[11],-a[12],
		-a[13],-a[14],-a[15],-a[16]
	)
end
mat4.__add=function(a,b)
	return mat4.new(
		a[1]+b[1],a[2]+b[2],a[3]+b[3],a[4]+b[4],
		a[5]+b[5],a[6]+b[6],a[7]+b[7],a[8]+b[8],
		a[9]+b[9],a[10]+b[10],a[11]+b[11],a[12]+b[12],
		a[13]+b[13],a[14]+b[14],a[15]+b[15],a[16]+b[16]
	)
end
mat4.__sub=function(a,b)
	return mat4.new(
		a[1]-b[1],a[2]-b[2],a[3]-b[3],a[4]-b[4],
		a[5]-b[5],a[6]-b[6],a[7]-b[7],a[8]-b[8],
		a[9]-b[9],a[10]-b[10],a[11]-b[11],a[12]-b[12],
		a[13]-b[13],a[14]-b[14],a[15]-b[15],a[16]-b[16]
	)
end
mat4.__mul=function(a,b)
	if getmetatable(b)==vector3 then
		return mat4.new(
			a[1]*b.x,a[2],a[3],a[4],
			a[5],a[6]*b.y,a[7],a[8],
			a[9],a[10],a[11]*b.z,a[12],
			a[13],a[14],a[15],a[16]
		)
	else
		return mat4.new(
			a[1]*b[1]+a[2]*b[5]+a[3]*b[9]+a[4]*b[13],
			a[1]*b[2]+a[2]*b[6]+a[3]*b[10]+a[4]*b[14],
			a[1]*b[3]+a[2]*b[7]+a[3]*b[11]+a[4]*b[15],
			a[1]*b[4]+a[2]*b[8]+a[3]*b[12]+a[4]*b[16],
			a[5]*b[1]+a[6]*b[5]+a[7]*b[9]+a[8]*b[13],
			a[5]*b[2]+a[6]*b[6]+a[7]*b[10]+a[8]*b[14],
			a[5]*b[3]+a[6]*b[7]+a[7]*b[11]+a[8]*b[15],
			a[5]*b[4]+a[6]*b[8]+a[7]*b[12]+a[8]*b[16],
			a[9]*b[1]+a[10]*b[5]+a[11]*b[9]+a[12]*b[13],
			a[9]*b[2]+a[10]*b[6]+a[11]*b[10]+a[12]*b[14],
			a[9]*b[3]+a[10]*b[7]+a[11]*b[11]+a[12]*b[15],
			a[9]*b[4]+a[10]*b[8]+a[11]*b[12]+a[12]*b[16],
			a[13]*b[1]+a[14]*b[5]+a[15]*b[9]+a[16]*b[13],
			a[13]*b[2]+a[14]*b[6]+a[15]*b[10]+a[16]*b[14],
			a[13]*b[3]+a[14]*b[7]+a[15]*b[11]+a[16]*b[15],
			a[13]*b[4]+a[14]*b[8]+a[15]*b[12]+a[16]*b[16]
		)
	end
end
mat4.__div=function(a,b)
	if type(a)=="number" then
		return mat4.new(
			a/b[1],a/b[2],a/b[3],a/b[4],
			a/b[5],a/b[6],a/b[7],a/b[8],
			a/b[9],a/b[10],a/b[11],a/b[12],
			a/b[13],a/b[14],a/b[15],a/b[16]
		)
	elseif type(b)=="number" then
		return mat4.new(
			a[1]/b,a[2]/b,a[3]/b,a[4]/b,
			a[5]/b,a[6]/b,a[7]/b,a[8]/b,
			a[9]/b,a[10]/b,a[11]/b,a[12]/b,
			a[13]/b,a[14]/b,a[15]/b,a[16]/b
		)
	else
		return mat4.new(
			
		)
	end
end
mat4.__eq=function(a,b)
	return
		a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[4]==b[4] and
		a[5]==b[5] and a[6]==b[6] and a[7]==b[7] and a[8]==b[8] and
		a[9]==b[9] and a[10]==b[10] and a[11]==b[11] and a[12]==b[12] and
		a[13]==b[13] and a[14]==b[14] and a[15]==b[15] and a[16]==b[16]
end
mat4.translate=function(a,x,y,z)
	return a*mat4.new(
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		x,y,z,1
	)
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
		a[1],a[5],a[9],a[13],
		a[2],a[6],a[10],a[14],
		a[3],a[7],a[11],a[15],
		a[4],a[8],a[12],a[16]
	)
end
mat4.unpack=function(a)
	return
		a[1],a[2],a[3],a[4],
		a[5],a[6],a[7],a[8],
		a[9],a[10],a[11],a[12],
		a[13],a[14],a[15],a[16]
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
cframe.from_euler=function(x,y,z,px,py,pz)
	local cx,sx=cos(x),sin(x)
	local cy,sy=cos(y),sin(y)
	local cz,sz=cos(z),sin(z)
	return cframe.new(
		px,py,pz,
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
cframe.from_axis=function(x,y,z,t,px,py,pz)
	local axis=vector3.new(x,y,z):normalize()
	local ca,sa=cos(t),sin(t)
	local r=unit_x*ca+unit_x:dot(axis)*axis*(1-ca)+axis:cross(unit_x)*sa
	local t=unit_y*ca+unit_y:dot(axis)*axis*(1-ca)+axis:cross(unit_y)*sa
	local b=unit_z*ca+unit_z:dot(axis)*axis*(1-ca)+axis:cross(unit_z)*sa
	return cframe.new(
		px,py,pz,
		r.x,t.x,b.x,
		r.y,t.y,b.y,
		r.z,t.z,b.z
	);
end
cframe.from_quat=function(x,y,z,w,px,py,pz)
	return cframe.new(
		px,py,pz,
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
		local a11,a12,a13,a14=a.r11,a.r12,a.r13,a.x
		local a21,a22,a23,a24=a.r21,a.r22,a.r23,a.y
		local a31,a32,a33,a34=a.r31,a.r32,a.r33,a.z
		local a41,a42,a43,a44=0,0,0,1
		
		local b11,b12,b13,b14=b.r11,b.r12,b.r13,b.x
		local b21,b22,b23,b24=b.r21,b.r22,b.r23,b.y
		local b31,b32,b33,b34=b.r31,b.r32,b.r33,b.z
		local b41,b42,b43,b44=0,0,0,1
		
		local c11=a11*b11+a12*b21+a13*b31+a14*b41
		local c12=a11*b12+a12*b22+a13*b32+a14*b42
		local c13=a11*b13+a12*b23+a13*b33+a14*b43
		local c14=a11*b14+a12*b24+a13*b34+a14*b44
		local c21=a21*b11+a22*b21+a23*b31+a24*b41
		local c22=a21*b12+a22*b22+a23*b32+a24*b42
		local c23=a21*b13+a22*b23+a23*b33+a24*b43
		local c24=a21*b14+a22*b24+a23*b34+a24*b44
		local c31=a31*b11+a32*b21+a33*b31+a34*b41
		local c32=a31*b12+a32*b22+a33*b32+a34*b42
		local c33=a31*b13+a32*b23+a33*b33+a34*b43
		local c34=a31*b14+a32*b24+a33*b34+a34*b44
		local c41=a41*b11+a42*b21+a43*b31+a44*b41
		local c42=a41*b12+a42*b22+a43*b32+a44*b42
		local c43=a41*b13+a42*b23+a43*b33+a44*b43
		local c44=a41*b14+a42*b24+a43*b34+a44*b44
		
		return cframe.new(
			c14,c24,c34,
			c11,c12,c13,
			c21,c22,c23,
			c31,c32,c33
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
	local m=sqrt((a.r32-a.r23)^2+(a.r13-a.r31)^2+(a.r21-a.r12)^2)
	return
		(a.r32-a.r23)/m,
		(a.r13-a.r31)/m,
		(a.r21-a.r12)/m,
		acos((a.r11+a.r22+a.r33-1)/2)
end
cframe.to_quat=function(a)
	local tr=a.r11+a.r22+a.r33
	if tr>0 then
		local s=sqrt(tr+1)*2
		return
			(a.r32-a.r23)/s,
			(a.r13-a.r31)/s,
			(a.r21-a.r12)/s,
			0.25*s
	elseif a.r11>a.r22 and a.r11>a.r33 then
		local s=sqrt(1+a.r11-a.r22-a.r33)*2
		return
			0.25*s,
			(a.r12+a.r21)/s,
			(a.r13+a.r31)/s,
			(a.r32-a.r23)/s
	elseif a.r22>a.r33 then
		local s=sqrt(1+a.r22-a.r11-a.r33)*2
		return
			(a.r12+a.r21)/s,
			0.25*s,
			(a.r23+a.r32)/s,
			(a.r13-a.r31)/s
	else
		local s=sqrt(1+a.r33-a.r11-a.r22)*2
		return
			(a.r21-a.r12)/s,
			(a.r13+a.r31)/s,
			(a.r23+a.r32)/s,
			0.25*s
	end
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
cframe.lerp=function(a,b,t)	
	local px=a.x*(1-t)+b.x*t
	local py=a.y*(1-t)+b.y*t
	local pz=a.z*(1-t)+b.z*t
	
	local x1,y1,z1,w1=a:to_quat()
	local x2,y2,z2,w2=b:to_quat()
	
	local dot=(x1*x2)+(y1*y2)+(z1*z2)+(w1*w2)
	
	if dot<0 then
		x2,y2,z2,w2=-x2,-y2,-z2,-w2
		dot=-dot
	end
	
	if dot>0.9995 then
		local x3=(x1*t*(x2-x1))
		local y3=(y1*t*(y2-y1))
		local z3=(y1*t*(y2-y1))
		local w3=(y1*t*(y2-y1))
		local m3=sqrt(x3^2+y3^2+z3^2+w3^2)
		
		return cframe.from_quat(
			x3/m3,y3/m3,z3/m3,w3/m3,
			px,py,pz
		)
	end
	
	local theta_0=acos(dot)
	local theta=theta_0*t
	local sin_theta=sin(theta)
	local sin_theta_0=sin(theta_0)
	
	local s0=cos(theta)-dot*sin_theta/sin_theta_0
	local s1=sin_theta/sin_theta_0
	
	return cframe.from_quat(
		(s0*x1)+(s1*x2),
		(s0*y1)+(s1*y2),
		(s0*z1)+(s1*z2),
		(s0*w1)+(s1*w2),
		px,py,pz
	)
end
cframe.unpack=function(a)
	return
		a.x,a.y,a.z,
		a.r11,a.r12,a.r13,
		a.r21,a.r22,a.r23,
		a.r31,a.r32,a.r33
end

------------------------------[UDim2]------------------------------
udim2.__index=udim2
udim2.new=function(x_scale,x_offset,y_scale,y_offset)
	return setmetatable({
		x_scale=x_scale,x_offset=x_offset,
		y_scale=y_scale,y_offset=y_offset
	},udim2)
end
udim2.__tostring=function(a)
	return ("%f, %d, %f, %d"):format(a:unpack())
end
udim2.__unm=function(a)
	return udim2.new(-a.x_scale,-a.x_offset,-a.y_scale,-a.y_offset)
end
udim2.__add=function(a,b)
	return udim2.new(
		a.x_scale+b.x_scale,a.x_offset+b.x_offset,
		a.y_scale+b.y_scale,a.y_offset+b.y_offset
	)
end
udim2.__sub=function(a,b)
	return udim2.new(
		a.x_scale-b.x_scale,a.x_offset-b.x_offset,
		a.y_scale-b.y_scale,a.y_offset-b.y_offset
	)
end
udim2.__mul=function(a,b)
	if type(a)=="number" then
		return udim2.new(a*b.x_scale,a*b.x_offset,a*b.y_scale,a*b.y_offset)
	elseif type(b)=="number" then
		return udim2.new(a.x_scale*b,a.x_offset*b,a.y_scale*b,a.y_offset*b)
	else
		return udim2.new(
			a.x_scale*b.x_scale,a.x_offset*b.x_offset,
			a.y_scale*b.y_scale,a.y_offset*b.y_offset
		)
	end
end
udim2.__div=function(a,b,o)
	if type(a)=="number" then
		return udim2.new(a/b.x_scale,a/b.x_offset,a/b.y_scale,a/b.y_offset)
	elseif type(b)=="number" then
		return udim2.new(a.x_scale/b,a.x_offset/b,a.y_scale/b,a.y_offset/b)
	else
		return udim2.new(
			a.x_scale/b.x_scale,a.x_offset/b.x_offset,
			a.y_scale/b.y_scale,a.y_offset/b.y_offset
		)
	end
end
udim2.__eq=function(a,b)
	return (
		a.x_scale==b.x_scale and a.x_offset==b.x_offset and 
		a.y_scale==b.y_scale and a.y_offset==b.y_offset
	)
end
udim2.lerp=function(a,b,t)
	return udim2.new(
		a.x_scale*(1-t)+b.x_scale*t,
		a.x_offset*(1-t)+b.x_offset*t,
		a.y_scale*(1-t)+b.y_scale*t,
		a.y_offset*(1-t)+b.y_offset*t
	)
end
udim2.unpack=function(a)
	return a.x_scale,a.x_offset,a.y_scale,a.y_offset
end

------------------------------[Rect]------------------------------
rect.__index=rect
rect.new=function(min_x,min_y,max_x,max_y)
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
	return rect.new(
		a.min_x+b.min_x,a.min_y+b.min_y,
		a.max_x+b.max_x,a.max_y+b.max_y
	)
end
rect.__sub=function(a,b)
	return rect.new(
		a.min_x-b.min_x,a.min_y-b.min_y,
		a.max_x-b.max_x,a.max_y-b.max_y
	)
end
rect.__mul=function(a,b)
	if type(a)=="number" then
		return rect.new(a*b.min_x,a*b.min_y,a*b.max_x,a*b.max_y)
	elseif type(b)=="number" then
		return rect.new(a.min_x*b,a.min_y*b,a.max_x*b,a.max_y*b)
	else
		return rect.new(
			a.min_x*b.min_x,a.min_y*b.min_y,
			a.max_x*b.max_x,a.max_y*b.max_y
		)
	end
end
rect.__div=function(a,b)
	if type(a)=="number" then
		return rect.new(a/b.min_x,a/b.min_y,a/b.max_x,a/b.max_y)
	elseif type(b)=="number" then
		return rect.new(a.min_x/b,a.min_y/b,a.max_x/b,a.max_y/b)
	else
		return rect.new(
			a.min_x/b.min_x,a.min_y/b.min_y,
			a.max_x/b.max_x,a.max_y/b.max_y
		)
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
rect.lerp=function(a,b,t)
	return rect.new(
		a.min_x*(1-t)+b.min_x*t,
		a.min_y*(1-t)+b.min_y*t,
		a.max_x*(1-t)+b.max_x*t,
		a.max_y*(1-t)+b.max_y*t
	)
end
rect.unpack=function(a)
	return a.min_x,a.min_y,a.max_x,a.max_y
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
color3.from_hex=function(hex)
	hex=hex:gsub("#","")
	return color3.new(
		tonumber("0x"..hex:sub(1,2))/255,
		tonumber("0x"..hex:sub(3,4))/255,
		tonumber("0x"..hex:sub(5,6))/255
	)
end
color3.from_hsv=function(h,s,v)
	local c=v*s
	local x=c*(1-abs(fmod(h/(60/360),2)-1))
	local m=v-c
	
	if h>=0 and h<(60/360) then
		return color3.new(c+m,x+m,m)
	elseif h>=(60/360) and h<(120/360) then
		return color3.new(x+m,c+m,m)
	elseif h>=(120/360) and h<(180/360) then
		return color3.new(m,c+m,x+m)
	elseif h>=(180/360) and h<(240/360) then
		return color3.new(m,x+m,c+m)
	elseif h>=(250/360) and h<(300/360) then
		return color3.new(x+m,m,c+m)
	elseif h>=(300/360) and h<(360/360) then
		return color3.new(c+m,m,x+m)
	else
		return color3.new(m,m,m)
	end
end
color3.__tostring=function(a)
	return ("%f, %f, %f"):format(a.r,a.g,a.b)
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
color3.to_hsv=function(a)
	local r,g,b=a.r,a.g,a.b
	local h,s,v=0,0,0
	local min_c,max_c=min(r,g,b),max(r,g,b)
	local c=max_c-min_c
	
	v=max_c
	
	if c~=0 then
		if max_c==r then
			h=fmod(((g-b)/c),6)
		elseif max_c==g then
			h=(b-r)/c+2
		else
			h=(r-g)/c+4
		end
		h,s=h/6,c/v
	end
	
	return h,s,v
end
color3.lerp=function(a,b,t)
	return color3.new(
		a.r*(1-t)+b.r*t,
		a.g*(1-t)+b.g*t,
		a.b*(1-t)+b.b*t
	)
end
color3.unpack=function(a)
	return a.r,a.g,a.b
end

--Data Types
lmath.vector2 = setmetatable(vector2,vector2)
lmath.vector3 = setmetatable(vector3,vector3)
lmath.quat    = setmetatable(quat,quat)
lmath.mat4    = setmetatable(mat4,mat4)
lmath.cframe  = setmetatable(cframe,cframe)
lmath.rect    = setmetatable(rect,rect)
lmath.udim2   = setmetatable(udim2,udim2)
lmath.color3  = setmetatable(color3,color3)

--Constants
unit_x = lmath.vector3.new(1,0,0)
unit_y = lmath.vector3.new(0,1,0)
unit_z = lmath.vector3.new(0,0,1)

--Temps
temp_mat4      = lmath.mat4.new()
temp_vector2_1 = lmath.vector2.new()
temp_vector2_2 = lmath.vector2.new()
temp_vector3_1 = lmath.vector3.new()
temp_vector3_2 = lmath.vector3.new()

return lmath