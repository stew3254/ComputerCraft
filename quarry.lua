--VARS
count = 0
face = 0
left = nil
right = nil
--Directions
frontDir = 0
rightDir = 1
backDir = 2
leftDir = 3
height = 0
distForward = 0
distLeft = 0
distRight = 0
--------------------
--FUNCTIONS
--Movement
function moveUp()
  turtle.up()
  checkFuel()
  checkInv()
  h = h + 1
end
function moveDown()
  turtle.down()
  checkFuel()
  checkInv()
  h = h - 1
end
function moveForward()
  turtle.forward()
  checkFuel()
  checkInv()
  f = f + 1
end
function moveBackward()
  turtle.back()
  checkFuel()
  checkInv()
  f = f - 1
end
function turnLeft()
  turtle.turnLeft()
  face = math.abs((face - 1)%4)
end
function turnRight()
  turtle.turnRight()
  face = math.abs((face + 1)%4)
end
function turn180()
  turtle.turnLeft()
  turtle.turnLeft()
end
--------------------
--Digging
function dig()
  turtle.dig()
  turtle.suck()
  count()
end
function digUp()
  turtle.digUp()
  turtle.suckUp()
  count()
end
function digDown()
  turtle.digDown()
  turtle.suckDown()
  count()
end
--------------------
--Maintainance
function count()
    count = count + 1
    term.setCursorPos(1,4)
    term.clearLine()
    print("Blocks Mined")
end
function checkFuel()
  fuel = turtle.getFuelLevel()
  while fuel == 0 do
    term.setCursorPos(1,3)
    term.clearLine()
    print("Turtle is Out of Fuel!")
  end
  term.setCursorPos(1,3)
  term.clearLine()
  print("Current Fuel Level: "..fuel)
end
function checkInv()
  turtle.select(15)
  if turtle.getItemCount > 0 then
    gotoHome()
  end
end
function gotoHome()
end
function returnToMine()
end
---------------
--START
while true do
  term.clear()
  term.setCursorPos(1,1)
  print("Welcome to Stew's Quarry Program")
  print("How far back should I move? ")
  forward = read()
  while true do
    print("Do I go left or right from here?")
    dir = read()
    if dir == "l" or dir == "left" then
      left = dir
      return
    elseif dir == "r" or dir == "right" then
      right = dir
      return
    else
      print("Incorrect direction given, please try again")
      sleep(1)
      term.setCursorPos(1,4)
      term.clearLine()
      term.setCursorPos(1,3)
      term.clearLine()
    end
  end
  print("How far?")
  num = read()
  if dir == left then
    dir, left = num
  elseif dir == right then
    dir, right = num
  end
  print("Place 2 chests in the first slot")
  while true do
    data = turtle.getItemDetail()
    if data.name == chest and data.count == 2 then return end
  end
  term.setCursorPos(1,5)
  term.clearLine()
  print("Mining a "..back.." by "..dir.." area")
  sleep(1)
--------------------
--MINE
  term.clear()
  term.setCursorPos(1,1)
  print("Running Stew's Miner Program")
  print("If fuel needed, place it in slot 16")
  checkFuel()
  checkInv()
  count()
  turtle.select(1)
  turtle.place()
  if dir == left then
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.place()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnLeft()
  end
  if dir == right then
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    turtle.place()
    turtle.turnRight()
    turtle.forward()
    turtle.turnRight()
  end
  digDown()
  moveDown()
  digDown()
  moveDown()
  digDown()
  if dir%2 == 0 then
    for i = 1, dir/2 - 1 do
      for i = 1, forward - 1 do
        dig()
        forward()
        digUp()
        digDown()
      end
    end
  else
    for i = 1, dir/2 do
      for i = 1, forward - 1 do
        dig()
        forward()
        digUp()
        digDown()
      end
      if left == nil then
        
    end
end
