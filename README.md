# lmath
A light math library written in Lua.

# Object Types

- **vector2**
- **vector3**
- **udim2**
- **rect**
- **color3**
- **matrix4**

# Example Usage
```lua
local a = lmath.vector3.new(1,2,3)

print(a) --1 2 3

local b = lmath.vector3.new()
b:set(4,5,6) --Sets b's components to x=4,y=5,z=6. You can also set them manually (Ex: b.x=4)

print(b) --4 5 6

a:add(b) --Performs the operation on object a

print(a) --5 7 9

local c=a+b --Using the overloaded operators will create a new object
```

# License
This software is free to use. You can modify it and redistribute it under the terms of the 
MIT license. Check [LICENSE](LICENSE) for further details.
