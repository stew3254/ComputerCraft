arg = {...}

function listen(m)
  while true do
    _, _, id, from, msg, _ = os.pullEvent("modem_message")
    local pos = msg:find("%s")
    local sub = msg:sub(pos+1)
    --Get command and file name
    local command = msg:sub(0, pos-1)
    pos = sub:find("%s")
    local file = ""
    if pos ~= nil then
      file = sub:sub(0, pos-1)
    else
      file = sub
    end
    sleep(.1)
    if command == "ls" then
      m.transmit(from, id, fs.list(file))
    elseif command == "cd" then
      m.transmit(from, id, shell.setDir(file))
    elseif command == "pull" then
      f = fs.open(file, "r")
      if f == nil then
        m.transmit(from, id, "ERROR")
      else
        m.transmit(from, id, "OK")
        sleep(.1)
        m.transmit(from, id, f.readAll())
        f:close()
      end
    elseif command == "put" then
      f = io.open(file, "w")
      if pos == nil then
        m.transmit(from, id, "ERROR")
      else
        f:write(sub:sub(pos+1))
        f:close()
        m.transmit(from, id, "OK")
      end
    else
      m.transmit(from, id, "ERROR")
    end
  end
end

local port = 21
if arg[1] ~= nil then
  port = tonumber(arg[1])
end
m = peripheral.find("modem")
if m == nil then
  print("No modems found")
  return
end
--Open port 21
m.open(21)
listen(m)