local modname = minetest.get_current_modname()
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

local LOGGING_ON = {minetest.settings:get_bool("mcl_logging_minecarts", false)}
local function mcl_log(message)
	if LOGGING_ON[1] then
		mcl_util.mcl_log(message, "[Minecarts]", true)
	end
end

local function hopper_take_item(self, dtime)
	local pos = self.object:get_pos()
	if not pos then return end

	if not self or self.name ~= "mcl_minecarts:hopper_minecart" then return end

	if mcl_util.check_dtime_timer(self, dtime, "hoppermc_take", 0.15) then
		--minetest.log("The check timer was triggered: " .. dump(pos) .. ", name:" .. self.name)
	else
		--minetest.log("The check timer was not triggered")
		return
	end


	local above_pos = vector.offset(pos, 0, 0.9, 0)
	local objs = minetest.get_objects_inside_radius(above_pos, 1.25)

	if objs then
		mcl_log("there is an itemstring. Number of objs: ".. #objs)

		for _, v in pairs(objs) do
			local ent = v:get_luaentity()

			if ent and not ent._removed and ent.itemstring and ent.itemstring ~= "" then
				local taken_items = false

				mcl_log("ent.name: " .. tostring(ent.name))
				mcl_log("ent pos: " .. tostring(ent.object:get_pos()))

				local inv = mcl_entity_invs.load_inv(self, 5)
				if not inv then return false end

				local current_itemstack = ItemStack(ent.itemstring)

				mcl_log("inv. size: " .. self._inv_size)
				if inv:room_for_item("main", current_itemstack) then
					mcl_log("Room")
					inv:add_item("main", current_itemstack)
					ent.object:get_luaentity().itemstring = ""
					ent.object:remove()
					taken_items = true
				else
					mcl_log("no Room")
				end

				if not taken_items then
					local items_remaining = current_itemstack:get_count()

					-- This will take part of a floating item stack if no slot can hold the full amount
					for i = 1, self._inv_size, 1 do
						local stack = inv:get_stack("main", i)

						mcl_log("i: " .. tostring(i))
						mcl_log("Items remaining: " .. items_remaining)
						mcl_log("Name: " .. tostring(stack:get_name()))

						if current_itemstack:get_name() == stack:get_name() then
							mcl_log("We have a match. Name: " .. tostring(stack:get_name()))

							local room_for = stack:get_stack_max() - stack:get_count()
							mcl_log("Room for: " .. tostring(room_for))

							if room_for == 0 then
								-- Do nothing
								mcl_log("No room")
							elseif room_for < items_remaining then
								mcl_log("We have more items remaining than space")

								items_remaining = items_remaining - room_for
								stack:set_count(stack:get_stack_max())
								inv:set_stack("main", i, stack)
								taken_items = true
							else
								local new_stack_size = stack:get_count() + items_remaining
								stack:set_count(new_stack_size)
								mcl_log("We have more than enough space. Now holds: " .. new_stack_size)

								inv:set_stack("main", i, stack)

								ent.object:get_luaentity().itemstring = ""
								ent.object:remove()

								taken_items = true
								break
							end

							mcl_log("Count: " .. tostring(stack:get_count()))
							mcl_log("stack max: " .. tostring(stack:get_stack_max()))
							--mcl_log("Is it empty: " .. stack:to_string())
						end

						if i == self._inv_size and taken_items then
							mcl_log("We are on last item and still have items left. Set final stack size: " .. items_remaining)
							current_itemstack:set_count(items_remaining)
							--mcl_log("Itemstack2: " .. current_itemstack:to_string())
							ent.itemstring = current_itemstack:to_string()
						end
					end
				end

				--Add in, and delete
				if taken_items then
					mcl_log("Saving")
					mcl_entity_invs.save_inv(ent)
					return taken_items
				else
					mcl_log("No need to save")
				end

			end
		end
	end

	return false
end

-- Minecart with Hopper
mod.register_minecart({
	itemstring = "mcl_minecarts:hopper_minecart",
	craft = {
		output = "mcl_minecarts:hopper_minecart",
		recipe = {
			{"mcl_hoppers:hopper"},
			{"mcl_minecarts:minecart"},
		},
	},
	entity_id = "mcl_minecarts:hopper_minecart",
	description = S("Minecart with Hopper"),
	tt_help = nil,
	longdesc = nil,
	usagehelp = nil,
	initial_properties = {
		mesh = "mcl_minecarts_minecart_hopper.b3d",
		textures = {
			"mcl_hoppers_hopper_inside.png",
			"mcl_minecarts_minecart.png",
			"mcl_hoppers_hopper_outside.png",
			"mcl_hoppers_hopper_top.png",
		},
	},
	icon = "mcl_minecarts_minecart_hopper.png",
	drop = {"mcl_minecarts:minecart", "mcl_hoppers:hopper"},
	groups = { container = 1 },
	on_rightclick = nil,
	on_activate_by_rail = nil,
	_mcl_minecarts_on_enter = function(self, pos, staticdata)
		if (staticdata.hopper_delay or 0) > 0 then
			return
		end

		-- try to pull from containers into our inventory
		if not self then return end
		local inv = mcl_entity_invs.load_inv(self,5)
		local above_pos = vector.offset(pos,0,1,0)
		mcl_util.hopper_pull_to_inventory(inv, 'main', above_pos, pos)

		staticdata.hopper_delay =  (staticdata.hopper_delay or 0) + 0.25
	end,
	_mcl_minecarts_on_step = function(self, dtime)
		hopper_take_item(self, dtime)

		local staticdata = self._staticdata
		local pos = mcl_minecarts.get_cart_position(staticdata) or self.object:get_pos()

		self._mcl_minecarts_on_enter(self, pos, staticdata)
	end,
	creative = true
})
mcl_entity_invs.register_inv("mcl_minecarts:hopper_minecart", S("Hopper Minecart"), 5, false, true)

