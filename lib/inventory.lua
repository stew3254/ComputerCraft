local ll = require("/lib/liblua")
local inv = {}

-- Get all items in the peripheral, if nil then all connected will be searched
function inv.getItems(p)
  local items = {}
  -- If the peripheral doesn't exist, look at all attached peripherals
  local peripherals = {}
  if p ~= nil then
    -- For turtles which don't have size
    if p.list == nil then
      p.list = function()
        local t = {}
        for i = 1,16,1 do
          table.insert(t, i, p.getItemDetail(i, true))
        end
        return t
      end
    end
    peripherals = {p}
  else
    peripherals = {peripheral.find("inventory")}
  end

  for _, per in ipairs(peripherals) do
    local container = peripheral.getName(per)
    for slot, _ in pairs(per.list()) do
      local item = per.getItemDetail(slot, true)
      -- Get detailed item info
      if items[item.displayName] == nil then
        -- Add the item container, slot and count
        item.containers = {}
        item.containers[container] = {{slot = slot, count = item.count}}
        -- See if it's an item with damage or NBT associated with it
        if item.damage ~= nil or item.damage ~= nil then
          -- Add the item to a list of items with damage
          items[item.displayName] = {item}
        else
          -- Add the item as is
          items[item.displayName] = item
        end
      else
        local storedItem = items[item.displayName]
        -- The item must have damage since it's a list
        if storedItem.displayName == nil then
          -- Add the item container, slot and count
          item.containers = {}
          item.containers[container] = {{slot = slot, count = item.count}}
          table.insert(storedItem, item)
        else
          -- Add the container and slot
          if storedItem.containers[container] == nil then
            storedItem.containers[container] = {{slot = slot, count = item.count}}
          else
            table.insert(storedItem.containers[container], {slot = slot, count = item.count})
          end

          -- See if the name, nbt and damage match
          if storedItem.name == item.name and
            storedItem.damage == item.damage and
            storedItem.nbt == item.nbt then
            storedItem.count = storedItem.count + item.count
          else
            -- Since they don't match, convert this back into a list
            items[item.displayName] = {storedItem, item}
          end
        end
      end
    end
  end
  return items
end

-- Get a list of free slots by container
function inv.getFree()
  local free = {}
  local containers = {peripheral.find("inventory")}
  for _, container in ipairs(containers) do
    local slots = {}
    local occupied = container.list()
    for slot = 1,container.size(),1 do
      if occupied[slot] == nil then
        table.insert(slots, slot)
      end
    end
    -- See if the slots array is empty
    if slots[1] ~= nil then
      free[peripheral.getName(container)] = slots
    end
  end
  return free
end

-- This is a helper function for inv.combine, not meant to be used on its own
local function combineContainer(container, details)
  local s, e = 1, #details
  local start, stop = details[s], details[e]
  local newDetails = {start}
  local p = peripheral.wrap(container)
  
  while true do
    -- Advance if the slot is already full
    while start.count == p.getItemLimit(start.slot) do
      -- Since the slot is full, add it to the table
      table.insert(newDetails, start)
      s = s + 1
      start = details[s]
      -- We are done
      if start == nil then
        return newDetails
      end
    end

    -- We are done
    if s >= e then
      table.insert(newDetails, start)
      return newDetails
    end
    
    -- Grab as many items as possible and move it over
    local min = ll.min(p.getItemLimit(start.slot) - start.count, stop.count)
    local n = p.pullItems(container, stop.slot, min, start.slot)
    if n ~= min then
      printError(start.slot, stop.slot)
      printError(n, start.count, stop.count, min)
      error("outside interference detected: couldn't move expected number of items")
    end
    -- Modify the counts to account for the items we moved
    start.count = start.count + n
    stop.count = stop.count - n
    -- We cleared this slot, move on
    if stop.count == 0 then
      e = e - 1
      stop = details[e]
    end
  end
end

-- Helper function to combine multiple containers together assuming
-- They are already packed per container
local function combine(item)
  local containers = {}
  local changed = false
  local start, stop = nil, nil

  local p = nil
  local p2 = nil
  
  for container, details in pairs(item.containers) do
    containers[container] = details
    
    -- Intialize variables
    if start == nil then
      start = {container = container, details = details}
      p = peripheral.wrap(container)
    elseif stop == nil then
      stop = {container = container, details = details}
      p2 = peripheral.wrap(container)
    end

    if start ~= nil and stop ~= nil then
      local startLast = start.details[#details]
      local stopLast = stop.details[#details]
      local startLimit = p.getItemLimit(startLast.slot)
      local stopLimit = p2.getItemLimit(stopLast.slot)
      
      if startLast.count == startLimit then
        -- Nothing can be added to this chest, move on
        start, p = stop, p2
        stop = nil
      elseif stopLast.count == stopLimit then
        -- This slot is also full, no sense moving items from it
        stop = nil
      else
        local min = ll.min(startLimit - startLast.count, stopLast.count)
        local n = p.pullItems(stop.container, stopLast.slot, min, startLast.slot)
        if n ~= min then
          printError(start.slot, stop.slot)
          printError(startLimit, stopLimit)
          printError(n, startLimit.count, stopLimit.count, min)
          error("outside interference detected: couldn't move expected number of items")
        end

        -- Modify counts
        startLast.count = startLast.count + n
        stopLast.count = stopLast.count - n
        
        -- This is empty, so it's no longer needed
        if stopLast.count == 0 then
          table.remove(stop.details[#details])
          -- Remove the container from the table if this item no longer
          -- exists in this chest
          if #details == 0 then
            containers[container] = nil
          end
          stop = nil
        end

        -- This is full, so replace it with the last known thing
        -- This is okay if start becomes nil
        if startLast.count == startLimit then
          start, p = stop, p2
        end
      end
    end
  end

  -- Only change if something moved
  if changed then
    item.containers = containers
  end
end

-- Try to combine everything into the most dense arrangement as possible
-- This not only modifies the actual inventories, but also the table given
-- Be aware of this when using this function
function inv.combine(items)
  local function combineSingleContainers(item)
    -- Look through each container
    for container, details in pairs(item.containers) do
      -- Update the container contents
      item.containers[container] = combineContainer(container, details)
    end
  end

  local function doAction(items, f)
    -- Operate on every item
    for itemName, item in pairs(items) do
      if item.displayName == nil then
        local itms = item
        -- This is a list of items, so do it for each one
        for _, item in ipairs(itms) do
          f(item)
        end
      else
        -- Just handle by itself
        f(item)
      end
    end
  end

  doAction(items, combineSingleContainers)
  -- Now go back and try to combine stragglers from each container
  doAction(items, combine)
end

local items = inv.getItems()
-- local file = io.open("items.tbl", "w")
-- file:write(textutils.serialize(items))
-- file:close()

-- local file = fs.open("items.tbl", "r")
-- local items = textutils.unserialize(file:readAll())
-- file:close()

inv.combine(items)

return inv