turtle.select(1)
while true do
  if turtle.getItemCount() > 0 then
    while not turtle.dropUp() do
      term.clear()
      term.setCursorPos(1,1)
      print("Chest is Full!")
    end
  end
  if turtle.detect() then
    turtle.dig()
    turtle.suck()
    term.clear()
    term.setCursorPos(1,1)
    print("Filling Chest")
  end
end
