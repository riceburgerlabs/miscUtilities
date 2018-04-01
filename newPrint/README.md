# newPrint.lua
## Description

Over writes the original print so that 'print()' will also print out the file, function and line number of where it was printed from.  Good for debugging when the console fills up with print statements.

## Installing
Download the file and require it in main.lua.
The code checks if it is being run on the simulator or not as it does not perform correctly on devices.
```lua
if system.getInfo( "environment" ) == "simulator" then
    require ("scripts.helper.newPrint")
end 
```
### Usage
Just use print as per usual.


----------


#### Example
```lua
print("Printed from main.lua at the base level (no function)")
```
**Outputs**

> 10:50:27 °/main.lua:nil():215: Printed from main.lua at the base level (no function)

*Printed at 10:50 from main.lua - no funciton - line 215*


----------


#### Example
```lua
local function test ()
	print("Printed from main.lua inside function test()")
end
test()
```
*Outputs*
>° 10:54:40 °/main.lua:test():250: Printed from main.lua inside function test()

*Printed at 10:54 from main.lua - funciton test - line 250*

## Built With
* [Corona](https://coronalabs.com/) - Corona SDK

## Authors

* Multiple sources on the Corona forums
* **Rice Burger Labs** - [Rice Burger Labs](http://www.riceburgerlabs.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

# Acknowledgments
* Big thanks to the Corona community.
<!--stackedit_data:
eyJoaXN0b3J5IjpbMjE4Mzk4NTY2XX0=
-->