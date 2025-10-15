local modname = minetest.get_current_modname()
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

local function detonate_tnt_minecart(self)
	local pos = self.object:get_pos()
	mcl_explosions.explode(pos, 6, { drop_chance = 1.0}, core.get_player_by_name(self._owner or ""), self.object)
	self.object:remove()
end

local function activate_tnt_minecart(self, timer, clicker)
	if self._boomtimer then
		return
	end
	if timer then
		self._boomtimer = timer
	else
		self._boomtimer = tnt.BOOMTIMER
	end
	self.object:set_properties({
		textures = {
			"mcl_tnt_blink.png",
			"mcl_tnt_blink.png",
			"mcl_tnt_blink.png",
			"mcl_tnt_blink.png",
			"mcl_tnt_blink.png",
			"mcl_tnt_blink.png",
			"mcl_minecarts_minecart.png",
		},
		glow = 15,
	})
	self._blinktimer = tnt.BLINKTIMER
	if clicker then
		self._owner = clicker:get_player_name()
	end
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
			activate_tnt_minecart(self, nil, clicker)
		end
	end,
	on_activate_by_rail = activate_tnt_minecart,
	creative = true,
	_mcl_minecarts_on_step = function(self, dtime)
		-- Impacts reduce the speed greatly. Use this to trigger explosions
		local current_speed = vector.length(self.object:get_velocity())
		if current_speed < (self._old_speed or 0) - 6 then
			detonate_tnt_minecart(self)
		end
		self._old_speed = current_speed

		if self._boomtimer then
			-- Explode
			self._boomtimer = self._boomtimer - dtime
			if self._boomtimer <= 0 then
				detonate_tnt_minecart(self)
				return
			else
				local pos = mod.get_cart_position(self._staticdata) or self.object:get_pos()
				if pos then
					tnt.smoke_step(pos)
				end
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
