local arg = {...}
local r = {}

function split(s, sep)
  if sep == nil then
    sep = "%s"
  end
  
  local t = {}
  for str in string.gmatch(s, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

if arg[1] ~= nil then
  r = http.get(arg[1])
  if r == nil then
    print("Could not get site")
    return
  end
end

if arg[2] == nil then
  local t = split(arg[1], "/")
  f = io.open(t[#t], "w")
  f:write(r.readAll())
  f:close()
else
  f = io.open(arg[2], "w")
  f:write(r.readAll())
  f:close()
end
