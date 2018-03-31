-- Original work was taken from the forum (not exactly sure), some changes made to suit my needs.

--------------
-- newPrint.lua
--------------
-- Over writes the original print and will print out the file, function and line number of where it was printed from.

--------------
-- Usage 
--------------
-- put the following in your main.lua
-- need to check if not on the simulator as the code does not perform correctly on the similator
--if system.getInfo( "environment" ) == "simulator" then
--    require ("scripts.helper.newPrint")
--end 

-- -- debug print overide
-- -- you can use _print() in code if you want original
 
_G._print = print


local localdir
local projectCodeRootString 
 
function string.join( arg )
    -- function requires a string, a separator, and at least one argument;
    -- if this condition is not met, print and error and return nil

    if ( #arg < 1 ) then
      --  _print( "Error: required string and separator missing" )
        return nil
    end
 
    -- the string is the first argument
    local str = ""

    -- the separator is the second argument
    local separator = "    "
 
    -- loop from the third index (the first real argument to join to the string)
    for i = 1, #arg do
        -- if the argument is a string, append it along with the separator

        if ( str:len() ~= 0 ) then
            str = str .. separator
        end
        str = str .. tostring(arg[i])

    end
    return str
end
 
 
function initialise_print( ... )
 
    print = function(...)
        local function cleanText(text)
           if text == nil then
              return "nil"
           end
           return text
        end

        local source_file = cleanText(debug.getinfo(2).source) 
        local path_start, path_end = source_file:find(projectCodeRootString)
        
        local debug_path
        local line
        local funcName
        if path_start == nil and debug.getinfo(3) then
            local source_file = cleanText(debug.getinfo(3).source)
            local path_start, path_end = source_file:find(projectCodeRootString)
            if path_start == nil then
                debug_path = "Not sure where it was called from -> "
            else
                debug_path = "Called From -> " .. cleanText(source_file:sub(path_end, source_file:len())) 
            end
            line = cleanText(debug.getinfo(3).currentline)
            -- This gets the function name:
            funcName = cleanText(debug.getinfo(3, "n").name)
        elseif source_file:len() > 3 then
            debug_path = cleanText(source_file:sub(path_end, source_file:len())) 
            line = cleanText(debug.getinfo(2).currentline)
         
        -- This gets the function name:
            funcName = cleanText(debug.getinfo(2, "n").name)
        else 
            debug_path = "unknown"
            line = "unknown"
            funcName = "unknown"
        end
        -- This gets the line number:
        
        local str = string.join(arg)
        local t = os.date( '*t' )
        local prefix = "° ".. os.date( "%H:%M:%S" ) .. " °" ..debug_path..":"..funcName.."()"..":"..line..":"
        _print(string.format("%-65s",  prefix), str)
    end
end
 
table.print_r = function ( t ) 
    if onSimulator then
        local function cleanText(text)
           if text == nil then
              return "nil"
           end
           return text
        end
        local projectCodeRootString 
        local fp = system.pathForFile( "main.lua", system.ResourceDirectory )
        local localdir = fp:gsub( "main.lua", "" )
        local projectCodeRootString = localdir
         
        -- local projectCodeRootString = '/LeapFrog/code/'

        local source_file = cleanText(debug.getinfo(2).source)
        local path_start, path_end = source_file:find(projectCodeRootString)
         
        if path_start == nil then
            return 
        end
        local debug_path = cleanText(source_file:sub(path_end, source_file:len()))
        -- This gets the line number:
        local line = cleanText(debug.getinfo(2).currentline)
         
        -- This gets the function name:
        local funcName = cleanText(debug.getinfo(2, "n").name)
        _print("------------- TABLE -------------")

        _print("°"..debug_path..":"..funcName.."()"..":"..line.." -> ")
    end

    --local depth   = depth or math.huge
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            _print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    local pos = tostring(pos)
                    if (type(val)=="table") then
                        _print(indent.."["..tostring(pos).."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+1))
                        _print(indent..string.rep(" ",string.len(pos)+1).."}")
                    elseif (type(val)=="string") then
                        _print(indent.."["..pos..'] => "'..val..'"')
                    else
                        _print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end         
        end
    end
    if (type(t)=="table") then
        _print("   " .. tostring(t).." {")
        sub_print_r(t,"     ")
        _print("   }")
    else
        sub_print_r(t," ")
    end
end
 
-- this is done so that the ios build doesnt break
local fp = system.pathForFile( "main.lua", system.ResourceDirectory )
if fp ~= nil then
    localdir = fp:gsub( "main.lua", "" )
    projectCodeRootString = localdir
    _print("Project Location: ".."°°"..localdir.."°°") -- this is to create a nice easy tag
    initialise_print()
else
    print = _print -- cancel overriding
    print( "ios error: fp: is nil. customm print overide cancelled" )
end