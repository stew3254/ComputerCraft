local inv = require("/lib/inventory")

-- See if a computer has a crafting peripheral equipped
local function canCraft()
  local sides = peripheral.getNames()
  for _, side in ipairs(sides) do
    local p = peripheral.wrap(side)
    if p.craft ~= nil and type(p.craft) == "function" then
      return true
    end
  end
  return false
end


local function main()
  if not canCraft() then
    error("No crafting peripheral attached", 1)
  end
end

main()