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
