local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

-- Minecart with TNT
local function activate_tnt_minecart(self, timer)
	if self._boomtimer then
		return
	end
	if timer then
		self._boomtimer = timer
	else
		self._boomtimer = tnt.BOOMTIMER
	end
	self.object:set_properties({textures = {
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_tnt_blink.png",
		"mcl_minecarts_minecart.png",
	}})
	self._blinktimer = tnt.BLINKTIMER
	minetest.sound_play("tnt_ignite", {pos = self.object:get_pos(), gain = 1.0, max_hear_distance = 15}, true)
end
mod.register_minecart({
	itemstring = "mcl_minecarts:tnt_minecart",
	craft = {
		output = "mcl_minecarts:tnt_minecart",
		recipe = {
			{"mcl_tnt:tnt"},
			{"mcl_minecarts:minecart"},
		},
	},
	entity_id = "mcl_minecarts:tnt_minecart",
	description = S("Minecart with TNT"),
	tt_help = S("Vehicle for fast travel on rails").."\n"..S("Can be ignited by tools or powered activator rail"),
	longdesc = S("A minecart with TNT is an explosive vehicle that travels on rail."),
	usagehelp = S("Place it on rails. Punch it to move it. The TNT is ignited with a flint and steel or when the minecart is on an powered activator rail.") .. "\n" ..
		S("To obtain the minecart and TNT, punch them while holding down the sneak key. You can't do this if the TNT was ignited."),
	initial_properties = {
		mesh = "mcl_minecarts_minecart_block.b3d",
		textures = {
			"default_tnt_top.png",
			"default_tnt_bottom.png",
			"default_tnt_side.png",
			"default_tnt_side.png",
			"default_tnt_side.png",
			"default_tnt_side.png",
			"mcl_minecarts_minecart.png",
		},
	},
	icon = "mcl_minecarts_minecart_tnt.png",
	drop = {"mcl_minecarts:minecart", "mcl_tnt:tnt"},
	on_rightclick = function(self, clicker)
		-- Ingite
		if not clicker or not clicker:is_player() then
			return
		end
		if self._boomtimer then
			return
		end
		local held = clicker:get_wielded_item()
		if held:get_name() == "mcl_fire:flint_and_steel" then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				held:add_wear(65535/65) -- 65 uses
				local index = clicker:get_wield_index()
				local inv = clicker:get_inventory()
				inv:set_stack("main", index, held)
			end
			activate_tnt_minecart(self)
		end
	end,
	on_activate_by_rail = activate_tnt_minecart,
	creative = true,
	_mcl_minecarts_on_step = function(self, dtime)
		-- Update TNT stuff
		if self._boomtimer then
			-- Explode
			self._boomtimer = self._boomtimer - dtime
			local pos = self.object:get_pos()
			if self._boomtimer <= 0 then
				self.object:remove()
				mcl_explosions.explode(pos, 6, { drop_chance = 1.0 })
				return
			else
				tnt.smoke_step(pos)
			end
		end
		if self._blinktimer then
			self._blinktimer = self._blinktimer - dtime
			if self._blinktimer <= 0 then
				self._blink = not self._blink
				if self._blink then
					self.object:set_properties({textures =
					{
					"default_tnt_top.png",
					"default_tnt_bottom.png",
					"default_tnt_side.png",
					"default_tnt_side.png",
					"default_tnt_side.png",
					"default_tnt_side.png",
					"mcl_minecarts_minecart.png",
					}})
				else
					self.object:set_properties({textures =
					{
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_tnt_blink.png",
					"mcl_minecarts_minecart.png",
					}})
				end
				self._blinktimer = tnt.BLINKTIMER
			end
		end
	end,
})
