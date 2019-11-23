# lmath
A light math library written in Lua.

# How to use
```lua
local lmath=require("lmath")
local a=lmath.vector2(5,1)
local b=lmath.vector3(2,5,6)

print(a) --5, 1
print(b.z) --6

print(a*2) --10, 2
print(b:dot(lmath.vector3(8,2,4))) --50
print(b:cross(lmath.vector3(8,2,4))) --8, 40, -36
```

# Data types

vector2(x,y) Returns {x,y}

vector3(x,y,z) Returns {x,y,z}

udim2(x_scale,x_offset,y_scale,y_offset) Returns {x={offset,scale},y={offset,scale}}

rect(min_x,min_y,max_x,max_y) Returns {min_x,min_y,max_x,max_y}

rgb(r,g,b) Returns {r,g,b}
