--[[
Lua Math Library

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

-------------------------------------------------------------------------------

local lmath={
	version="0.1.9"
}

--Data Types
local vector2 = {}
local vector3 = {}
local mat4    = {}
local rect    = {}
local udim2   = {}
local color3  = {}

--Constants
local unit_x,unit_y,unit_z

--Temp
local temp_mat4

-------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------

vector2.__index=vector2

vector2.new=function(x,y)
	return setmetatable({
		x=x or 0,
		y=y or 0
	},vector2)
end

vector2.unpack=function(a)
	return a.x,a.y
end

vector2.set=function(a,x,y)
	a.x,a.y=x or 0,y or 0
	return a
end

vector2.get_magnitude=function(a)
	return sqrt(a.x^2+a.y^2)
end

vector2.get_dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)
end

vector2.get_cross=function(a,b)
	return (a.x*b.y)-(a.y*b.x)
end

vector2.add=function(a,b)
	return a:set(a.x+b.x,a.y+b.y)
end

vector2.subtract=function(a,b)
	return a:set(a.x-b.x,a.y-b.y)
end

vector2.multiply=function(a,b)
	if type(b)=="number" then
		return a:set(a.x*b,a.y*b)
	else
		return a:set(a.x*b.x,a.y*b.y)
	end
end

vector2.divide=function(a,b)
	if type(b)=="number" then
		return a:set(a.x/b,a.y/b)
	else
		return a:set(a.x/b.x,a.y/b.y)
	end
end

vector2.negate=function(a)
	return a:set(-a.x,-a.y)
end

vector2.normalize=function(a)
	local m=a:magnitude()
	return a:set(a.x/m,a.y/m)
end

vector2.lerp=function(a,b,t)
	return a:set(
		a.x*(1-t)+b.x*t,
		a.y*(1-t)+b.y*t
	)
end

vector2.__tostring=function(a)
	return ("%f %f"):format(a:unpack())
end

vector2.__unm=function(a)
	return vector2.new(a:unpack()):negate()
end

vector2.__add=function(a,b)
	return vector2.new(a:unpack()):add(b)
end

vector2.__sub=function(a,b)
	return vector2.new(a:unpack()):subtract(b)
end

vector2.__mul=function(a,b)
	return vector2.new(a:unpack()):multiply(b)
end

vector2.__div=function(a,b)
	return vector2.new(a:unpack()):divide(b)
end

vector2.__eq=function(a,b)
	return a.x==b.x and a.y==b.y
end

-------------------------------------------------------------------------------

vector3.__index=vector3

vector3.new=function(x,y,z)
	return setmetatable({
		x=x or 0,
		y=y or 0,
		z=z or 0
	},vector3)
end

vector3.unpack=function(a)
	return a.x,a.y,a.z
end

vector3.set=function(a,x,y,z)
	a.x,a.y,a.z=x or 0,y or 0,z or 0
	return a
end

vector3.get_magnitude=function(a)
	return sqrt(a.x^2+a.y^2+a.z^2)
end

vector3.get_dot=function(a,b)
	return (a.x*b.x)+(a.y*b.y)+(a.z*b.z)
end

vector3.get_cross=function(a,b)
	return
		a.y*b.z-a.z*b.y,
		a.z*b.x-a.x*b.z,
		a.x*b.y-a.y*b.x
end

vector3.add=function(a,b)
	if type(b)=="number" then
		return a:set(a.x+b,a.y+b,a.z+b)
	else
		return a:set(a.x+b.x,a.y+b.y,a.z+b.z)
	end
end

vector3.subtract=function(a,b)
	if type(b)=="number" then
		return a:set(a.x-b,a.y-b,a.z-b)
	else
		return a:set(a.x-b.x,a.y-b.y,a.z-b.z)
	end
end

vector3.multiply=function(a,b)
	if type(b)=="number" then
		return a:set(a.x*b,a.y*b,a.z*b)
	else
		return a:set(a.x*b.x,a.y*b.y,a.z*b.z)
	end
end

vector3.divide=function(a,b)
	if type(b)=="number" then
		return a:set(a.x/b,a.y/b,a.z/b)
	else
		return a:set(a.x/b.x,a.y/b.y,a.z/b.z)
	end
end

vector3.negate=function(a)
	return a:set(-a.x,-a.y,-a.z)
end

vector3.normalize=function(a)
	local m=a:magnitude()
	return a:set(a.x/m,a.y/m)
end

vector3.lerp=function(a,b,t)
	return a:set(
		a.x*(1-t)+b.x*t,
		a.y*(1-t)+b.y*t,
		a.z*(1-t)+b.z*t
	)
end

vector3.__tostring=function(a)
	return ("%f %f %f"):format(a:unpack())
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
	return vector3.new(a:unpack()):multiply(b)
end

vector3.__div=function(a,b)
	return vector3.new(a:unpack()):divide(b)
end

vector3.__eq=function(a,b)
	return a.x==b.x and a.y==b.y and a.z==b.z
end

-------------------------------------------------------------------------------

mat4.__index=mat4

mat4.new=function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16)
	return setmetatable({
		a1 or 1,a2 or 0,a3 or 0,a4 or 0,
		a5 or 0,a6 or 1,a7 or 0,a8 or 0,
		a9 or 0,a10 or 0,a11 or 1,a12 or 0,
		a13 or 0,a14 or 0,a15 or 0,a16 or 1
	},mat4)
end

mat4.unpack=function(a)
	return
		a[1],a[2],a[3],a[4],
		a[5],a[6],a[7],a[8],
		a[9],a[10],a[11],a[12],
		a[13],a[14],a[15],a[16]
end

mat4.set=function(a,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16)
	a[1],a[2],a[3],a[4]=a1 or 1,a2 or 0,a3 or 0,a4 or 0
	a[5],a[6],a[7],a[8]=a5 or 0,a6 or 1,a7 or 0,a8 or 0
	a[9],a[10],a[11],a[12]=a9 or 0,a10 or 0,a11 or 1,a12 or 0
	a[13],a[14],a[15],a[16]=a13 or 0,a14 or 0,a15 or 0,a16 or 1
	return a
end

mat4.set_identity=function(a)
	return a:set(
		1,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,1
	)
end

mat4.set_perspective=function(a,fov,aspect,near,far)
	local scale=tan(rad(fov)/2)
	return a:set(
		1/(scale*aspect),0,0,0,
		0,1/scale,0,0,
		0,0,-(far+near)/(far-near),-1,
		0,0,-(2*far*near)/(far-near),0
	)
end

mat4.set_orthographic=function(a,left,right,top,bottom,near,far)
	return a:set(
		2/(right-left),0,0,0,
		0,2/(top-bottom),0,0,
		0,0,-2/(far-near),0,
		-((right+left)/(right-left)),
		-((top+bottom)/(top-bottom)),
		-((far+near)/(far-near)),1
	)
end

mat4.set_position=function(a,x,y,z)
	a[4],a[8],a[12]=x or 0,y or 0,z or 0
	return a
end

mat4.set_euler=function(a,x,y,z)
	local cx,sx=cos(x),sin(x)
	local cy,sy=cos(y),sin(y)
	local cz,sz=cos(z),sin(z)
	
	a[1]=cy*cz
	a[2]=-cy*sz,sy
	a[3]=sy
	
	a[5]=cz*sx*sy+cx*sz
	a[6]=cx*cz-sx*sy*sz
	a[7]=-cy*sx
	
	a[9]=sx*sz-cx*cz*sy
	a[10]=cz*sx+cx*sy*sz
	a[11]=cx*cy
	
	return a
end

mat4.set_axis=function(a,x,y,z,t)
	local ca,sa=cos(t),sin(t)
	local m=sqrt(x^2+y^2+z^2)
	
	x,y,z=x/m,y/m,z/m
	
	a[1]=ca+x^2*(1-ca)
	a[2]=y^2*(1-ca)-z*sa
	a[3]=z^2*(1-ca)+y*sa
	
	a[5]=x^2*(1-ca)+z*sa
	a[6]=ca+y^2*(1-ca)
	a[7]=z^2*(1-ca)-x*sa
	
	a[9]=x*z*(1-ca)-y*sa
	a[10]=y*z*(1-ca)+x*sa
	a[11]=ca+z^2*(1-ca)
	
	return a
end

mat4.set_quat=function(a,x,y,z,w)
	a[1]=1-2*y^2-2*z^2
	a[2]=2*(x*y-z*w)
	a[3]=2*(x*z+y*w)
	
	a[5]=2*(x*y+z*w)
	a[6]=1-2*x^2-2*z^2
	a[7]=2*(y*z-x*w)
	
	a[9]=2*(x*z-y*w)
	a[10]=2*(y*z+x*w)
	a[11]=1-2*x^2-2*y^2
	
	return a
end

mat4.set_look=function(a,position,front,up)
	local x_axis=up:cross(front):normalize()
	local y_axis=front:cross(x_axis):normalize()
	return a:set(
		x_axis.x,y_axis.x,front.x,position.x,
		x_axis.y,y_axis.y,front.y,position.y,
		x_axis.z,y_axis.z,front.z,position.z,
		0,0,0,1
	)
end

mat4.get_position=function(a)
	return a[4],a[8],a[12]
end

mat4.get_euler=function(a)
	local a11,a12,a13,a14=a[1],a[2],a[3],a[4]
	local a21,a22,a23,a24=a[5],a[6],a[7],a[8]
	local a31,a32,a33,a34=a[9],a[10],a[11],a[12]
	local a41,a42,a43,a44=a[13],a[14],a[15],a[16]
	return
		atan2(-a23,a33),asin(a13),atan2(-a12,a11)
end

mat4.get_axis=function(a)
	local a11,a12,a13,a14=a[1],a[2],a[3],a[4]
	local a21,a22,a23,a24=a[5],a[6],a[7],a[8]
	local a31,a32,a33,a34=a[9],a[10],a[11],a[12]
	local a41,a42,a43,a44=a[13],a[14],a[15],a[16]
	local m=sqrt((a32-a23)^2+(a13-a31)^2+(a21-a12)^2)
	return
		(a32-a23)/m,
		(a13-a31)/m,
		(a21-a12)/m,
		acos((a11+a22+a33-1)/2)
end

mat4.get_quat=function(a)
	local a11,a12,a13,a14=a[1],a[2],a[3],a[4]
	local a21,a22,a23,a24=a[5],a[6],a[7],a[8]
	local a31,a32,a33,a34=a[9],a[10],a[11],a[12]
	local a41,a42,a43,a44=a[13],a[14],a[15],a[16]
	local tr=a11+a22+a33
	if tr>0 then
		local s=sqrt(tr+1)*2
		return
			(a32-a23)/s,
			(a13-a31)/s,
			(a21-a12)/s,
			0.25*s
	elseif a11>a22 and a11>a33 then
		local s=sqrt(1+a11-a22-a33)*2
		return
			0.25*s,
			(a12+a21)/s,
			(a13+a31)/s,
			(a32-a23)/s
	elseif a.r22>a.r33 then
		local s=sqrt(1+a22-a11-a33)*2
		return
			(a12+a21)/s,
			0.25*s,
			(a23+a32)/s,
			(a13-a31)/s
	else
		local s=sqrt(1+a33-a11-a22)*2
		return
			(a21-a12)/s,
			(a13+a31)/s,
			(a23+a32)/s,
			0.25*s
	end
end

mat4.multiply=function(a,b)
	local a11,a12,a13,a14=a[1],a[2],a[3],a[4]
	local a21,a22,a23,a24=a[5],a[6],a[7],a[8]
	local a31,a32,a33,a34=a[9],a[10],a[11],a[12]
	local a41,a42,a43,a44=a[13],a[14],a[15],a[16]
	
	local b11,b12,b13,b14=b[1],b[2],b[3],b[4]
	local b21,b22,b23,b24=b[5],b[6],b[7],b[8]
	local b31,b32,b33,b34=b[9],b[10],b[11],b[12]
	local b41,b42,b43,b44=b[13],b[14],b[15],b[16]
	
	return a:set(
		a11*b11+a12*b21+a13*b31+a14*b41,
		a11*b12+a12*b22+a13*b32+a14*b42,
		a11*b13+a12*b23+a13*b33+a14*b43,
		a11*b14+a12*b24+a13*b34+a14*b44,
		a21*b11+a22*b21+a23*b31+a24*b41,
		a21*b12+a22*b22+a23*b32+a24*b42,
		a21*b13+a22*b23+a23*b33+a24*b43,
		a21*b14+a22*b24+a23*b34+a24*b44,
		a31*b11+a32*b21+a33*b31+a34*b41,
		a31*b12+a32*b22+a33*b32+a34*b42,
		a31*b13+a32*b23+a33*b33+a34*b43,
		a31*b14+a32*b24+a33*b34+a34*b44,
		a41*b11+a42*b21+a43*b31+a44*b41,
		a41*b12+a42*b22+a43*b32+a44*b42,
		a41*b13+a42*b23+a43*b33+a44*b43,
		a41*b14+a42*b24+a43*b34+a44*b44
	)
end

mat4.translate=function(a,x,y,z)
	return a:multiply(temp_mat4:set(
		1,0,0,x,
		0,1,0,y,
		0,0,1,z,
		0,0,0,1
	))
end

mat4.scale=function(a,x,y,z)
	return a:multiply(temp_mat4:set(
		x,0,0,0,
		0,y,0,0,
		0,0,z,0,
		0,0,0,1
	))
end

mat4.inverse=function(a)
	local a11,a12,a13,a14=a[1],a[2],a[3],a[4]
	local a21,a22,a23,a24=a[5],a[6],a[7],a[8]
	local a31,a32,a33,a34=a[9],a[10],a[11],a[12]
	local a41,a42,a43,a44=a[13],a[14],a[15],a[16]
	
	local c11 =  a22*a33*a44-a22*a34*a43-a32*a23*a44+a32*a24*a43+a42*a23*a34-a42*a24*a33
	local c12 = -a12*a33*a44+a12*a34*a43+a32*a13*a44-a32*a14*a43-a42*a13*a34+a42*a14*a33
	local c13 =  a12*a23*a44-a12*a24*a43-a22*a13*a44+a22*a14*a43+a42*a13*a24-a42*a14*a23
	local c14 = -a12*a23*a34+a12*a24*a33+a22*a13*a34-a22*a14*a33-a32*a13*a24+a32*a14*a23
	local c21 = -a21*a33*a44+a21*a34*a43+a31*a23*a44-a31*a24*a43-a41*a23*a34+a41*a24*a33
	local c22 =  a11*a33*a44-a11*a34*a43-a31*a13*a44+a31*a14*a43+a41*a13*a34-a41*a14*a33
	local c23 = -a11*a23*a44+a11*a24*a43+a21*a13*a44-a21*a14*a43-a41*a13*a24+a41*a14*a23
	local c24 =  a11*a23*a34-a11*a24*a33-a21*a13*a34+a21*a14*a33+a31*a13*a24-a31*a14*a23
	local c31 =  a21*a32*a44-a21*a34*a42-a31*a22*a44+a31*a24*a42+a41*a22*a34-a41*a24*a32
	local c32 = -a11*a32*a44+a11*a34*a42+a31*a12*a44-a31*a14*a42-a41*a12*a34+a41*a14*a32
	local c33 =  a11*a22*a44-a11*a24*a42-a21*a12*a44+a21*a14*a42+a41*a12*a24-a41*a14*a22
	local c34 = -a11*a22*a34+a11*a24*a32+a21*a12*a34-a21*a14*a32-a31*a12*a24+a31*a14*a22
	local c41 = -a21*a32*a43+a21*a33*a42+a31*a22*a43-a31*a23*a42-a41*a22*a33+a41*a23*a32
	local c42 =  a11*a32*a43-a11*a33*a42-a31*a12*a43+a31*a13*a42+a41*a12*a33-a41*a13*a32
	local c43 = -a11*a22*a43+a11*a23*a42+a21*a12*a43-a21*a13*a42-a41*a12*a23+a41*a13*a22
	local c44 =  a11*a22*a33-a11*a23*a32-a21*a12*a33+a21*a13*a32+a31*a12*a23-a31*a13*a22

	local det = a11*c11+a12*c21+a13*c31+a14*c41
	
	if det==0 then
		return a
	end
	
	return a:set(
		c11/det,c12/det,c13/det,c14/det,
		c21/det,c22/det,c23/det,c24/det,
		c31/det,c32/det,c33/det,c34/det,
		c41/det,c42/det,c43/det,c44/det
	)
end

mat4.rotate_euler=function(a,x,y,z)
	return a:multiply(temp_mat4:set_identity():set_euler(x,y,z))
end

mat4.rotate_axis=function(a,x,y,z,t)
	return a:multiply(temp_mat4:set_identity():set_axis(x,y,z,t))
end

mat4.rotate_quat=function(a,x,y,z,w)
	return a:multiply(temp_mat4:set_identity():set_quat(x,y,z,w))
end

mat4.transpose=function(a)
	return a:set(
		a[1],a[2],a[3],a[4],
		a[5],a[6],a[7],a[8],
		a[9],a[10],a[11],a[12],
		a[13],a[14],a[15],a[16]
	)
end

mat4.lerp=function(a,b,t)
	local ax,ay,az=a:get_position()
	local bx,by,bz=b:get_position()
	
	local x1,y1,z1,w1=a:get_quat()
	local x2,y2,z2,w2=b:get_quat()
	
	local px=ax*(1-t)+bx*t
	local py=ay*(1-t)+by*t
	local pz=az*(1-t)+bz*t
	
	local dot=(x1*x2)+(y1*y2)+(z1*z2)+(w1*w2)
	
	if dot<0 then
		x2,y2,z2,w2=-x2,-y2,-z2,-w2
		dot=-dot
	end
	
	if dot>0.9995 then
		local x3=x1*t*(x2-x1)
		local y3=y1*t*(y2-y1)
		local z3=y1*t*(y2-y1)
		local w3=y1*t*(y2-y1)
		local m3=sqrt(x3^2+y3^2+z3^2+w3^2)
		
		return a:set_position(px,py,pz):set_quat(
			x3/m3,y3/m3,z3/m3,w3/m3
		)
	end
	
	local theta_0=acos(dot)
	local theta=theta_0*t
	local sin_theta=sin(theta)
	local sin_theta_0=sin(theta_0)
	
	local s0=cos(theta)-dot*sin_theta/sin_theta_0
	local s1=sin_theta/sin_theta_0
	
	return a:set_position(px,py,pz):set_quat(
		(s0*x1)+(s1*x2),
		(s0*y1)+(s1*y2),
		(s0*z1)+(s1*z2),
		(s0*w1)+(s1*w2)
	)
end

mat4.__tostring=function(a)
	return ("%f "):rep(16):format(a:unpack())
end

mat4.__add=function(a,b)
	local x,y,z=a:get_position()
	return mat4.new(a:unpack()):set_position(x+b.x,y+b.y,z+b.z)
end

mat4.__sub=function(a,b)
	local x,y,z=a:get_position()
	return mat4.new(a:unpack()):set_position(x-b.x,y-b.y,z-b.z)
end

mat4.__mul=function(a,b)
	if getmetatable(b)==vector3 then
		local a11,a12,a13,a14=a[1],a[2],a[3],a[4]
		local a21,a22,a23,a24=a[5],a[6],a[7],a[8]
		local a31,a32,a33,a34=a[9],a[10],a[11],a[12]
		local a41,a42,a43,a44=a[13],a[14],a[15],a[16]
		
		return vector3.new(
			a14+b.x*a11+b.y*a12+b.z*a13,
			a24+b.x*a21+b.y*a22+b.z*a23,
			a34+b.x*a31+b.y*a32+b.z*a33
		)
	else
		return mat4.new(a:unpack()):multiply(b)
	end
end

mat4.__eq=function(a,b)
	return
		a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[4]==b[4]
		and a[5]==b[5] and a[6]==b[6] and a[7]==b[7] and a[8]==b[8]
		and a[9]==b[9] and a[10]==b[10] and a[11]==b[11] and a[12]==b[12]
		and a[13]==b[13] and a[14]==b[14] and a[15]==b[15] and a[16]==b[16]
end

-------------------------------------------------------------------------------

udim2.__index=udim2

udim2.new=function(x_scale,x_offset,y_scale,y_offset)
	return setmetatable({
		x_scale=x_scale or 0,x_offset=x_offset or 0,
		y_scale=y_scale or 0,y_offset=y_offset or 0
	},udim2)
end

udim2.unpack=function(a)
	return a.x_scale,a.x_offset,a.y_scale,a.y_offset
end

udim2.set=function(a,x_scale,x_offset,y_scale,y_offset)
	a.x_scale,a.x_offset=x_scale or 0,x_offset or 0
	a.y_scale,a.y_offset=y_scale or 0,y_offset or 0
	return a
end

udim2.lerp=function(a,b,t)
	return a:set(
		a.x_scale*(1-t)+b.x_scale*t,
		a.x_offset*(1-t)+b.x_offset*t,
		a.y_scale*(1-t)+b.y_scale*t,
		a.y_offset*(1-t)+b.y_offset*t
	)
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

-------------------------------------------------------------------------------

rect.__index=rect

rect.new=function(min_x,min_y,max_x,max_y)
	return setmetatable({
		min_x=min_x or 0,min_y=min_y or 0,
		max_x=max_x or 0,max_y=max_y or 0
	},rect)
end

rect.unpack=function(a)
	return a.min_x,a.min_y,a.max_x,a.max_y
end

rect.set=function(a,min_x,min_y,max_x,max_y)
	a.min_x,a.min_y=min_x or 0,min_y or 0
	a.max_x,a.max_y=max_x or 0,max_y or 0
	return a
end

rect.clamp=function(a,b)
	return a:set(
		lmath.clamp(a.min_x,b.min_x,b.max_x),
		lmath.clamp(a.min_y,b.min_y,b.max_y),
		lmath.clamp(a.max_x,b.min_x,b.max_x),
		lmath.clamp(a.max_y,b.min_y,b.max_y)
	)
end

rect.lerp=function(a,b,t)
	return a:set(
		a.min_x*(1-t)+b.min_x*t,
		a.min_y*(1-t)+b.min_y*t,
		a.max_x*(1-t)+b.max_x*t,
		a.max_y*(1-t)+b.max_y*t
	)
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

-------------------------------------------------------------------------------

color3.__index=color3

color3.new=function(r,g,b)
	return setmetatable({
		r=r or 0,
		g=g or 0,
		b=b or 0
	},color3)
end

color3.unpack=function(a)
	return a.r,a.g,a.b
end

color3.set=function(a,r,g,b)
	a.r,a.g,a.b=r or 0,b or 0,g or 0
	return a
end

color3.set_hex=function(a,hex)
	hex=hex:gsub("#","")
	return a:set(
		tonumber("0x"..hex:sub(1,2))/255,
		tonumber("0x"..hex:sub(3,4))/255,
		tonumber("0x"..hex:sub(5,6))/255
	)
end

color3.set_hsv=function(a,h,s,v)
	local c=v*s
	local x=c*(1-abs(fmod(h/(60/360),2)-1))
	local m=v-c
	
	if h>=0 and h<(60/360) then
		return a:set(c+m,x+m,m)
	elseif h>=(60/360) and h<(120/360) then
		return a:set(x+m,c+m,m)
	elseif h>=(120/360) and h<(180/360) then
		return a:set(m,c+m,x+m)
	elseif h>=(180/360) and h<(240/360) then
		return a:set(m,x+m,c+m)
	elseif h>=(250/360) and h<(300/360) then
		return a:set(x+m,m,c+m)
	elseif h>=(300/360) and h<(360/360) then
		return a:set(c+m,m,x+m)
	else
		return a:set(m,m,m)
	end
end

color3.get_hsv=function(a)
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
	return a:set(
		a.r*(1-t)+b.r*t,
		a.g*(1-t)+b.g*t,
		a.b*(1-t)+b.b*t
	)
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

-------------------------------------------------------------------------------

--Data Types
lmath.vector2 = setmetatable(vector2,vector2)
lmath.vector3 = setmetatable(vector3,vector3)
lmath.mat4    = setmetatable(mat4,mat4)
lmath.rect    = setmetatable(rect,rect)
lmath.udim2   = setmetatable(udim2,udim2)
lmath.color3  = setmetatable(color3,color3)

--Constants
unit_x = lmath.vector3.new(1,0,0)
unit_y = lmath.vector3.new(0,1,0)
unit_z = lmath.vector3.new(0,0,1)

--Temps
temp_mat4 = lmath.mat4.new()

return lmath