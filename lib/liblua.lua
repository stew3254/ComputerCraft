local string = require("string")
local table = require("table")

local ll = {}

function ll.max(a, b)
  if a >= b then
    return a
  else
    return b
  end
end

function ll.min(a, b)
  if a <= b then
    return a
  else
    return b
  end
end

-- Split a string
function ll.split(s, sep)
  if sep == nil then
    sep = "%s"
  end
  
  local t = {}
  for str in string.gmatch(s, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
split = ll.split

-- Slice table
function ll.slice(tbl, first, last, step)
  local sliced = {}
  
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end
  
  return sliced
end
slice = ll.slice

-- Map function
function ll.map(f, ...)
  local args = {...}
  local ret = {}
  for i = 1, #args[1] do
    local t = {}
    for j = 1, #args do
      table.insert(t, #t+1, args[j][i])
    end
    table.insert(ret, #ret+1, f(table.unpack(t)))
  end
  return ret
end
map = ll.map

-- Used to apply filters to a regular list
function ll.filter(f, l)
  local ret = {}
  for _,v in ipairs(l) do
    table.insert(ret, #ret+1, f(v) and v or nil)
  end
  return ret
end
filter = ll.filter

-- Returns true is something is in the sequence
function ll.any(seq)
  for i, v in ipairs(seq) do
    if v then
      return true
    end
  end
  return false
end
any = ll.any

-- TODO finish this
-- Reduce a regular list
-- function ll.reduce(f, l, init)
--   local start = 1
--   if init == nil then
--     init = l[1]
--     start = 2
--   end

--   local agg = nil
--   for i = start, #l-1 do
--     if l[i]
--   end

--   for _,v in ipairs(t) do
--     table.insert(ret, #ret+1, f(v) and v or nil)
--   end
--   return ret
-- end

-- Simple table printing. Does not do recursive tables
function ll.tprint(...)
  local t = {...}
  for i = 1, #t do
    for k,v in pairs(t[i]) do
      print(k,v)
    end
  end
end

function ll.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

return ll

-- wget -f http://mc.bashed.rocks:13699/lib/liblua.lua /usr/lib/liblua.lua