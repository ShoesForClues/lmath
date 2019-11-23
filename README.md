# lmath
A light math library written in Lua.

# How to use
```lua
local lmath=require("lmath")
local a=lmath.vector2(5,2)
local b=lmath.vector3(2,5,6)

print(a) --5, 2
print(a*2) --10, 4
print(a:lerp(lmath.vector2(20,6),0.5)) --7.5, 2

print(b.z) --6
print(b:dot(lmath.vector3(8,2,4))) --50
print(b:cross(lmath.vector3(8,2,4))) --8, 40, -36
```

# Data types
```lua
vector2(x,y) --{x,y}

vector3(x,y,z) --{x,y,z}

udim2(x_scale,x_offset,y_scale,y_offset) --{x={offset,scale},y={offset,scale}}

rect(min_x,min_y,max_x,max_y) --{min_x,min_y,max_x,max_y}

rgb(r,g,b) --{r,g,b}
```
