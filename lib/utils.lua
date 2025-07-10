--[[ BABBLEPLAY::UTILS
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]
local Utils = {}

  -- Look for <count> consecutive instances of <value> in <array>
function Utils.find_consecutive(array, value, count)
  local consecutive = 0
  for i=1, #array do
    if array[i] == value then
      consecutive = consecutive + 1
      if consecutive >= count then 
        return true 
      end
    else
      consecutive = 0
    end
  end
  return false
end

function Utils.dump(o, depth)
  local str = "{\n"
  depth = depth or 0

  local count = 0
  for k,v in pairs(o) do
    count = count + 1
  end
  if count > 40 then
    return "...\n"
  end

  for k,v in pairs(o) do
    if type(v) == "table" then
      str = str .. string.rep("  ", depth+1) .. k .. " = " .. Utils.dump(v, depth+1)
    elseif type(v) == "string" then
      str = str .. string.rep("  ", depth+1) .. k .. " = '" .. v .. "'\n"
    elseif type(v) == "boolean" then
      str = str .. string.rep("  ", depth+1) .. k .. " = "
      if v then str = str .. 'True' else str = str .. 'False' end
      str = str .. "\n"
    elseif type(v) == "userdata" then
      str = str .. string.rep("  ", depth+1) .. k .. " = <userdata>\n" 
    else
      str = str .. string.rep("  ", depth+1) .. k .. " = " .. v .. "\n"
    end

  end
  str = str .. string.rep("  ",depth) .. "}\n"
  return str
end
return Utils
