local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts

-- Imports
local get_cart_data = mod.get_cart_data
local MAX_TRAIN_LENGTH = mod.MAX_TRAIN_LENGTH

-- Follow .behind to the back end of a train
local function find_back(start)
	while start.behind do
		local nxt = get_cart_data(start.behind)
		if not nxt then return start end
		start = nxt
	end
	return start
end

-- Iterate across all the cars in a train
local function train_cars(anchor)
	local back = find_back(anchor._staticdata)
	local limit = MAX_TRAIN_LENGTH
	return function()
		if not back or limit <= 0 then return end
		limit = limit - 1

		local ret = back
		if back.ahead then
			back = get_cart_data(back.ahead)
		else
			back = nil
		end
		return ret
	end
end
function mod.train_length(cart)
	local count = 0
	for cart in train_cars(cart) do
		count = count + 1
	end
	return count
end

function mod.is_in_same_train(anchor, other)
	for cart in train_cars(anchor) do
		if cart.uuid == other.uuid then return true end
	end
	return false
end

function mod.distance_between_cars(car1, car2)
	if not car1.connected_at then return nil end
	if not car2.connected_at then return nil end

	if not car1.dir then car1.dir = vector.zero() end
	if not car2.dir then car2.dir = vector.zero() end

	local pos1 = vector.add(car1.connected_at, vector.multiply(car1.dir, car1.distance))
	local pos2 = vector.add(car2.connected_at, vector.multiply(car2.dir, car2.distance))

	return vector.distance(pos1, pos2)
end
local distance_between_cars = mod.distance_between_cars

function mod.update_train(cart)
	local staticdata = cart._staticdata

	-- Only update from the back
	if staticdata.behind or not staticdata.ahead then return end
	print("\nUpdating train")

	-- Do no special processing if the cart is not part of a train
	if not staticdata.ahead and not staticdata.behind then return end

	-- Calculate the maximum velocity of all train cars
	local velocity = 0
	local count = 0
	for cart in train_cars(cart) do
		velocity = velocity + (cart.velocity or 0)
		count = count + 1
	end
	velocity = velocity / count
	print("Using velocity "..tostring(velocity))

	-- Set the entire train to the average velocity
	local behind = nil
	for c in train_cars(cart) do
		local e = 0
		local separation
		local cart_velocity = velocity
		if behind then
			separation = distance_between_cars(behind, c)
			local e = 0
			if separation > 1.6 then
				cart_velocity = velocity * 0.9
			elseif separation < 1.15 then
				cart_velocity = velocity * 1.1
			end
		end
		print(tostring(c.behind).."->"..c.uuid.."->"..tostring(c.ahead).."("..tostring(separation)..")  setting cart #"..
			c.uuid.." velocity from "..tostring(c.velocity).." to "..tostring(cart_velocity))
		c.velocity = cart_velocity

		behind = c
	end
end

function mod.link_cart_ahead(cart, cart_ahead)
	local staticdata = cart._staticdata
	local ca_staticdata = cart_ahead._staticdata

	minetest.log("action","Linking cart #"..staticdata.uuid.." to cart #"..ca_staticdata.uuid)

	staticdata.ahead = ca_staticdata.uuid
	ca_staticdata.behind = staticdata.uuid
end
