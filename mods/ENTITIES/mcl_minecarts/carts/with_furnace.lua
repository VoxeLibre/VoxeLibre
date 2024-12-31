local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local FURNACE_CART_SPEED = tonumber(minetest.settings:get("mcl_minecarts_furnace_speed")) or 4

-- Minecart with Furnace
mcl_minecarts.register_minecart({
	itemstring = "mcl_minecarts:furnace_minecart",
	craft = {
		output = "mcl_minecarts:furnace_minecart",
		recipe = {
			{"mcl_furnaces:furnace"},
			{"mcl_minecarts:minecart"},
		},
	},
	entity_id = "mcl_minecarts:furnace_minecart",
	description = S("Minecart with Furnace"),
	tt_help = nil,
	longdesc = S("A minecart with furnace is a vehicle that travels on rails. It can propel itself with fuel."),
	usagehelp = S("Place it on rails. If you give it some coal, the furnace will start burning for a long time and the minecart will be able to move itself. Punch it to get it moving.") .. "\n" ..
		S("To obtain the minecart and furnace, punch them while holding down the sneak key."),

	initial_properties = {
		mesh = "mcl_minecarts_minecart_block.b3d",
		textures = {
			"default_furnace_top.png",
			"default_furnace_top.png",
			"default_furnace_front.png",
			"default_furnace_side.png",
			"default_furnace_side.png",
			"default_furnace_side.png",
			"mcl_minecarts_minecart.png",
		},
	},
	icon = "mcl_minecarts_minecart_furnace.png",
	drop = {"mcl_minecarts:minecart", "mcl_furnaces:furnace"},
	on_rightclick = function(self, clicker)
		local staticdata = self._staticdata

		-- Feed furnace with coal
		if not clicker or not clicker:is_player() then
			return
		end
		local held = clicker:get_wielded_item()
		if minetest.get_item_group(held:get_name(), "coal") == 1 then
			staticdata.fueltime = (staticdata.fueltime or 0) + 180

			-- Trucate to 27 minutes (9 uses)
			if staticdata.fueltime > 27*60 then
				staticdata.fuel_time = 27*60
			end

			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				held:take_item()
				local index = clicker:get_wield_index()
				local inv = clicker:get_inventory()
				inv:set_stack("main", index, held)
			end
			self.object:set_properties({textures =
			{
				"default_furnace_top.png",
				"default_furnace_top.png",
				"default_furnace_front_active.png",
				"default_furnace_side.png",
				"default_furnace_side.png",
				"default_furnace_side.png",
				"mcl_minecarts_minecart.png",
			}})
		end
	end,
	on_activate_by_rail = nil,
	creative = true,
	_mcl_minecarts_on_step = function(self, dtime)
		local staticdata = self._staticdata

		-- Update furnace stuff
		if (staticdata.fueltime or 0) > 0 then
			for car in mcl_minecarts.train_cars(staticdata) do
				if car.velocity < FURNACE_CART_SPEED - 0.1 then -- Slightly less to allow train cars to maintain spacing
					car.velocity = FURNACE_CART_SPEED
				end
			end

			staticdata.fueltime = (staticdata.fueltime or dtime) - dtime
			if staticdata.fueltime <= 0 then
				self.object:set_properties({textures =
					{
					"default_furnace_top.png",
					"default_furnace_top.png",
					"default_furnace_front.png",
					"default_furnace_side.png",
					"default_furnace_side.png",
					"default_furnace_side.png",
					"mcl_minecarts_minecart.png",
				}})
				staticdata.fueltime = 0
			end
		end
	end,
})
