local S = core.get_translator(core.get_current_modname())

mcl_campfires = {}

local COOK_TIME = 30 -- Time it takes to cook food on a campfire.
local CAMPFIRE_SPOTS = {
	vector.new(-0.25, -0.03125, -0.25),
	vector.new(0.25, -0.03125, -0.25),
	vector.new(0.25, -0.03125, 0.25),
	vector.new(-0.25, -0.03125, 0.25),
}

--- @class mcl_campfires.CampfireRef
---
--- @field pos  Vector
--- @field node core.Node
--- @field meta core.MetaDataRef
--- @field inv  core.InvRef
mcl_campfires.CampfireRef = {}
mcl_campfires.CampfireRef.__index = mcl_campfires.CampfireRef

--- Creates a new campfire reference.
---
--- @param pos Vector
--- @return mcl_campfires.CampfireRef
function mcl_campfires.CampfireRef.new(pos)
	local meta = core.get_meta(pos)
	local node = core.get_node(pos)
	local inv  = meta:get_inventory()
	local o    = {
		pos  = pos,
		node = node,
		meta = meta,
		inv  = inv,
	}
	o = setmetatable(o, mcl_campfires.CampfireRef)
	return o
end

--- Finds the first empty space in a campfire inventory.
--- If there are no empty spaces, returns nil.
---
--- @private
--- @return integer?
--- @nodiscard
function mcl_campfires.CampfireRef:find_empty_spot()
	for i = 1, 4 do
		local stack = self.inv:get_stack("main", i)
		if not stack or stack:is_empty() then
			return i
		end
	end
end

--- Gets the X, Y, Z coordinates of a food item.
---
--- @private
--- @param food_index integer
--- @return Vector? pos
function mcl_campfires.CampfireRef:get_food_pos(food_index)
	local foodv = {}
	for i, axis in pairs({ "x", "y", "z" }) do
		local field = string.format("food_%s_%d", axis, food_index)
		local val   = self.meta:get_string(field)
		local n     = tonumber(val)
		if not n then
			core.log("warning", string.format("field %q has no number value, has: %q", field, val))
			return nil
		end
		foodv[i] = n
	end
	return vector.new(foodv[1], foodv[2], foodv[3])
end

--- Returns the food entity at the index, or nil if it doesn't exist.
---
--- @private
--- @param index integer
--- @return core.LuaEntityRef?
function mcl_campfires.CampfireRef:get_food_entity(index)
	local fpos = self:get_food_pos(index)
	if not fpos then
		return
	end
	local entities = core.get_objects_inside_radius(fpos, 0.1)
	if not entities then
		return
	end
	for _, e in ipairs(entities) do
		if not e then
			goto continue
		end
		local le = e:get_luaentity()
		if not le then
			goto continue
		end
		if le.name == "mcl_campfires:food_entity" then
			--- @cast e core.LuaEntityRef
			return e
		end
		::continue::
	end
end

--- Find the `i`th item at a campfire at `pos`.
---
--- @private
--- @param i integer Item index
--- @return core.ItemStack?    item_stack
--- @return core.LuaEntityRef? entity
--- @return integer?           cook_time
--- @nodiscard
function mcl_campfires.CampfireRef:find_item(i)
	local st = self.inv:get_stack("main", i)
	if not st or st:is_empty() then
		return
	end
	local ent = self:get_food_entity(i)
	if not ent then
		core.log("warning",
			"campfire entity for index " .. tostring(i)
			.. " not found at position " .. tostring(self.pos))
	end
	return st, ent, self.meta:get_int("cooktime_" .. tostring(i))
end

---
--- @private
--- @param index integer
function mcl_campfires.CampfireRef:drop_cooked_item(index)
	local ent = self:get_food_entity(index)
	if ent then
		ent:remove()
	end

	local item   = self.inv:get_stack("main", index)
	local cooked = core.get_craft_result({
		method = "cooking",
		width  = 1,
		items  = { item }
	})
	if not cooked then
		return
	end

	self.meta:set_string("food_x_" .. tostring(index), "")
	self.meta:set_string("food_y_" .. tostring(index), "")
	self.meta:set_string("food_z_" .. tostring(index), "")

	core.add_item(self.pos, cooked.item)

	local dir = vector.divide(
		core.facedir_to_dir(core.get_node(self.pos).param2),
		-1.95
	)
	mcl_experience.throw_xp(vector.add(self.pos, dir), 1)

	self.inv:set_stack("main", index, "")
end

---
--- @private
--- @param entity  core.LuaEntityRef
--- @param item_id string
function mcl_campfires.CampfireRef:update_food_entity_visual(entity, item_id)
	local id = string.sub(item_id, 14)
	local wield_image = string.format("mcl_mobitems_%s_raw.png", id)
	local props = {
		wield_item  = item_id,
		wield_image = wield_image,
	}
	entity:set_properties(props)
end

--- @param stack core.ItemStack
--- @return boolean cookable
function mcl_campfires.CampfireRef:can_cook(stack)
	local in_group = core.get_item_group(stack:get_name(), "campfire_cookable") ~= 0
	if not in_group then
		return false
	end
	local output, _ = core.get_craft_result({
		method = "cooking",
		width  = 1,
		items  = { stack }
	})
	return not output.item:is_empty()
end

--- @param object core.ObjectRef
local function is_creative(object)
	return core.is_creative_enabled(object:get_player_name())
end

---
--- @param object    core.ObjectRef
--- @param itemstack core.ItemStack
--- @return core.ItemStack  stack Leftover itemstack
--- @return string?         error_message
function mcl_campfires.CampfireRef:take_item(object, itemstack)
	if not self:can_cook(itemstack) then
		return itemstack
	end
	local spot = self:find_empty_spot()
	if not spot then
		return itemstack
	end
	local epos = self.pos + CAMPFIRE_SPOTS[spot]
	local e = core.add_entity(epos, "mcl_campfires:food_entity")
	if not e then
		return ItemStack(), "failed to spawn entity"
	end
	self.inv:set_stack("main", spot, itemstack)
	self.meta:set_int("cooktime_" .. tostring(spot), COOK_TIME)
	self.meta:set_string("food_x_" .. tostring(spot), tostring(e:get_pos().x))
	self.meta:set_string("food_y_" .. tostring(spot), tostring(e:get_pos().y))
	self.meta:set_string("food_z_" .. tostring(spot), tostring(e:get_pos().z))
	e:set_properties({
		wield_item  = self.inv:get_stack("main", spot):get_name(),
		wield_image =
			"mcl_mobitems_" ..
			string.sub(self.inv:get_stack("main", spot):get_name(), 14) ..
			"_raw.png"
	})
	core.get_node_timer(self.pos):start(1)
	if not is_creative(object) then
		itemstack = itemstack:take_item(1)
	end
	return itemstack
end

---
--- @private
--- @param index integer
--- @return boolean empty
function mcl_campfires.CampfireRef:cook_item(index)
	local stack, entity, cook_time = self:find_item(index)
	if not stack or stack:is_empty() then
		return true
	end
	if entity then
		self:update_food_entity_visual(entity, stack:get_name())
	end
	if cook_time <= 0 then
		self:drop_cooked_item(index)
		return true
	end
	self.meta:set_int("cooktime_" .. index, cook_time - 1)
	return false
end

--- Cooks items in a campfire. Should be called on timer.
---
--- @return boolean continue_timer
--- @nodiscard
function mcl_campfires.CampfireRef:cook_items()
	local empty_count = 0
	for i = 1, 4 do
		local empty = self:cook_item(i)
		if empty then
			empty_count = empty_count + 1
		end
	end
	return empty_count ~= 4
end

function mcl_campfires.CampfireRef:update_all_entity_visuals()
	for i = 1, 4 do
		local stack, entity = self:find_item(i)
		if not stack or not entity then
			goto continue
		end
		self:update_food_entity_visual(entity, stack:get_name())
		::continue::
	end
end

--- @param pos Vector
--- @param digger core.ObjectRef
--- @param drops core.ItemStack[]
--- @param nodename core.ItemString
local function do_campfire_drop(pos, digger, drops, nodename)
	if is_creative(digger) then
		local inv = digger:get_inventory()
		if inv
			and inv:room_for_item("main", nodename)
			and not inv:contains_item("main", nodename)
		then
			inv:add_item("main", nodename)
		end
		return
	end
	local wielded_item = digger:get_wielded_item()
	local has_silk_touch = mcl_enchanting.has_enchantment(wielded_item, "silk_touch")
	if has_silk_touch then
		core.add_item(pos, nodename)
	else
		core.add_item(pos, drops)
	end
end

---@param pos Vector
---@param node core.Node
---@param oldmeta core.NodeMetaRef?
local function do_campfire_drop_items(pos, node, oldmeta)
	local meta = core.get_meta(pos)
	mcl_util.drop_items_from_meta_container("main")(pos, node, oldmeta)
	local entities = core.get_objects_inside_radius(pos, 0.5)
	if not entities then
		return
	end
	for _, food_entity in ipairs(entities) do
		if not food_entity then
			goto continue
		end
		if food_entity:get_luaentity().name ~= "mcl_campfires:food_entity" then
			goto continue
		end
		food_entity:remove()
		for i = 1, 4 do
			meta:set_string("food_x_" .. tostring(i), "")
			meta:set_string("food_y_" .. tostring(i), "")
			meta:set_string("food_z_" .. tostring(i), "")
		end
		::continue::
	end
end

--- @param pos Vector
local function on_blast(pos)
	local node = core.get_node(pos)
	do_campfire_drop_items(pos, node)
	core.remove_node(pos)
end

function mcl_campfires.light_campfire(pos)
	local campfire = core.get_node(pos)
	local name = campfire.name .. "_lit"
	core.set_node(pos, { name = name, param2 = campfire.param2 })
end

--- on_rightclick function to take items that are cookable in a campfire,
--- and put them in the campfire inventory
---
--- @type core.NodeDef.OnRightClickFunc
function mcl_campfires.take_item(pos, _, clicker, itemstack)
	local campfire = mcl_campfires.CampfireRef.new(pos)
	local stack, err = campfire:take_item(clicker, itemstack)
	if err then
		core.log("error", "mcl_campfires.take_item error: " .. err)
	end
	return stack or itemstack
end

--- @type core.NodeDef.OnTimerFunc
function mcl_campfires.cook_items(pos)
	return mcl_campfires.CampfireRef.new(pos):cook_items()
end

--- @param pos Vector
local function destroy_particle_spawner(pos)
	local meta = core.get_meta(pos)
	local part_spawn_id = meta:get_int("particle_spawner_id")
	if part_spawn_id and part_spawn_id > 0 then
		core.delete_particlespawner(part_spawn_id)
	end
end

--- @param pos Vector
--- @param constructor boolean?
local function create_smoke_partspawner(pos, constructor)
	if not constructor then
		destroy_particle_spawner(pos)
	end

	local node_below = vector.offset(pos, 0, -1, 0)
	local haybale = false
	if core.get_node(node_below).name == "mcl_farming:hay_block" then
		haybale = true
	end

	local smoke_timer = 2.4
	if haybale then
		smoke_timer = 4
	end

	local spawner_id = core.add_particlespawner({
		amount = 3,
		time = 0,
		minpos = vector.add(pos, vector.new(-0.25, 0, -0.25)),
		maxpos = vector.add(pos, vector.new(0.25, 0, 0.25)),
		minvel = vector.new(-0.2, 0.5, -0.2),
		maxvel = vector.new(0.2, 1, 0.2),
		minacc = vector.new(0, 0.5, 0),
		maxacc = vector.new(0, 0.5, 0),
		minexptime = smoke_timer,
		maxexptime = smoke_timer * 2,
		minsize = 6,
		maxsize = 8,
		collisiondetection = true,
		vertical = false,
		texture = "mcl_campfires_particle_1.png",
		texpool = {
			"mcl_campfires_particle_1.png",
			{ name = "mcl_campfires_particle_1.png",  fade = "out" },
			{ name = "mcl_campfires_particle_2.png",  fade = "out" },
			{ name = "mcl_campfires_particle_3.png",  fade = "out" },
			{ name = "mcl_campfires_particle_4.png",  fade = "out" },
			{ name = "mcl_campfires_particle_5.png",  fade = "out" },
			{ name = "mcl_campfires_particle_6.png",  fade = "out" },
			{ name = "mcl_campfires_particle_7.png",  fade = "out" },
			{ name = "mcl_campfires_particle_8.png",  fade = "out" },
			{ name = "mcl_campfires_particle_9.png",  fade = "out" },
			{ name = "mcl_campfires_particle_10.png", fade = "out" },
			{ name = "mcl_campfires_particle_11.png", fade = "out" },
			{ name = "mcl_campfires_particle_11.png", fade = "out" },
			{ name = "mcl_campfires_particle_12.png", fade = "out" },
		}
	})
	if spawner_id == -1 then
		core.log("error", "failed to create particle spawner")
		return
	end
	local meta = core.get_meta(pos)
	meta:set_int("particle_spawner_id", spawner_id)
end

---@param name string
---@param def core.NodeDef
function mcl_campfires.register_campfire(name, def)
	-- Define Campfire
	core.register_node(name, {
		description = def.description,
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S(
			"Campfires have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = def.inv_texture,
		wield_image = def.inv_texture,
		drawtype = "mesh",
		mesh = "mcl_campfires_campfire.obj",
		tiles = { { name = "mcl_campfires_log.png" }, },
		use_texture_alpha = "clip",
		groups = { handy = 1, axey = 1, material_wood = 1, not_in_creative_inventory = 1, campfire = 1, },
		paramtype = "light",
		paramtype2 = "4dir",
		_on_ignite = function(_ --[[player]], node)
			mcl_campfires.light_campfire(node.under)
			return true
		end,
		drop = "",
		sounds = mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = 'fixed',
			fixed = { -.5, -.5, -.5, .5, -.05, .5 }, --left, bottom, front, right, top
		},
		collision_box = {
			type = 'fixed',
			fixed = { -.5, -.5, -.5, .5, -.05, .5 },
		},
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_vl_projectile = {
			on_collide = function(projectile, pos, _, _)
				-- Ignite Campfires
				if mcl_burning.is_burning(projectile) then
					mcl_campfires.light_campfire(pos)
				end
			end
		},
		after_dig_node = function(pos, _, _, digger)
			do_campfire_drop(pos, digger, def.drops, name .. "_lit")
		end,
	})

	--Define Lit Campfire
	core.register_node(name .. "_lit", {
		description = def.description,
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S(
		"Campfires have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = def.inv_texture,
		wield_image = def.inv_texture,
		drawtype = "mesh",
		mesh = "mcl_campfires_campfire.obj",
		tiles = {
			{
				name = def.fire_texture,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 16,
					length = 0.8
				}
			}
		},
		overlay_tiles = {
			{
				name = def.lit_logs_texture,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 16,
					length = 2.0,
				}
			},
		},
		use_texture_alpha = "clip",
		groups = { handy = 1, axey = 1, material_wood = 1, lit_campfire = 1 },
		paramtype = "light",
		paramtype2 = "4dir",
		on_construct = function(pos)
			local meta = core.get_meta(pos)
			local inv  = meta:get_inventory()
			inv:set_size("main", 4)
			create_smoke_partspawner(pos, true)
		end,
		on_destruct = function(pos)
			destroy_particle_spawner(pos)
		end,
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			local meta = core.get_meta(pos)
			local inv  = meta:get_inventory()
			if not inv then
				inv:set_size("main", 4)
			end

			if core.get_item_group(itemstack:get_name(), "shovel") ~= 0 then
				local protected = mcl_util.check_position_protection(pos, player)
				if not protected then
					if not core.is_creative_enabled(player:get_player_name()) then
						-- Add wear (as if digging a shovely node)
						local toolname = itemstack:get_name()
						local wear = mcl_autogroup.get_wear(toolname, "shovely")
						if wear then
							itemstack:add_wear(wear)
							tt.reload_itemstack_description(itemstack) -- update tooltip
						end
					end
					node.name = name
					core.set_node(pos, node)
					core.sound_play("fire_extinguish_flame", { pos = pos, gain = 0.25, max_hear_distance = 16 }, true)
				end
			elseif core.get_item_group(itemstack:get_name(), "campfire_cookable") ~= 0 then
				mcl_campfires.take_item(pos, node, player, itemstack)
			else
				if not pointed_thing then
					return itemstack
				end
				core.item_place_node(itemstack, player, pointed_thing)
			end
		end,
		on_timer = mcl_campfires.cook_items,
		drop = "",
		light_source = def.lightlevel,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -.5, -.5, -.5, .5, -.05, .5 }, --left, bottom, front, right, top
		},
		collision_box = {
			type = "fixed",
			fixed = { -.5, -.5, -.5, .5, -.05, .5 },
		},
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		damage_per_second = def.damage, -- FIXME: Once entity burning is fixed, this needs to be removed.
		on_blast = on_blast,
		after_dig_node = function(pos, node, oldmeta, digger)
			do_campfire_drop_items(pos, node, oldmeta)
			do_campfire_drop(pos, digger, def.drops, name .. "_lit")
		end,
		_mcl_campfires_smothered_form = name,
	})
end

--- @param p core.PlayerRef
--- @return boolean
local function should_campfire_burn_player(p)
	local is_sneaking = p:get_player_control().sneak
	if is_sneaking then
		return false
	end
	if core.global_exists("mcl_enchanting") then
		local armor_feet       = p:get_inventory():get_stack("armor", 5)
		local has_frost_walker = mcl_enchanting.has_enchantment(armor_feet, "frost_walker")
		if has_frost_walker then
			return false
		end
	end
	if core.global_exists("mcl_potions") then
		local has_fire_resistance = mcl_potions.has_effect(p, "fire_resistance")
		if has_fire_resistance then
			return false
		end
	end
	return true
end

--- @param obj core.ObjectRef
local function burn_in_campfire(obj)
	local p = obj:get_pos()
	if not p then
		return
	end
	local n = core.find_node_near(p, 0.4, { "group:lit_campfire" }, true)
	if n then
		mcl_burning.set_on_fire(obj, 5)
	end
end

local etime = 0
core.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then
		return
	end
	etime = 0
	local pls = core.get_connected_players()
	for _, pl in pairs(pls) do
		if should_campfire_burn_player(pl) then
			burn_in_campfire(pl)
		end
	end
	for _, ent in pairs(core.luaentities) do
		if ent.is_mob then
			burn_in_campfire(ent.object) -- FIXME: Mobs don't seem to burn properly anymore.
		end
	end
end)

core.register_lbm({
	label = "Campfire Smoke",
	name = "mcl_campfires:campfire_smoke",
	nodenames = { "group:lit_campfire" },
	run_at_every_load = true,
	action = function(pos, _)
		create_smoke_partspawner(pos)
	end,
})

core.register_lbm({
	label = "Load campfire entity visuals",
	name = "mcl_campfires:entity_load_visuals",
	nodenames = { "group:lit_campfire" },
	run_at_every_load = true,
	action = function(pos)
		local c = mcl_campfires.CampfireRef.new(pos)
		c:update_all_entity_visuals()
	end
})
