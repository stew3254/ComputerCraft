local ll = require("/lib/liblua")
local inv = {}

inv.cataloguePath = "/lib/inventory/"

-- Get all items in the peripheral, if nil then all connected will be searched
-- Ignore the input and output chests in inOut
function inv.getItems(inOut, items, p)
  inOut = inOut or {}
  items = items or {}
  -- local time = os.epoch("utc")
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
    -- See if this container is excluded or not
    local skip = false
    for _, v in pairs(inOut) do
      if skip == true then
        break
      end

      if type(v) == "string" and v == container then
        skip = true
      elseif type(v) == "table" then
        for _, c in ipairs(v) do
          if c == container then
            skip = true
            break
          end
        end
      end
    end
    
    if not skip then
      for slot, _ in pairs(per.list()) do
        local item = per.getItemDetail(slot, true)
        -- Add the acess time to the item for future sorting and tracking
        -- item.accessed = time
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
  end
  return items
end

-- Get a list of the first n free slots by container
-- if n is nill then get all of them
-- if container type is nil, assume chests only
function inv.getFree(n, cType)
  local free = {}
  local count = 0
  local containers = {peripheral.find("inventory")}
  
  local function searchContainer(container, containerName)
    local slots = {}
    local occupied = container.list()
    for slot = 1,container.size(),1 do
      if occupied[slot] == nil then
        table.insert(slots, slot)
        if n ~= nil then
          count = count + 1
          if count == n then
            break
          end
        end
      end
    end

    -- See if the slots array is empty
    if slots[1] ~= nil then
      table.insert(free, {container = containerName, slots = slots})
    end
  end

  for _, container in ipairs(containers) do
    local containerName = peripheral.getName(container)
    if cType == nil or cType == "chest" then
      if containerName:find("^minecraft:chest_") ~= nil then
        searchContainer(container, containerName)
      end
    elseif cType == "furnace" then
      local types = {
        "^minecraft:furnace_",
        "^minecraft:blast_furnace_",
        "^minecraft:smoker_"
      }

      -- Search through all furnace types
      for _, t in ipairs(types) do
        if containerName:find(t) ~= nil then
          searchContainer(container, containerName)
          break
        end
      end
    else
      error("can't search other container types")
    end

    -- See if we've reached our count
    if count == n then
      return free
    end
  end
  return free
end

-- This is a helper function for inv.combine, not meant to be used on its own
local function combineContainer(container, details, limit)
  local s, e = 1, #details
  local start, stop = details[s], details[e]
  local newDetails = {start}
  local p = peripheral.wrap(container)
  
  while true do
    -- Advance if the slot is already full
    while start.count == limit do
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
    local min = ll.min(limit - start.count, stop.count)
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
      local limit = item.maxCount
      
      if startLast.count == limit then
        -- Nothing can be added to this chest, move on
        start, p = stop, p2
        stop = nil
      elseif stopLast.count == limit then
        -- This slot is also full, no sense moving items from it
        stop = nil
      else
        local min = ll.min(limit - startLast.count, stopLast.count)
        local n = p.pullItems(stop.container, stopLast.slot, min, startLast.slot)
        if n ~= min then
          printError(start.slot, stop.slot)
          printError(n, startLast.count, stopLast.count, min)
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
        if startLast.count == limit then
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
      item.containers[container] = combineContainer(container, details, item.maxCount)
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

-- This function determines which chest is an input/output chest that players
-- can interact with. If you place an item in this slot
-- it can determine which one is the output chest
-- Slot must be free before placing the item in
function inv.getSpecial(slot)
  slot = slot or 1
  local containers = {peripheral.find("inventory")}
  local empty = {}
  -- find containers where this slot is empty
  for _, container in ipairs(containers) do
    if container.getItemDetail(slot) == nil then
      table.insert(empty, container)
    end
  end
  io.stdout:write("Waiting for item to be added, press enter when done")
  read()
  for _, container in ipairs(empty) do
    if container.getItemDetail(slot) ~= nil then
      return peripheral.getName(container)
    end
  end
  error("couldn't determine chest")
end

-- import items from the input chests
function inv.input(input, items)
  -- Convert to table to make it easier to handle
  if type(input) == "string" then
    input = {input}
  end
  
  for _, name in ipairs(input) do
    local container = peripheral.wrap(name)
    local inItems = container.list()
    if #inItems > 0 then
      for slot, item in pairs(inItems) do
        item = container.getItemDetail(slot, true)
        -- See if the item is already in the storage system
        local storedItem = items[item.displayName]
        if storedItem == nil then
          -- Add it to the storage network if there is a free slot
          local free = inv.getFree(1)
          -- We can't add anything, so just exit
          if #free == 0 then
            return
          end
          free = free[1]
          -- Move the items over
          container.pushItems(free.container, slot)
          -- Add it to the storage array
          item.containers = {}
          item.containers[free.container] = {{slot = slot, count = item.count}}
          items[item.displayName] = item
        else
          -- Assume the containers have already been combined
          -- and just get the last slot. Even if they haven't it's okay,
          -- because combine later on will take care of it
          for c, details in pairs(storedItem.containers) do
            local last = details[#details]
            -- This container has space, add it here
            if last.count < storedItem.maxCount then
              local min = ll.min(storedItem.maxCount - last.count, item.count)
              local n = container.pushItems(c, slot, min, last.slot)
              if n ~= min then
                printError(n, last.count, item.count, min)
                error("outside interference detected: couldn't move expected number of items")
              end
              
              -- Change counts
              storedItem.count = storedItem.count + n
              last.count = last.count + n
              item.count = item.count - n
            end
            
            -- There are still some items left over
            if item.count > 0 then
              -- Move the excess to a free slot
              local free = inv.getFree(1)
              -- We can't add anything, so just exit
              if #free == 0 then
                return
              end
              free = free[1]
              -- Move the items over
              local n = container.pushItems(free.container, slot)
              -- Add it to the storage array
              if storedItem.containers[free.container] == nil then
                storedItem.containers[free.container] = {{slot = slot, count = item.count}}
              else
                table.insert(storedItem.containers[free.container], {slot = slot, count = item.count})
              end
              -- Increase the count
              storedItem.count = storedItem.count + n
            end
          end
        end
      end
    end
  end
end

-- Get an item from the chest to a specific output chest
-- Can be either a display name or a full item object
-- if count is nil assume a full stack of whatever item is requested
function inv.get(output, items, item, count)
  if type(output) ~= "string" then
    error("invalid output container")
  end

  local container = peripheral.wrap(output)
  
  local function removeEmpty(items, item, container, details)
    if #details == 0 then
      item.containers[container] = nil
      local empty = true
      for _, _ in pairs(item.containers) do
        empty = false
        break
      end
      if empty then
        local storedItem = item[item.displayName]
        if storedItem ~= nil and #storedItem > 1 then
          -- We have an array
          for idx, i in ipairs(storedItem) do
            if i.name == item.name and i.damage == item.damage and i.nbt == item.nbt then
              table.remove(storedItem, idx)
              break
            end
          end
        else
          items[item.displayName] = nil
        end
      end
    end
  end
  
  local function moveItems(item, c, details, left, moved)
    local last = details[#details]
    local min = ll.min(last.count, left)
    local n = container.pullItems(c, last.slot, min)
    if n ~= min then
      printError(n, last.count, item.count, min)
      error("outside interference detected: couldn't move expected number of items")
    end

    -- Update counts
    last.count = last.count - n
    item.count = item.count - n
    left = left - n
    moved = moved + n
    
    -- Remove the last item if the count is 0
    if last.count == 0 then
      details[#details] = nil
    end

    removeEmpty(items, item, c, details)
    return left, moved
  end
  
  if type(item) == "string" then
    local name = item
    item = items[name]
    if item == nil then
      error("item not found")
    end
    local left = count or item.maxCount
    local moved = 0
    -- Find the specific container where the max isn't full
    if item.count % item.maxCount > 0 then
      for c, details in pairs(item.containers) do
        left, moved = moveItems(item, c, details, left, moved)
        break
      end
    end

    -- Nothing left to move
    if left == 0 or item.count == 0 then
      return moved
    end
    
    -- Look through all containers to grab any items possible
    for c, details in pairs(item.containers) do
      left, moved = moveItems(item, c, details, left, moved)
      -- Nothing left to move
      if left == 0 or item.count == 0 then
        return moved
      end
    end
  end
end

function inv.catalogue(item, catalogue)
  -- Read the catalogue if we don't have one
  if catalogue == nil then
    -- todo finish this
  end
  if item.displayName
end

-- Gets all inventory managers and categorizes them by owner
-- Inventory managers must have a chest on the top of them in order to work
function inv.getManagers()
  local t = {}
  local managers = {peripheral.find("inventoryManager")}
  for _, manager in pairs(managers) do
    local name = peripheral.getName(manager)
    local worked, owner = pcall(manager.getOwner)
    if worked then
      -- Try to take an item from the player and give it back
      -- TODO finish this once the mod is fixed
      t[owner] = {manager = name}
    else
      if t[""] == nil then
        t[""] = {name}
      else
        table.insert(t[""], name)
      end
    end
  end
  return t
end

-- local input = inv.getSpecial()
-- local output = inv.getSpecial()
-- local file = io.open("chests.tbl", "w")
-- file:write(textutils.serialize({input = input, output = output}))
-- file:close()

local file = fs.open("chests.tbl", "r")
local inOut = textutils.unserialize(file:readAll())
file:close()

local items = inv.getItems(inOut)
file = io.open("items.tbl", "w")
file:write(textutils.serialize(inv.getItems(inOut)))
file:close()

-- file = fs.open("items.tbl", "r")
-- local items = textutils.unserialize(file:readAll())
-- file:close()

-- local n = inv.get(inOut.output, items, "Memory Card")
-- print(n)
-- local managers = inv.getManagers()
-- ll.tprint(managers)

file = io.open("items.tbl", "w")
file:write(textutils.serialize(inv.getItems(inOut)))
file:close()

return inv