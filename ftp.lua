arg = {...}

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

function doCommand(m, id, from, cwd, scwd)
  term.write(">> ")
  input = read()
  if input == "exit" or input == "bye" or input == "quit" then
    print("Bye")
    return
  end
  t = split(input)
  if t[1] == "clear" then
    shell.run("clear")
  elseif t[1] == "lls" then
    local ls = {}
    if t[2] == nil then
      ls = fs.list(cwd)
    else
      ls = fs.list(cwd.."/"..t[2])
    end
    for _,v in ipairs(ls) do
      print(v)
    end
  elseif t[1] == "ls" then
    if t[2] == nil then
      m.transmit(port, id, t[1].." "..scwd)
    else
      m.transmit(port, id, t[1].." "..scwd.."/"..t[2])
    end
    _, _, id, from, msg, _ = os.pullEvent("modem_message")
    for _,v in ipairs(msg) do
      print(v)
    end
  elseif t[1] == "lcd" then
    if t[2] == nil then
      cwd = "/"
    else
      if t[2]:gmatch(".") == "/" then
        cwd = t[2]
        --Didn't handle .. operator
      else
        if cwd == "/" then
          cwd = cwd..t[2]
        else
          cwd = cwd.."/"..t[2]
        end
      end
    end
  elseif t[1] == "cd" then
    if t[2] == nil then
      scwd = "/"
    else
      if t[2]:gmatch(".") == "/" then
        scwd = t[2]
        --Didn't handle .. operator
      else
        if scwd == "/" then
          scwd = scwd..t[2]
        else
          scwd = scwd.."/"..t[2]
        end
      end
    end
  elseif t[1] == "put" then
    if t[2] == nil then
      print("Please supply a file to put")
    else
      ls = fs.list(cwd)
      --Bad search algorithm
      isFile = false
      for _,v in ipairs(ls) do
        if v == t[2] then
          isFile = true
        end
      end
      if isFile then
        if cwd == "/" then
          file = cwd..t[2]
        else
          file = cwd.."/"..t[2]
        end
        f = fs.open(file, "r")
        m.transmit(port, id, t[1].." "..file.." "..f.readAll())
        _, _, id, from, msg, _ = os.pullEvent("modem_message")
        print(msg)
      else
        print("File not found")
      end
    end
    elseif t[1] == "pull" then
      if t[2] == nil then
        print("Please supply a file to pull")
      else
        if scwd == "/" then
          file = scwd..t[2]
        else
          file = scwd.."/"..t[2]
        end
        m.transmit(port, id, t[1].." "..file)
        _, _, id, from, msg, _ = os.pullEvent("modem_message")
        if msg == "ERROR" then
          print("File not found")
        else
          print(msg)
          _, _, id, from, msg, _ = os.pullEvent("modem_message")
          f = io.open(file, "w")
          f:write(msg)
          f:close()
        end
      end
    end
  doCommand(m, id, from, cwd, scwd)
end

port = 21
if arg[1] ~= nil then
  port = tonumber(arg[1])
end
m = peripheral.find("modem")
if m == nil then
  print("No modems found")
  return
end
id = tonumber(os.getComputerID())
m.open(id)
print("FTP CLIENT")
doCommand(m, id, port, shell.dir(), "/")
