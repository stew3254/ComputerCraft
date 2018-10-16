-- thread.lua
--
-- Code for threaded execution of lua code.

<<<<<<< HEAD
-- Stores all threads that have been created.
threadParts = {}

-- Creates a new thread
threadCreate = function(procName, procPath)
	-- Does the file exist and are we really reading a file?
	if fs.isDir(procPath) or not fs.exists(procPath) then
		return false, nil
	else
		-- Table that holds all of the functions from the file
		procTable = {}
		procFile = fs.open(procPath, "r")

		-- Run through the file by loading functions as strings into procTable.
=======
threadParts = {}

threadCreate = function(procName, procPath)
	if fs.isDir(procPath) or not fs.exists(procPath) then
		return false, nil
	else
		procTable = {}
		procFile = fs.open(procPath, "r")

>>>>>>> 2248fe7f7baccc58fa1ad4a7fa70051b06adaff6
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
<<<<<<< HEAD
		
		-- Create the new thread entry. In order, it contains the name of the process, the path of the file it came from, a table of functions and a table of what functions should be run and what parameters should be passed to it. 
=======

>>>>>>> 2248fe7f7baccc58fa1ad4a7fa70051b06adaff6
		threadParts[#threadParts] = {procName, procPath, procTable, procTable[0]}	
	end
end

<<<<<<< HEAD
-- Run through every thread entry and run the queued function. Terminates the thread when there are no more functions to call in procOrder
=======
>>>>>>> 2248fe7f7baccc58fa1ad4a7fa70051b06adaff6
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

<<<<<<< HEAD
-- Called by threadIterate when a thread is out of functions to call. Can also be called to end a thread early. 
=======
>>>>>>> 2248fe7f7baccc58fa1ad4a7fa70051b06adaff6
threadRemove = function(procName)
	for i,proc in threadParts do
		if proc[0] == procName then 
			table.remove(proc, i)
			return nil
		end
	end
end
