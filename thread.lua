-- thread.lua
--
-- Code for threaded execution of lua code.

threadParts = {}

threadCreate = function(procName, procPath)
	if fs.isDir(procPath) or not fs.exists(procPath) then
		return false, nil
	else
		procTable = {}
		procFile = fs.open(procPath, "r")

		local functionStr = ""
		local line, layer
		repeat
			line = procFile.readLine()
			functionStr = functionStr .. line .. "\n"
			if string.match(line, "function") ~= nil then
				layer = layer + 1
			elseif string.match(line, "end") ~= nil then
				layer = layer - 1
				if layer == 0 then
					procTable[#procTable] = loadstring(functionStr)
				end
			end
		until line ~= nil

		threadParts[#threadParts] = {procName, procPath, procTable, procTable[0]}	
	end
end

threadIterate = function()
	for procName, procPath, procTable, procOrder in threadParts do
		local procOrderEntry = procOrder[procOrder[0]]
		if procOrderEntry ~= nil then
			procOrder[0] = procOrder[0] + 1
			procTable[procOrderEntry[0]](procOrderEntry[1])
		else
			threadRemove(procName)	
		end
	end
end

threadRemove = function(procName)
	for i,proc in threadParts do
		if proc[0] == procName then 
			table.remove(proc, i)
			return nil
		end
	end
end
