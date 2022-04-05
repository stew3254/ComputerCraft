utils = {}

-- Generate a mac address
function utils.generateMac()
	local base16 = {0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f"}
	local addr = ""
	for i = 0,11,1 do
		if i % 2 == 0 and i ~= 0 then
			addr = addr..":"
		end
		addr = addr..tostring(base16[math.random(1, 16)])
	end
	return addr
end

-- Remove mac of colons
function utils.stripMac(mac)
  local new = ""
  for  c in mac:gmatch"." do
    if c ~= ":" then
      new = new..c
    end
  end
  return new
end

-- Fix mac and add colons
function utils.fixMac(mac)
  local new = ""
  i = 0
  for c in mac:gmatch"." do
    if i % 2 == 0 and i ~= 0 then
      new = new..":"
    end
    new = new..c
    i = i + 1
  end
  return new
end

return utils