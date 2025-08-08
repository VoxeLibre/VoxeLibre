local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local mcl_log = mcl_util.make_mcl_logger("mcl_logging_minecarts", "Minecarts")
local mod = mcl_minecarts

-- Imports
local PASSENGER_ATTACH_POSITION = mod.PASSENGER_ATTACH_POSITION

local function activate_normal_minecart(self)
	mod.detach_driver(self)

	-- Detach passenger
	if self._passenger then
		local mob = self._passenger.object
		mob:set_detach()
		self._passenger = nil
	end
end

function mod.attach_driver(cart, player)
	local staticdata = cart._staticdata

	-- Make sure we have a player
	if not player or not player:is_player() then return end

	-- Prevent more than one player getting in the cart
	local player_name = player:get_player_name()
	if cart._driver or player:get_player_control().sneak then return end

	-- Prevent getting into a cart that already has a passenger
	if cart._passenger then return end

	-- Update cart information
	cart._driver = player_name
	cart._start_pos = cart.object:get_pos()

	-- Keep track of player attachment
	local player_meta = mcl_playerinfo.get_mod_meta(player_name, modname)
	player_meta.attached_to = cart._uuid
	staticdata.last_player = player_name

	-- Update player information
	mcl_player.player_attached[player_name] = true
	mcl_log(player_name.." entered minecart #"..tostring(staticdata.uuid).." at "..tostring(cart._start_pos))

	-- Attach the player object to the minecart
	player:set_attach(cart.object, "", vector.new(1,-1.75,-2), vector.new(0,0,0))
	minetest.after(0.2, function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			mcl_player.player_set_animation(player, "sit" , 30)
			player:set_eye_offset(vector.new(0,-5.5,0), vector.new(0,-4,0))
			mcl_title.set(player, "actionbar", {text=S("Sneak to dismount"), color="white", stay=60})
		end
	end, player_name)
end

mod.register_minecart({
	itemstring = "mcl_minecarts:minecart",
	craft = {
		output = "mcl_minecarts:minecart",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		},
	},
	entity_id = "mcl_minecarts:minecart",
	description = S("Minecart"),
	tt_helop = S("Vehicle for fast travel on rails"),
	long_descp = S("Minecarts can be used for a quick transportion on rails.") .. "\n" ..
		S("Minecarts only ride on rails and always follow the tracks. At a T-junction with no straight way ahead, they turn left. The speed is affected by the rail type."),
		S("You can place the minecart on rails. Right-click it to enter it. Punch it to get it moving.") .. "\n" ..
		S("To obtain the minecart, punch it while holding down the sneak key.") .. "\n" ..
		S("If it moves over a powered activator rail, you'll get ejected."),
	initial_properties = {
		mesh = "mcl_minecarts_minecart.b3d",
		textures = {"mcl_minecarts_minecart.png"},
	},
	icon = "mcl_minecarts_minecart_normal.png",
	drop = {"mcl_minecarts:minecart"},
	on_rightclick = mod.attach_driver,
	on_activate_by_rail = activate_normal_minecart,
	_mcl_minecarts_on_step = function(self, dtime)
		-- Grab mob
		if math.random(1,20) > 15 and not (self._passenger or self._driver) then
			local mobsnear = minetest.get_objects_inside_radius(self.object:get_pos(), 1.3)
			for n=1, #mobsnear do
				local mob = mobsnear[n]
				if mob and not mob:get_attach() then
					local entity = mob:get_luaentity()
					if entity and entity.is_mob then
						self._passenger = entity
						mob:set_attach(self.object, "", PASSENGER_ATTACH_POSITION, vector.zero())
						break
					end
				end
			end
		elseif self._passenger then
			local passenger_pos = self._passenger.object:get_pos()
			if not passenger_pos then
				self._passenger = nil
			end
		end
	end
})
