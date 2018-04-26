--Start Program
function startProgram()
  term.clear()
  term.setCursorPos(1,1)
  print("Type 'help' for help with actions.")
  print("What would you like me to do?")
  input = read()
  sleep(1)
  ifStatements()
  term.clear()
  term.setCursorPos(1,1)
end
--------------------
--If statement sections of program
function ifStatements()
  if input == "help" then
    helpMe()
  end
  if input == "help 2" then
    helpMe2()
  end
  if input == "list" then
    listFeatures()
  end
  if input == "house" then
    buildHouse()
  end
  if input == "frame" then
    buildFrame()
  end
  if input == "platform" then
    buildPlatform()
  end
  if input == "wall" then
    buildWall()
  end
  if input == "floor" then
    buildFloor()
  end
end
--------------------
--Help
function helpMe()
  if input == "help" then
    print("Welcome to the help section.")
    print("'list' will list build features that can be used.")
    print("'help house' will give a description of the house feature.")
    print("'help frame' will give a description of the frame feature.")
    print("'help platform' will give a description of the platform feature.")
    print("Type 'help 2' for more features")
    input = read()
    sleep(1)
    ifStatements()
    term.clear()
    term.setCursorPos(1,1)
  end
end
--------------------
--Help 2
function helpMe2()
  if input == "help 2" then
    print("Help page 2.")
    print("'help wall' will give a description of the wall feature.")
    print("'help floor' will give a description of the floor feature.")
    input = read()
    sleep(1)
    ifStatements()
    term.clear()
    term.setCursorPos(1,1)
  end
end
--------------------
--List
function listFeatures()
  if input == list then
    print("1. House")
    print("2. Frame")
    print("3. Platform")
    print("4. Wall")
    print("5. Floor")
    input = read()
    sleep(1)
    ifStatements()
    term.clear()
    term.setCursorPos(1,1)
  end
end
--------------------
--Help House
function helpHouse()
  print("The house dimensions are based on the")
  print("outer wall of the house. When the floor")
  print("is added, it does not take away from the")
  print("original height estimate. The floor is")
  print("added to the bottom of the original.")
  print("height you added.")
  input = read()
  sleep(1)
  ifStatements()
  term.clear()
  term.setCursorPos(1,1)
end
--------------------
--Check Inventory Slots
function checkSlot()
  for slot = 1,16 do
    if turtle.getItemCount(slot) >0 then
      turtle.select(slot)
    break
    end
  end
end
function turn180()
  turtle.turnLeft()
  turtle.turnLeft()
end
--------------------
--House Build Corner
function corner()
  if highHouse%2 == 0 then
    turn180()
    for moveCorner = 1, leftHouse - 2 do
      turtle.forward()
    end
  end
  turtle.turnLeft()
  turtle.forward()
  turn180()
  for downCorner = 1, highHouse do
    turtle.down()
  end
end
--------------------
--Roof Finish Row then Turn Left
function roofRowTurnLeft()
  for buildRoofRow = 1, backHouse - 3 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  turtle.turnLeft()
end
--------------------
--Roof Finish Row then Turn Right
function roofRowTurnRight()
  for buildRoofRow = 1, backHouse - 3 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnRight()
  turtle.back()
  checkSlot()
  turtle.place()
  turtle.turnRight()
end
--------------------
--Ends the Roof
function roofEnd()
  for buildRoofRow = 1, backHouse - 3 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.down()
  turtle.placeUp()
end
--------------------
--Floor Finish Row then Turn Left
function floorRowTurnleft()
  for buildfloorRow = 1, backHouse - 1 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  turtle.turnLeft()
end
--------------------
--Floor Finish Row then Turn Right
function floorRowTurnRight()
  for buildfloorRow = 1, backHouse - 1 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnRight()
  turtle.back()
  checkSlot()
  turtle.place()
  turtle.turnRight()
end
--------------------
--Floor
function buildFloor()
  if backHouse%2 == 1 then
    for movebackHouse = 1, backHouse - 3 do
      turtle.forward()
    end
    turn180()
  end
  turtle.turnRight()
  for moveleftHouse = 1, leftHouse - 3 do
    turtle.forward()
  end
  turtle.turnRight()
  for moveDown = 1, highHouse - 1 do
    turtle.down()
  end
  turtle.turnLeft()
  turtle.forward()
  turtle.turnRight()
  turtle.forward()
  if leftHouse%2 == 1 then
    for buildFloor = 1, leftHouse/2 - .5 do
      floorRowTurnleft()
      floorRowTurnRight()
    end
    floorRowTurnleft()
  else
    for buildFloor = 1, leftHouse/2 do
      floorRowTurnLeft()
      floorRowTurnRight()
    end
  end
end
--------------------
--House
if input == 1 then
  print("Building the house.")
  print("How far back?")
  backHouse = read()
  print("How far left?")
  leftHouse = read()
  print("How tall?")
  highHouse = read()
  print("Needs floor? (y/n)")
  floor = read()
  if string.find(floor, "y") or string.find(floor, "Y") then
    print("Okay, you want it "..backHouse.." by "..leftHouse.." by "..highHouse..".\nWith a floor.")
  else
    print("Okay, you want it "..backHouse.." by "..leftHouse.." by "..highHouse..".\nWith no floor.")
  end
  sleep(2)
  --------------------
  --First Wall
  turn180()
  for buildleftHousehighHouse = 1, highHouse do
    for buildleftHouse = 1, leftHouse - 1 do
      turtle.back()
      checkSlot()
      turtle.place()
    end
    turtle.up()
    checkSlot()
    turtle.placeDown()
    turn180()
  end
  --------------------
  --First Corner
  if highHouse%2 == 0 then
      turn180()
      for moveCorner = 1, leftHouse - 1 do
        turtle.forward()
      end
    end
    turtle.turnLeft()
    turtle.forward()
    turn180()
    for downCorner = 1, highHouse do
      turtle.down()
    end
  --------------------
  --Second Wall
  for buildleftHousehighHouse = 1, highHouse do
    for buildleftHouse = 1, leftHouse - 2 do
      turtle.back()
      checkSlot()
      turtle.place()
    end
    turtle.up()
    checkSlot()
    turtle.placeDown()
    turn180()
  end
  --------------------
  --Second Corner
  corner()
  --------------------
  --Third Wall
  for buildbackHousehighHouse = 1, highHouse do
    for buildbackHouse = 1, backHouse - 2 do
      turtle.back()
      checkSlot()
      turtle.place()
    end
    turtle.up()
    checkSlot()
    turtle.placeDown()
    turn180()
  end
  --------------------
  --Third Corner
  corner()
  --------------------
  --Fourth Wall
  for buildleftHousehighHouse = 1, highHouse do
    for buildleftHouse = 1, leftHouse - 3 do
      turtle.back()
      checkSlot()
      turtle.place()
    end
    turtle.up()
    checkSlot()
    turtle.placeDown()
    turn180()
  end
  --------------------
  --Roof
  if highHouse%2 ==0 then
    turtle.turnLeft()
    turtle.turnLeft()
    for moveleftHouse = 1, leftHouse - 3 do
      turtle.forward()
    end
  end
  turtle.turnLeft()
  turtle.forward()
  turtle.down()
  turn180()
  if leftHouse%2 == 1 then
    for buildCeiling = 1, leftHouse/2 - 1.5 do
      roofRowTurnleftHouse()
      roofRowTurnRight()
    end
    roofEnd()
  else
    for buildCeiling = 1, leftHouse/2 - 2 do
      roofRowTurnleftHouse()
      roofRowTurnRight()
    end
    roofRowTurnleftHouse()
    roofEnd()
  end
  --------------------
  --Floor
  if string.find(floor, "y") or string.find(floor, "Y") then
    buildFloor()
  end
end
--------------------
--Frame
if input == 2 then
  print("Building the frame.")
  print("How far back?")
  backFrame = read()
  print("How far left?")
  leftFrame = read()
  print("How tall?")
  highFrame = read()
  print("Okay, you want it "..backFrame.." by "..leftFrame.." by "..highFrame..".")
  --------------------
  --Floor Frame
  turn180()
  for buildBack = 1, backFrame - 1 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  for buildLeft = 1, leftFrame - 2 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  for buildBack = 1, backFrame - 2 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  for buildLeft = 1, leftFrame - 3 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.up()
  checkSlot()
  turtle.placeDown()
  turn180()
  checkSlot()
  turtle.place()
  --------------------
  --Outer Frame
  for buildHigh = 1, highFrame - 1 do
    turtle.up()
    checkSlot()
    turtle.place()
  end
  turtle.turnLeft()
  turtle.forward()
  turtle.turnRight()
  turtle.forward()
  turtle.turnRight()
  for buildBack = 1, backFrame - 2 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  for buildDown = 1, highFrame - 1 do
    turtle.down()
    checkSlot()
    turtle.placeUp()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  for moveHigh = 1, highFrame - 1 do
    turtle.up()
  end
  for buildLeft = 1, leftFrame - 2 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  for buildDown = 1, highFrame - 1 do
    turtle.down()
    checkSlot()
    turtle.placeUp()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  for moveHigh = 1, highFrame - 1 do
    turtle.up()
  end
  for buildBack = 1, backFrame - 2 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  for buildDown = 1, highFrame - 1 do
    turtle.down()
    checkSlot()
    turtle.placeUp()
  end
  turtle.turnLeft()
  turtle.back()
  checkSlot()
  turtle.place()
  for moveHigh = 1, highFrame - 1 do
    turtle.up()
  end
  for buildLeft = 1, leftFrame - 3 do
    turtle.back()
    checkSlot()
    turtle.place()
  end
  turtle.up()
  checkSlot()
  turtle.placeDown()
end