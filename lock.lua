--os.pullEvent = os.pullEventRaw
local monitor = peripheral.find("monitor")
pro = shell.getRunningProgram()
credentialsFile = pro.."SAM"
userInput = ""
passInput = ""
promptInput = ""

local function colorWhite()
  if term.isColor() == true then
    term.setTextColor(colors.white)
  end
end

local function colorYellow()
  if term.isColor() == true then
    term.setTextColor(colors.yellow)
  end
end

local function colorRed()
  if term.isColor() == true then
    term.setTextColor(colors.red)
  end
end

local function colorGreen()
  if term.isColor() == true then
    term.setTextColor(colors.green)
  end
end

local function lock()
  if fs.exists(credentialsFile) then
    local file = fs.open(credentialsFile, "r")
    user = file.readLine(1)
    pass = file.readLine(2)
    prompt = file.readLine(3)
    file.close()
  end
  -------------------------------------
  if prompt == nil then
    term.clear()
    term.setCursorPos(1,1)
    textutils.slowPrint("Hello, what would you like your username to be?")
    colorYellow()
    userInput = read()
    colorWhite()
    textutils.slowPrint("Hello "..userInput..". \nWhat would you like your password to be?")
    colorYellow()
    passInput = read()
    colorWhite()
    textutils.slowPrint("What would you like your message to say before \ndisplaying your login prompt?")
    colorYellow()
    promptInput = read()
    colorWhite()
    -------------------------------------
    if not fs.exists(credentialsFile) then
      local file = fs.open(credentialsFile, "w")
      file.write(userInput)
      file.write("\n"..passInput)
      file.write("\n"..promptInput)
      file.close()
    end
    -------------------------------------
    textutils.slowPrint("Okay, setup finished. Rebooting in 2 seconds")
    sleep(2)
    os.reboot()
  end
  -------------------------------------
  if peripheral.find("monitor") then
    monitor.setTextScale(5)
    if monitor.isColor() then
      monitor.setBackgroundColor(colors.red)
    end
    monitor.clear()
    monitor.setCursorPos(6,5)
    monitor.write("Locked")
  end
  -------------------------------------
  term.clear()
  term.setCursorPos(1,1)
  colorYellow()
  textutils.slowPrint(prompt)
  colorWhite()
  sleep(1)
  textutils.slowWrite("Username: ")
  input1= colorYellow()
  input1 = read()
  colorWhite()
  textutils.slowWrite("Password: ")
  input2 = colorYellow()
  input2 = read("*")
  if user == input1 and pass == input2 then
    if peripheral.find("monitor") then
      monitor.setTextScale(5)
      if monitor.isColor() then
        monitor.setBackgroundColor(colors.green)
      end
      monitor.clear()
      monitor.setCursorPos(5,5)
      monitor.write("Unlocked")
    end
    colorGreen()
    term.setCursorPos(1,4)
    textutils.slowPrint("Valid Login Credentials. Welcome to the System.")
    sleep(2)
    term.clear()
    term.setCursorPos(1,1)
    colorYellow()
    print(os.version())
    term.setCursorPos(1,2)
  else
    term.setCursorPos(1,4)
    colorRed()
    textutils.slowPrint("Invalid Login Credenials, Please Don't Try Again.")
    sleep(2)
    lock()
  end
end
local function isStartup() 
  if not fs.exists("startup") then
    local file = fs.open("startup", "w")
    file.write("shell.run(\"")
    file.write(pro)
    file.write("\")")
    file.close()
    os.reboot()
  else
    local file = fs.open("startup", "r")
    local readFile = file.readAll()
    file.close()
    if not string.find(readFile,"shell.run") then
      term.clear()
      term.setCursorPos(1,1)
      colorRed()
      textutils.slowPrint("You already have a startup.\nWould you like to delete it (y/n)?")
      local input = read()
      if input == "y" then
        textutils.slowPrint("Deleting startup.")
        fs.delete("startup")
        sleep(1)
        term.clear()
        term.setCursorPos(1,1)
        colorWhite()
        textutils.slowPrint("Finished, now reloading")
        sleep(1)
        isStartup()
      end
    end
  end
end

isStartup()
lock()
