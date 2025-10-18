local S = core.get_translator(core.get_current_modname())

mcl_campfires = {}

local COOK_TIME = 30 -- Time it takes to cook food on a campfire.
local CAMPFIRE_SPOTS = {
	vector.new(-0.25, -0.03125, -0.25),
	vector.new(0.25, -0.03125, -0.25),
	vector.new(0.25, -0.03125, 0.25),
	vector.new(-0.25, -0.03125, 0.25),
}


--- @enum mcl_campfires.CampfireKind
local CAMPFIRE_KIND = {
	LIT = 1,
	UNLIT = 2,
	NA = 3
}

local function is_food_entity(e)
	if not e or not e.get_luaentity then
		return false
	end
	local le = e:get_luaentity()
	if not le or type(le) ~= "table" then
		return false
	end
	return le.name == "mcl_campfires:food_entity"
end

--- @param object core.ObjectRef
local function is_creative(object)
	return core.is_creative_enabled(object:get_player_name())
end


--- @param stack core.ItemStack
--- @return boolean
local function is_shovel(stack)
	return core.get_item_group(stack:get_name(), "shovel") ~= 0
end


--- @param stack core.ItemStack
--- @return boolean
local function is_cookable_in_campfire(stack)
	return core.get_item_group(stack:get_name(), "campfire_cookable") ~= 0
end


--- @param pos Vector
--- @return mcl_campfires.CampfireKind
local function get_campfire_kind(pos)
	local node = core.get_node(pos)
	local nodename = node.name
	if core.get_item_group(nodename, "lit_campfire") ~= 0 then
		return CAMPFIRE_KIND.LIT
	elseif core.get_item_group(nodename, "campfire") ~= 0 then
		return CAMPFIRE_KIND.UNLIT
	else
		return CAMPFIRE_KIND.NA
	end
end


--- @class mcl_campfires.CampfireRef
---
--- @field pos Vector
--- @field node core.Node
--- @field nodedef core.NodeDef
--- @field meta core.NodeMetaRef
--- @field inv core.InvRef
--- @field kind mcl_campfires.CampfireKind
local CampfireRef = {}
CampfireRef.__index = CampfireRef


--- Creates a new campfire reference.
---
--- @param pos Vector
--- @return mcl_campfires.CampfireRef
function CampfireRef.new(pos)
	local meta = core.get_meta(pos)
	local node = core.get_node(pos)
	local nodedef = core.registered_nodes[node.name]
	local inv = meta:get_inventory()
	local kind = get_campfire_kind(pos)
	local o = {
		pos = pos,
		node = node,
		nodedef = nodedef,
		meta = meta,
		inv = inv,
		kind = kind,
	}
	o = setmetatable(o, CampfireRef)
	return o
end

--- @private
function CampfireRef:update()
	self.node = core.get_node(self.pos)
	self.nodedef = core.registered_nodes[self.node.name]
	self.meta = core.get_meta(self.pos)
	self.inv = self.meta:get_inventory()
	self.kind = get_campfire_kind(self.pos)
end

--- Finds the first empty space in a campfire inventory.
--- If there are no empty spaces, returns nil.
---
--- @private
--- @return integer?
--- @nodiscard
function CampfireRef:find_empty_index()
	if self.kind ~= CAMPFIRE_KIND.LIT then
		return
	end
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
--- @param index integer Food index
--- @return Vector? pos
function CampfireRef:get_food_pos(index)
	if index < 1 or index > 4 then
		local errm = string.format(
			"mcl_campfires: campfire at pos %q: unexpected food index: %d. "
			.. "expected value between 1 and 4 (inclusive)",
			self.pos, index
		)
		core.log("error", errm)
		return
	end
	return self.pos + CAMPFIRE_SPOTS[index] --[[@as Vector]]
end

--- Returns the food entity at the index, or nil if it doesn't exist.
---
--- @private
--- @param index integer
--- @return core.LuaEntityRef?
function CampfireRef:get_food_entity(index)
	local fpos = self:get_food_pos(index)
	if not fpos then
		return
	end
	local entities = core.get_objects_inside_radius(fpos, 0.1)
	if not entities then
		return
	end
	for _, e in ipairs(entities) do
		if is_food_entity(e) then
			--- @cast e core.LuaEntityRef
			return e
		end
	end
end

--- Find the `i`th item at a campfire at `pos`.
---
--- @private
--- @param i integer Item index
--- @return core.ItemStack? item_stack
--- @return core.LuaEntityRef? entity
--- @return integer? cook_time
--- @nodiscard
function CampfireRef:find_item(i)
	local st = self.inv:get_stack("main", i)
	if not st or st:is_empty() then
		return
	end
	local ent = self:get_food_entity(i)
	if not ent then
		local wmsg = string.format(
			"campfire entity for index %d not found at position %s",
			i, self.pos
		)
		core.log("warning", wmsg)
	end
	local cook_time_field = string.format("cooktime_%d", i)
	local cook_time = self.meta:get_int(cook_time_field)
	return st, ent, cook_time
end

--- @param index integer
--- @param cook boolean? If the item should drop as cooked (default: false)
function CampfireRef:drop_item(index, cook)
	if not cook then
		cook = false
	end
	local item, ent = self:find_item(index)
	if not item then
		return
	end
	if ent then
		ent:remove()
	end

	local drop_item = item
	if cook then
		local cook_result = core.get_craft_result({
			method = "cooking",
			width = 1,
			items = { item }
		})
		if not cook_result then
			local errm = string.format(
				"campfire at %q tried to drop cooked item %q, but a cooked "
				.. "version couldn't be found",
				self.pos, item:get_name()
			)
			core.log("error", errm)
			return
		end
		drop_item = cook_result.item
	end

	core.add_item(self.pos, drop_item)

	local dir = vector.divide(
		core.facedir_to_dir(core.get_node(self.pos).param2),
		-1.95
	)
	mcl_experience.throw_xp(vector.add(self.pos, dir), 1)

	self.inv:set_stack("main", index, "")
end

---
--- @private
--- @param entity core.LuaEntityRef
--- @param item_id string
function CampfireRef:update_food_entity_visual(entity, item_id)
	local id = string.sub(item_id, 14)
	local wield_image = string.format("mcl_mobitems_%s_raw.png", id)
	local props = {
		wield_item = item_id,
		wield_image = wield_image,
	}
	entity:set_properties(props)
end

--- @param stack core.ItemStack
--- @return boolean cookable
function CampfireRef:can_cook(stack)
	if self.kind ~= CAMPFIRE_KIND.LIT then
		return false
	end
	if not is_cookable_in_campfire(stack) then
		return false
	end
	local output, _ = core.get_craft_result({
		method = "cooking",
		width = 1,
		items = { stack }
	})
	return not output.item:is_empty()
end

---
--- @param object core.ObjectRef
--- @param itemstack core.ItemStack
--- @return core.ItemStack stack Leftover itemstack
--- @return string? error_message
function CampfireRef:take_item(object, itemstack)
	if not self:can_cook(itemstack) then
		return itemstack
	end
	local index = self:find_empty_index()
	if not index then
		return itemstack
	end
	local epos = self:get_food_pos(index)
	local e = core.add_entity(epos, "mcl_campfires:food_entity")
	if not e then
		return ItemStack(), "failed to spawn entity"
	end

	local item
	if is_creative(object) then
		item = itemstack:peek_item(1)
	else
		item = itemstack:take_item(1)
	end

	self.inv:set_stack("main", index, item)
	self.meta:set_int("cooktime_" .. tostring(index), COOK_TIME)

	e:set_properties({ wield_item = item:get_name() })

	core.get_node_timer(self.pos):start(1)
	return itemstack
end

---
--- @private
--- @param index integer
--- @return boolean empty
function CampfireRef:cook_item(index)
	if self.kind ~= CAMPFIRE_KIND.LIT then
		local errm = string.format(
			"campfire at %q is not lit: cannot cook", self.pos)
		core.log("error", errm)
		return true
	end
	local stack, entity, cook_time = self:find_item(index)
	if not stack or stack:is_empty() then
		return true
	end
	if entity then
		self:update_food_entity_visual(entity, stack:get_name())
	end
	if not cook_time or cook_time <= 0 then
		self:drop_item(index, true)
		return true
	end
	self.meta:set_int("cooktime_" .. index, cook_time - 1)
	return false
end

--- Cooks items in a campfire. Should be called on timer.
---
--- @return boolean continue_timer
--- @nodiscard
function CampfireRef:cook_items()
	local empty_count = 0
	for i = 1, 4 do
		local empty = self:cook_item(i)
		if empty then
			empty_count = empty_count + 1
		end
	end
	return empty_count ~= 4
end

function CampfireRef:update_all_entity_visuals()
	for i = 1, 4 do
		local stack, entity = self:find_item(i)
		if stack and entity then
			self:update_food_entity_visual(entity, stack:get_name())
		end
	end
end

--- Play the sound of the campfire being extinguished.
---
--- @private
function CampfireRef:play_extinguish_sound()
	local sounddata = {
		pos = self.pos,
		gain = 0.25,
		max_hear_distance = 16,
	}
	core.sound_play("fire_extinguish_flame", sounddata, true)
end

--- Extinguishes a campfire.
---
--- @return boolean extinguished
function CampfireRef:extinguish()
	local smothered = self.nodedef._mcl_campfires_smothered_form
	if type(smothered) ~= "string" then
		local wmsg = string.format(
			"cannot extinguish campfire: no smothered form for %q",
			self.node.name)
		core.log("warning", wmsg)
		return false
	end
	for i = 1, 4 do
		self:drop_item(i)
	end
	core.set_node(self.pos, {
		name = smothered,
		param1 = self.node.param1,
		param2 = self.node.param2,
	})
	self:update()
	self:play_extinguish_sound()
	return true
end

function CampfireRef:extinguish_if_below_water()
	local above = vector.offset(self.pos, 0, 1, 0)
	if flowlib.is_water(above) then
		self:extinguish()
	end
end

--- @param pos Vector
--- @param digger core.ObjectRef
--- @param drops core.ItemStack[]
--- @param nodename core.ItemString
local function drop_campfire_items(pos, digger, drops, nodename)
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

--- Drop a campfire's items even after it has been destroyed.
---
--- @param pos Vector
--- @param node core.Node
--- @param oldmeta core.NodeMetaRef.Table?
local function drop_campfire_food(pos, node, oldmeta)
	mcl_util.drop_items_from_meta_container("main")(pos, node, oldmeta)
	local es = core.get_objects_inside_radius(pos, 0.5)
	if not es then
		return
	end
	for _, e in ipairs(es) do
		if is_food_entity(e) then
			e:remove()
		end
	end
end


function mcl_campfires.light_campfire(pos)
	local campfire = core.get_node(pos)
	core.set_node(pos, {
		name = campfire.name .. "_lit",
		param2 = campfire.param2
	})
end

function CampfireRef:destroy_particle_spawner()
	local id = self.meta:get_int("particle_spawner_id")
	if id and id > 0 then
		core.delete_particlespawner(id)
	end
end

--- @param constructor boolean?
function CampfireRef:create_smoke_partspawner(constructor)
	if not constructor then
		self:destroy_particle_spawner()
	end

	local node_below = vector.offset(self.pos, 0, -1, 0)
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
		minpos = vector.add(self.pos, vector.new(-0.25, 0, -0.25)),
		maxpos = vector.add(self.pos, vector.new(0.25, 0, 0.25)),
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
	self.meta:set_int("particle_spawner_id", spawner_id)
end

function CampfireRef:on_construct()
	self.inv:set_size("main", 4)
	self:create_smoke_partspawner(true)
	self:extinguish_if_below_water()
end

--- Handle the campfire being right-clicked with a shovel.
---
--- @private
--- @param clicker core.ObjectRef
--- @param stack core.ItemStack
--- @return core.ItemStack
function CampfireRef:on_shovel(clicker, stack)
	local name = clicker:get_player_name()
	if not name then
		return stack
	end
	local protected = core.is_protected(self.pos, name)
	if protected then
		core.record_protection_violation(self.pos, name)
		return stack
	end
	if not is_creative(clicker) then
		-- Add wear (as if digging a shovely node)
		-- TODO: Centralize tool wear
		local toolname = stack:get_name()
		local wear = mcl_autogroup.get_wear(toolname, "shovely")
		if wear then
			stack:add_wear(wear)
			tt.reload_itemstack_description(stack) -- update tooltip
		end
	end
	self:extinguish()
	return stack
end

--- @param player core.ObjectRef
--- @param stack core.ItemStack
--- @param pointed_thing core.PointedThing
--- @return core.ItemStack
function CampfireRef:on_right_click(player, stack, pointed_thing)
	if is_shovel(stack) then
		self:on_shovel(player, stack)
		return stack
	end
	if is_cookable_in_campfire(stack) then
		local stack2, err = self:take_item(player, stack)
		if err then
			core.log("error", "mcl_campfires: take_item error: " .. err)
		end
		return stack2 or stack
	end
	if not pointed_thing then
		return stack
	end
	core.item_place_node(stack, player, pointed_thing)
	return stack
end

---@param name string
---@param def core.NodeDef
function mcl_campfires.register_campfire(name, def)
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
		groups = {
			handy = 1,
			axey = 1,
			material_wood = 1,
			not_in_creative_inventory = 1,
			campfire = 1,
		},
		paramtype = "light",
		paramtype2 = "4dir",
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
		_on_ignite = function(_, node)
			mcl_campfires.light_campfire(node.under)
			return true
		end,
		_vl_projectile = {
			on_collide = function(projectile, pos, _, _)
				if projectile.name == "mobs_mc:small_fireball"
					or mcl_burning.is_burning(projectile.object)
				then
					mcl_campfires.light_campfire(pos)
				end
			end
		},
		after_dig_node = function(pos, _, _, digger)
			drop_campfire_items(pos, digger, def.drops, name .. "_lit")
		end,
	})

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
		groups = {
			handy = 1,
			axey = 1,
			material_wood = 1,
			lit_campfire = 1
		},
		paramtype = "light",
		paramtype2 = "4dir",
		drop = "",
		light_source = def.lightlevel,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = "fixed",
			-- left, bottom, front, right, top
			fixed = { -.5, -.5, -.5, .5, -.05, .5 },
		},
		collision_box = {
			type = "fixed",
			fixed = { -.5, -.5, -.5, .5, -.05, .5 },
		},
		-- FIXME: Once entity burning is fixed, this needs to be removed.
		damage_per_second = def.damage,

		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_campfires_smothered_form = name,

		on_construct = function(pos)
			CampfireRef.new(pos):on_construct()
		end,

		on_destruct = function(pos)
			CampfireRef.new(pos):destroy_particle_spawner()
		end,

		on_rightclick = function(pos, _, player, itemstack, pointed_thing)
			return CampfireRef
				.new(pos)
				:on_right_click(player, itemstack, pointed_thing)
		end,

		on_timer = function(pos)
			return CampfireRef.new(pos):cook_items()
		end,

		on_blast = function(pos)
			local node = core.get_node(pos)
			drop_campfire_food(pos, node)
			core.remove_node(pos)
		end,

		after_dig_node = function(pos, node, oldmeta, digger)
			drop_campfire_food(pos, node, oldmeta)
			drop_campfire_items(pos, digger, def.drops, name .. "_lit")
		end,

		_mcl_extinguish_fn = function(pos)
			return CampfireRef.new(pos):extinguish()
		end
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
			burn_in_campfire(ent.object)
		end
	end
end)

core.register_lbm({
	label = "Load lit campfires",
	name = "mcl_campfires:lit_on_load",
	nodenames = { "group:lit_campfire" },
	run_at_every_load = true,
	action = function(pos, _)
		local c = CampfireRef.new(pos)
		c:update_all_entity_visuals()
		c:create_smoke_partspawner()
	end
})
