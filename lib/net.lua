-- Custom serializer so functions don't break things
local serial = require("/lib/serial")

local LINK_STATUS_PROTO = 0
local IP_PROTO = 1

net = {}

local ifaceListeners = {}
local function eventListen() 
	sides = {}
	-- Get all attached peripherals
	for i, side in ipairs(peripheral.getNames()) do
		if peripheral.getType(side) == "modem" then
			table.insert(sides, side)
		end
	end
	
	local e, side, dst, src, msg, dist = os.pullEventRaw("modem_message")
	if e == "terminate" then
		-- Handle termination
		for _, side in ipairs(sides) do
			local modem = iface.close()
		end
		exit(1)
	end
	ifaceListeners[side](src, dst, msg, dist)
end

-- Interface file location
local IFACE_FILE = "/network/ifaces"
-- Some unlikely number to be collided with
local BROADCAST_PORT = 65000

-- Create a packet
function net.newPkt(args)
	if type(args) == "table" then
		local tbl = {
			src = args.src,
			dst = args.dst,
			proto = args.proto or IP_PROTO,
			msg = args.msg
		}
		
		-- Pad the protocol to fit 2 digts
		local function padNum(n, amt)
			local s = tostring(n)	
			for i = s:len()+1,amt,1 do
				s = "0"..s
			end
			return s
		end

		-- Set the packet with a tostring method
		local pkt = setmetatable(tbl, {
			__tostring = function(t)
				return string.format(
					"%s%s",
					padNum(tbl.proto, 2),
					tostring(tbl.msg)
				)
			end
		})
	else
		error("Invalid argument, must be string or table", 0)
	end
end

-- Parse a packet into a message
function net.parsePkt(src, dst, s)
	return net.newPkt{
		src = src,
		dst = dst,
		proto = tonumber(s:sub(1,2)),
		msg = s:sub(3)
	}
end

-- Open function for an interface
local function ifaceOpen(self)
	-- Open ip_port to send messages on
	modem = peripheral.wrap(self.side)
	modem.open(BROADCAST_PORT)
	modem.open(self.id)
	
	net.broadcast(self, net.newPkt{proto = LINK_STATUS_PROTO, msg = "Link online"})
end
--
-- Open function for an interface
local function ifaceClose(self)
	-- Open IP_PORT to send messages on
	modem = peripheral.wrap(self.side)
	net.broadcast(self, net.newPkt{proto = LINK_STATUS_PROTO, msg = "Link closed"})

	modem.close(BROADCAST_PORT)
	modem.close(self.id)
end


-- Create a new interface object
function net.newIface(side, id, ip, netmask)
	local iface = {
		side = side or "",
		id = id or os.getComputerID(),
		ip = ip or "",
		netmask = netmask or "",
	}
	iface.open = ifaceOpen
	iface.close = ifaceClose
	return iface
end

-- To iface
function net.toIface(iface)
	iface.open = ifaceOpen
	iface.close = ifaceClose
	return iface
end

-- List all network interfaces
function net.interfaces(refresh)
	-- If the file exists, just return its contents
	local f = fs.open(IFACE_FILE, "r")
	local ifaces = {}
	
	-- See if we should refresh the interfaces
	if f ~= nil and not refresh then
		for _, iface in ipairs(serial.unserialize(f.readAll())) do
			table.insert(ifaces, net.toIface(iface))
		end

		f.close()
		return ifaces
	end

	-- Get all attached peripherals
	for i, side in ipairs(peripheral.getNames()) do
		if peripheral.getType(side) == "modem" then
			table.insert(ifaces, net.newIface(side))
		end
	end
	
	-- Save the interfaces to a file
	f = fs.open(IFACE_FILE, "w")
	f.write(serial.serialize(ifaces))
	f.close()

	return ifaces
end

-- Send messages
function net.send(iface, pkt)
	local modem = peripheral.wrap(iface.side)
	-- If the source isn't set, use the local interface
	pkt.src = pkt.src or iface.id
	-- Make it a broadcast if destination isn't set
	pkt.dst = pkt.dst or BROADCAST_PORT
	-- Send the packet
	modem.transmit(pkt.dst, pkt.src, tostring(pkt))
end

-- Broadcast messages
function net.broadcast(iface, pkt)
	-- Change the packet destination to the broadcast port
	pkt.dst = BROADCAST_PORT
	net.lsend(iface, pkt)
end

-- Receive message
function net.recv(iface)
end