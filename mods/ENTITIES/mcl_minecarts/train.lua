local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts

-- Imports
local get_cart_data = mod.get_cart_data

local function find_back(start)
	while start.behind do
		local nxt = get_cart_data(start.behind)
		if not nxt then return start end
		start = nxt
	end
	return start
end

local function train_cars(anchor)
	local back = find_back(anchor._staticdata)
	return function()
		if not back then return end

		local ret = back
		if back.ahead then
			back = get_cart_data(back.ahead)
		else
			back = nil
		end
		return ret
	end
end

function mod.update_train(cart)
	local sum_velocity = 0
	local count = 0
	for cart in train_cars(cart) do
		count = count + 1
		sum_velocity = sum_velocity + (cart.velocity or 0)
	end
	local avg_velocity = sum_velocity / count
	if count == 0 then return end

	print("Using velocity "..tostring(avg_velocity))

	-- Set the entire train to the average velocity
	for c in train_cars(cart) do
		print(tostring(c.behind).."->"..c.uuid.."->"..tostring(c.ahead).."  setting cart #"..c.uuid.." velocity to "..tostring(avg_velocity))
		c.velocity = avg_velocity
	end
end

function mod.train_length(cart)
	local count = 0
	for cart in train_cars(cart) do
		count = count + 1
	end
	return count
end
function mod.link_cart_ahead(cart, cart_ahead)
	local staticdata = cart._staticdata
	local ca_staticdata = cart_ahead._staticdata

	minetest.log("action","Linking cart #"..staticdata.uuid.." to cart #"..ca_staticdata.uuid)

	staticdata.ahead = ca_staticdata.uuid
	ca_staticdata.behind = staticdata.uuid
end
function mod.is_in_same_train(anchor, other)
	for cart in train_cars(anchor) do
		if cart.uuid == other.uuid then return true end
	end
	return false
end
