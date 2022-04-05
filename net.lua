-- Custom serializer so functions don't break things
local serial = require("/lib/serial")
local utils = require("/lib/net_utils")

-- Need a more secure way of getting random, but best I got now
math.randomseed(os.epoch("utc"))

local IP_PROTO = 1

net = {}

-- Interface file location
local IFACE_FILE = "/network/ifaces"
-- Some unlikely number to be collided with
local IP_PORT = 65000

-- Create a packet
function net.newPacket(args)
	if type(args) == "table" then
		local tbl = {
			src = args.src,
			dst = args.dst,
			proto = args.proto,
			msg = args.msg
		}
		
		local function makeProto(proto)
			local s = tostring(proto)	
			for i = s:len()+1,2,1 do
				s = "0"..s
			end
			return s
		end

		return setmetatable(tbl, {
			__tostring = function(t)
				print(utils.stripMac(tbl.src))
				return string.format(
					"%s%s%s%s",
					utils.stripMac(tbl.src),
					utils.stripMac(tbl.dst),
					makeProto(tbl.proto),
					tostring(tbl.msg)
				)
			end
		})
	elseif type(args) == "string" then
		print("placeholder")
	else
		error("Invalid argument, must be string or table", 0)
	end
end

pkt = net.newPacket{
	src="de:ad:be:ef:b0:0b",
	dst="11:22:33:44:55:66",
	proto=IP_PROTO,
	msg="test"
}

print(tostring(pkt))

-- Open function for an interface
local function ifaceOpen(self)
	-- Open ip_port to send messages on
	modem = peripheral.wrap(self.side)
	modem.open(IP_PORT)
end
--
-- Open function for an interface
local function ifaceClose(self)
	-- Open IP_PORT to send messages on
	modem = peripheral.wrap(self.side)
	modem.close(IP_PORT)
end


-- Create a new interface object
function net.newIface(side, mac, ip, netmask)
	local iface = {
		side = side or "",
		mac = mac or utils.generateMac(),
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
			-- Make a random address
			table.insert(ifaces, net.newIface(side))
		end
	end
	
	-- Save the interfaces to a file
	f = fs.open(IFACE_FILE, "w")
	f.write(serial.serialize(ifaces))
	f.close()

	return ifaces
end

function net.lsend(iface, pkt)
	local modem = peripheral.wrap(iface.side)
	modem.transmit(IP_PORT, IP_PORT, tostring(pkt))
end
iface = net.interfaces()[1]
net.lsend(iface, "test")