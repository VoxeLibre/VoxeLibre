--basic settings
local item_drop_settings                 = {} --settings table
item_drop_settings.age                   = 1.0 --how old a dropped item (_insta_collect==false) has to be before collecting
item_drop_settings.radius_magnet         = 2.0 --radius of item magnet. MUST BE LARGER THAN radius_collect!
item_drop_settings.radius_collect        = 0.2 --radius of collection
item_drop_settings.player_collect_height = 1.0 --added to their pos y value
item_drop_settings.collection_safety     = false --do this to prevent items from flying away on laggy servers
item_drop_settings.random_item_velocity  = true --this sets random item velocity if velocity is 0
item_drop_settings.drop_single_item      = false --if true, the drop control drops 1 item instead of the entire stack, and sneak+drop drops the stack
-- drop_single_item is disabled by default because it is annoying to throw away items from the intentory screen

item_drop_settings.magnet_time           = 0.75 -- how many seconds an item follows the player before giving up

local get_gravity = function()
	return tonumber(minetest.settings:get("movement_gravity")) or 9.81
end

local check_pickup_achievements = function(object, player)
	local itemname = ItemStack(object:get_luaentity().itemstring):get_name()
	if minetest.get_item_group(itemname, "tree") ~= 0 then
		awards.unlock(player:get_player_name(), "mcl:mineWood")
	elseif itemname == "mcl_mobitems:blaze_rod" then
		awards.unlock(player:get_player_name(), "mcl:blazeRod")
	elseif itemname == "mcl_mobitems:leather" then
		awards.unlock(player:get_player_name(), "mcl:killCow")
	elseif itemname == "mcl_core:diamond" then
		awards.unlock(player:get_player_name(), "mcl:diamonds")
	end
end

local enable_physics = function(object, luaentity, ignore_check)
	if luaentity.physical_state == false or ignore_check == true then
		luaentity.physical_state = true
		object:set_properties({
			physical = true
		})
		object:set_velocity({x=0,y=0,z=0})
		object:set_acceleration({x=0,y=-get_gravity(),z=0})
	end
end

local disable_physics = function(object, luaentity, ignore_check, reset_movement)
	if luaentity.physical_state == true or ignore_check == true then
		luaentity.physical_state = false
		object:set_properties({
			physical = false
		})
		if reset_movement ~= false then
			object:set_velocity({x=0,y=0,z=0})
			object:set_acceleration({x=0,y=0,z=0})
		end
	end
end

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 or not minetest.settings:get_bool("enable_damage") then
			local pos = player:get_pos()
			local inv = player:get_inventory()
			local checkpos = {x=pos.x,y=pos.y + item_drop_settings.player_collect_height,z=pos.z}

			--magnet and collection
			for _,object in ipairs(minetest.get_objects_inside_radius(checkpos, item_drop_settings.radius_magnet)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" and object:get_luaentity()._magnet_timer and (object:get_luaentity()._insta_collect or (object:get_luaentity().age > item_drop_settings.age)) then
					object:get_luaentity()._magnet_timer = object:get_luaentity()._magnet_timer + dtime
					local collected = false
					if object:get_luaentity()._magnet_timer >= 0 and object:get_luaentity()._magnet_timer < item_drop_settings.magnet_time and inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then

						-- Collection
						if vector.distance(checkpos, object:get_pos()) <= item_drop_settings.radius_collect and not object:get_luaentity()._removed then
							-- Ignore if itemstring is not set yet
							if object:get_luaentity().itemstring ~= "" then
								inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
								minetest.sound_play("item_drop_pickup", {
									pos = pos,
									max_hear_distance = 16,
									gain = 1.0,
								}, true)
								check_pickup_achievements(object, player)


								-- Destroy entity
								-- This just prevents this section to be run again because object:remove() doesn't remove the item immediately.
								object:get_luaentity()._removed = true
								object:remove()
								collected = true
							end

						-- Magnet
						else

							object:get_luaentity()._magnet_active = true
							object:get_luaentity()._collector_timer = 0

							-- Move object to player
							disable_physics(object, object:get_luaentity())

							local opos = object:get_pos()
							local vec = vector.subtract(checkpos, opos)
							vec = vector.add(opos, vector.divide(vec, 2))
							object:move_to(vec)


							--fix eternally falling items
							minetest.after(0, function(object)
								local lua = object:get_luaentity()
								if lua then
									object:set_acceleration({x=0, y=0, z=0})
								end
							end, object)


							--this is a safety to prevent items flying away on laggy servers
							if item_drop_settings.collection_safety == true then
								if object:get_luaentity().init ~= true then
									object:get_luaentity().init = true
									minetest.after(1, function(args)
										local playername = args[1]
										local player = minetest.get_player_by_name(playername)
										local object = args[2]
										local lua = object:get_luaentity()
										if player == nil or not player:is_player() or object == nil or lua == nil or lua.itemstring == nil then
											return
										end
										if inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
											inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
											if not object:get_luaentity()._removed then
												minetest.sound_play("item_drop_pickup", {
													pos = pos,
													max_hear_distance = 16,
													gain = 1.0,
												}, true)
											end
											check_pickup_achievements(object, player)
											object:get_luaentity()._removed = true
											object:remove()
										else
											enable_physics(object, object:get_luaentity())
										end
									end, {player:get_player_name(), object})
								end
							end
						end
					end

					if not collected then
						if object:get_luaentity()._magnet_timer > 1 then
							object:get_luaentity()._magnet_timer = -item_drop_settings.magnet_time
							object:get_luaentity()._magnet_active = false
						elseif object:get_luaentity()._magnet_timer < 0 then
							object:get_luaentity()._magnet_timer = object:get_luaentity()._magnet_timer + dtime
						end
					end

				elseif not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "mcl_experience:orb" then
					local entity = object:get_luaentity()
					entity.collector = player:get_player_name()
					entity.collected = true

				end
			end

		end
	end
end)

local minigroups = { "shearsy", "swordy", "shearsy_wool", "swordy_cobweb" }
local basegroups = { "pickaxey", "axey", "shovely" }
local materials = { "wood", "gold", "stone", "iron", "diamond" }

-- Checks if the given node would drop its useful drop if dug by a tool
-- with the given tool capabilities. Returns true if it will yield its useful
-- drop, false otherwise.
local check_can_drop = function(node_name, tool_capabilities)
	local handy = minetest.get_item_group(node_name, "handy")
	local dig_immediate = minetest.get_item_group(node_name, "dig_immediate")
	if handy == 1 or dig_immediate == 2 or dig_immediate == 3 then
		return true
	else
		local toolgroupcaps
		if tool_capabilities then
			toolgroupcaps = tool_capabilities.groupcaps
		else
			return false
		end

		-- Compare node groups with tool capabilities
		for m=1, #minigroups do
			local minigroup = minigroups[m]
			local g = minetest.get_item_group(node_name, minigroup)
			if g ~= 0 then
				local plus = minigroup .. "_dig"
				if toolgroupcaps[plus] then
					return true
				end
				for e=1,5 do
					local effplus = plus .. "_efficiency_" .. e
					if toolgroupcaps[effplus] then
						return true
					end
				end
			end
		end
		for b=1, #basegroups do
			local basegroup = basegroups[b]
			local g = minetest.get_item_group(node_name, basegroup)
			if g ~= 0 then
				for m=g, #materials do
					local plus = basegroup .. "_dig_"..materials[m]
					if toolgroupcaps[plus] then
						return true
					end
					for e=1,5 do
						local effplus = plus .. "_efficiency_" .. e
						if toolgroupcaps[effplus] then
							return true
						end
					end
				end
			end
		end

		return false
	end
end

-- Stupid workaround to get drops from a drop table:
-- Create a temporary table in minetest.registered_nodes that contains the proper drops,
-- because unfortunately minetest.get_node_drops needs the drop table to be inside a registered node definition
-- (very ugly)

local tmp_id = 0

local function get_drops(drop, toolname, param2, paramtype2)
	tmp_id = tmp_id + 1
	local tmp_node_name = "mcl_item_entity:" .. tmp_id
	minetest.registered_nodes[tmp_node_name] = {
		name = tmp_node_name,
		drop = drop,
		paramtype2 = paramtype2
	}
	local drops = minetest.get_node_drops({name = tmp_node_name, param2 = param2}, toolname)
	minetest.registered_nodes[tmp_node_name] = nil
	return drops
end

local function discrete_uniform_distribution(drops, min_count, max_count, cap)
	local new_drops = table.copy(drops)
	for i, item in ipairs(drops) do
		local new_item = ItemStack(item)
		local multiplier = math.random(min_count, max_count)
		if cap then
			multiplier = math.min(cap, multiplier)
		end
		new_item:set_count(multiplier * new_item:get_count())
		new_drops[i] = new_item
	end
	return new_drops
end

local function get_fortune_drops(fortune_drops, fortune_level)
	local drop
	local i = fortune_level
	repeat
		drop = fortune_drops[i]
		i = i - 1
	until drop or i < 1
	return drop or {}
end

function minetest.handle_node_drops(pos, drops, digger)
	-- NOTE: This function override allows digger to be nil.
	-- This means there is no digger. This is a special case which allows this function to be called
	-- by hand. Creative Mode is intentionally ignored in this case.

	local doTileDrops = minetest.settings:get_bool("mcl_doTileDrops", true)
	if (digger ~= nil and minetest.is_creative_enabled(digger:get_player_name())) or doTileDrops == false then
		return
	end

	-- Check if node will yield its useful drop by the digger's tool
	local dug_node = minetest.get_node(pos)
	local toolcaps
	local tool
	if digger ~= nil then
		tool = digger:get_wielded_item()
		toolcaps = tool:get_tool_capabilities()

		if not check_can_drop(dug_node.name, toolcaps) then
			return
		end
	end

	--[[ Special node drops when dug by shears by reading _mcl_shears_drop or with a silk touch tool reading _mcl_silk_touch_drop
	from the node definition.
	Definition of _mcl_shears_drop / _mcl_silk_touch_drop:
	* true: Drop itself when dug by shears / silk touch tool
	* table: Drop every itemstring in this table when dug by shears _mcl_silk_touch_drop
	]]
	
	local enchantments = tool and mcl_enchanting.get_enchantments(tool, "silk_touch")
	
	local silk_touch_drop = false
	local nodedef = minetest.registered_nodes[dug_node.name]
	if toolcaps ~= nil and toolcaps.groupcaps and toolcaps.groupcaps.shearsy_dig and nodedef._mcl_shears_drop then
		if nodedef._mcl_shears_drop == true then
			drops = { dug_node.name }
		else
			drops = nodedef._mcl_shears_drop
		end
	elseif tool and enchantments.silk_touch and nodedef._mcl_silk_touch_drop then
		silk_touch_drop = true
		if nodedef._mcl_silk_touch_drop == true then
			drops = { dug_node.name }
		else
			drops = nodedef._mcl_silk_touch_drop
		end
	end
	
	if tool and nodedef._mcl_fortune_drop and enchantments.fortune then
		local fortune_level = enchantments.fortune
		local fortune_drop = nodedef._mcl_fortune_drop
		if fortune_drop.discrete_uniform_distribution then
			local min_count = fortune_drop.min_count
			local max_count = fortune_drop.max_count + fortune_level * (fortune_drop.factor or 1)
			local chance = fortune_drop.chance or fortune_drop.get_chance and fortune_drop.get_chance(fortune_level)
			if not chance or math.random() < chance then
				drops = discrete_uniform_distribution(fortune_drop.multiply and drops or fortune_drop.items, min_count, max_count, fortune_drop.cap)
			elseif fortune_drop.override then
				drops = {}
			end
		else
			-- Fixed Behavior
			local drop = get_fortune_drops(fortune_drops, fortune_level)
			drops = get_drops(drop, tool:get_name(), dug_node.param2, nodedef.paramtype2)
		end
	end

	if digger and mcl_experience.throw_experience and not silk_touch_drop then
		local experience_amount = minetest.get_item_group(dug_node.name,"xp")
		if experience_amount > 0 then
			mcl_experience.throw_experience(pos, experience_amount)
		end
	end
	
	for _,item in ipairs(drops) do
		local count
		if type(item) == "string" then
			count = ItemStack(item):get_count()
		else
			count = item:get_count()
		end
		local drop_item = ItemStack(item)
		drop_item:set_count(1)
		for i=1,count do
			local dpos = table.copy(pos)
			-- Apply offset for plantlike_rooted nodes because of their special shape
			if nodedef and nodedef.drawtype == "plantlike_rooted" and nodedef.walkable then
				dpos.y = dpos.y + 1
			end
			-- Spawn item and apply random speed
			local obj = minetest.add_item(dpos, drop_item)
			if obj ~= nil then
				local x = math.random(1, 5)
				if math.random(1,2) == 1 then
					x = -x
				end
				local z = math.random(1, 5)
				if math.random(1,2) == 1 then
					z = -z
				end
				obj:set_velocity({x=1/x, y=obj:get_velocity().y, z=1/z})
			end
		end
	end
end

-- Drop single items by default
function minetest.item_drop(itemstack, dropper, pos)
	if dropper and dropper:is_player() then
		local v = dropper:get_look_dir()
		local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
		local cs = itemstack:get_count()
		if dropper:get_player_control().sneak then
			cs = 1
		end
		local item = itemstack:take_item(cs)
		local obj = minetest.add_item(p, item)
		if obj then
			v.x = v.x*4
			v.y = v.y*4 + 2
			v.z = v.z*4
			obj:set_velocity(v)
			-- Force collection delay
			obj:get_luaentity()._insta_collect = false
			return itemstack
		end
	end
end

--modify builtin:item

local time_to_live = tonumber(minetest.settings:get("item_entity_ttl"))
if not time_to_live then
	time_to_live = 300
end

minetest.register_entity(":__builtin:item", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		pointable = false,
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		infotext = "",
	},

	-- Itemstring of dropped item. The empty string is used when the item is not yet initialized yet.
	-- The itemstring MUST be set immediately to a non-empty string after creating the entity.
	-- The hand is NOT permitted as dropped item. ;-)
	-- Item entities will be deleted if they still have an empty itemstring on their first on_step tick.
	itemstring = '',

	-- If true, item will fall
	physical_state = true,

	-- If item entity is currently flowing in water
	_flowing = false,

	-- Number of seconds this item entity has existed so far
	age = 0,

	set_item = function(self, itemstring)
		self.itemstring = itemstring
		if self.itemstring == "" then
			-- item not yet known
			return
		end
		local stack = ItemStack(itemstring)
		local count = stack:get_count()
		local max_count = stack:get_stack_max()
		if count > max_count then
			count = max_count
			self.itemstring = stack:get_name().." "..max_count
		end
		local itemtable = stack:to_table()
		local itemname = nil
		local description = ""
		if itemtable then
			itemname = stack:to_table().name
		end
		local item_texture = nil
		local item_type = ""
		local glow
		local def = minetest.registered_items[itemname]
		if def then
			item_texture = def.inventory_image
			item_type = def.type
			description = def.description
			glow = def.light_source
		end
		local s = 0.2 + 0.1 * (count / max_count)
		local wield_scale = (def and def.wield_scale and def.wield_scale.x) or 1
		local c = s
		s = s / wield_scale
		local prop = {
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = s, y = s},
			collisionbox = {-c, -c, -c, c, c, c},
			automatic_rotate = math.pi * 0.5,
			infotext = description,
			glow = glow,
		}
		self.object:set_properties(prop)
		if item_drop_settings.random_item_velocity == true then
			minetest.after(0, function(self)
				if not self or not self.object or not self.object:get_luaentity() then
					return
				end
				local vel = self.object:get_velocity()
				if vel and vel.x == 0 and vel.z == 0 then
					local x = math.random(1, 5)
					if math.random(1,2) == 1 then
						x = -x
					end
					local z = math.random(1, 5)
					if math.random(1,2) == 1 then
						z = -z
					end
					local y = math.random(2,4)
					self.object:set_velocity({x=1/x, y=y, z=1/z})
				end
			end, self)
		end

	end,

	get_staticdata = function(self)
		return minetest.serialize({
			itemstring = self.itemstring,
			always_collect = self.always_collect,
			age = self.age,
			_insta_collect = self._insta_collect,
			_flowing = self._flowing,
			_removed = self._removed,
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				self.itemstring = data.itemstring
				self.always_collect = data.always_collect
				if data.age then
					self.age = data.age + dtime_s
				else
					self.age = dtime_s
				end
				--remember collection data
				-- If true, can collect item without delay
				self._insta_collect = data._insta_collect
				self._flowing = data._flowing
				self._removed = data._removed
			end
		else
			self.itemstring = staticdata
		end
		if self._removed then
			self._removed = true
			self.object:remove()
			return
		end
		if self._insta_collect == nil then
			-- Intentionally default, since delayed collection is rare
			self._insta_collect = true
		end
		if self._flowing == nil then
			self._flowing = false
		end
		self._magnet_timer = 0
		self._magnet_active = false
		-- How long ago the last possible collector was detected. nil = none in this session
		self._collector_timer = nil
		-- Used to apply additional force
		self._force = nil
		self._forcestart = nil
		self._forcetimer = 0

		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -get_gravity(), z = 0})
		self:set_item(self.itemstring)
	end,

	try_merge_with = function(self, own_stack, object, entity)
		if self.age == entity.age or entity._removed then
			-- Can not merge with itself and remove entity
			return false
		end

		local stack = ItemStack(entity.itemstring)
		local name = stack:get_name()
		if own_stack:get_name() ~= name or
				own_stack:get_meta() ~= stack:get_meta() or
				own_stack:get_wear() ~= stack:get_wear() or
				own_stack:get_free_space() == 0 then
			-- Can not merge different or full stack
			return false
		end

		local count = own_stack:get_count()
		local total_count = stack:get_count() + count
		local max_count = stack:get_stack_max()

		if total_count > max_count then
			return false
		end
		-- Merge the remote stack into this one

		local pos = object:get_pos()
		pos.y = pos.y + ((total_count - count) / max_count) * 0.15
		self.object:move_to(pos)

		self.age = 0 -- Handle as new entity
		own_stack:set_count(total_count)
		self:set_item(own_stack:to_string())

		entity._removed = true
		object:remove()
		return true
	end,

	on_step = function(self, dtime)
		if self._removed then
			return
		end
		self.age = self.age + dtime
		if self._collector_timer ~= nil then
			self._collector_timer = self._collector_timer + dtime
		end
		if time_to_live > 0 and self.age > time_to_live then
			self._removed = true
			self.object:remove()
			return
		end
		-- Delete corrupted item entities. The itemstring MUST be non-empty on its first step,
		-- otherwise there might have some data corruption.
		if self.itemstring == "" then
			minetest.log("warning", "Item entity with empty itemstring found at "..minetest.pos_to_string(self.object:get_pos()).. "! Deleting it now.")
			self._removed = true
			self.object:remove()
			return
		end

		local p = self.object:get_pos()
		local node = minetest.get_node_or_nil(p)
		local in_unloaded = (node == nil)

		-- If no collector was found for a long enough time, declare the magnet as disabled
		if self._magnet_active and (self._collector_timer == nil or (self._collector_timer > item_drop_settings.magnet_time)) then
			self._magnet_active = false
			enable_physics(self.object, self)
			return
		end
		if in_unloaded then
			-- Don't infinetly fall into unloaded map
			disable_physics(self.object, self)
			return
		end

		-- Destroy item in lava, fire or special nodes
		local nn = node.name
		local def = minetest.registered_nodes[nn]
		local lg = minetest.get_item_group(nn, "lava")
		local fg = minetest.get_item_group(nn, "fire")
		local dg = minetest.get_item_group(nn, "destroys_items")
		if (def and (lg ~= 0 or fg ~= 0 or dg == 1)) then
			--Wait 2 seconds to allow mob drops to be cooked, & picked up instead of instantly destroyed.
			if self.age > 2 then
				if dg ~= 2 then
					minetest.sound_play("builtin_item_lava", {pos = self.object:get_pos(), gain = 0.5})
				end
				self._removed = true
				self.object:remove()
				return
			end
		end

		-- Push item out when stuck inside solid opaque node
		if def and def.walkable and def.groups and def.groups.opaque == 1 then
			local shootdir
			local cx = (p.x % 1) - 0.5
			local cz = (p.z % 1) - 0.5
			local order = {}

			-- First prepare the order in which the 4 sides are to be checked.
			-- 1st: closest
			-- 2nd: other direction
			-- 3rd and 4th: other axis
			local cxcz = function(o, cw, one, zero)
				if cw < 0 then
					table.insert(o, { [one]=1, y=0, [zero]=0 })
					table.insert(o, { [one]=-1, y=0, [zero]=0 })
				else
					table.insert(o, { [one]=-1, y=0, [zero]=0 })
					table.insert(o, { [one]=1, y=0, [zero]=0 })
				end
				return o
			end
			if math.abs(cx) < math.abs(cz) then
				order = cxcz(order, cx, "x", "z")
				order = cxcz(order, cz, "z", "x")
			else
				order = cxcz(order, cz, "z", "x")
				order = cxcz(order, cx, "x", "z")
			end

			-- Check which one of the 4 sides is free
			for o=1, #order do
				local nn = minetest.get_node(vector.add(p, order[o])).name
				local def = minetest.registered_nodes[nn]
				if def and def.walkable == false and nn ~= "ignore" then
					shootdir = order[o]
					break
				end
			end
			-- If none of the 4 sides is free, shoot upwards
			if shootdir == nil then
				shootdir = { x=0, y=1, z=0 }
				local nn = minetest.get_node(vector.add(p, shootdir)).name
				if nn == "ignore" then
					-- Do not push into ignore
					return
				end
			end

			-- Set new item moving speed accordingly
			local newv = vector.multiply(shootdir, 3)
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.object:set_velocity(newv)

			disable_physics(self.object, self, false, false)

			if shootdir.y == 0 then
				self._force = newv
				p.x = math.floor(p.x)
				p.y = math.floor(p.y)
				p.z = math.floor(p.z)
				self._forcestart = p
				self._forcetimer = 1
			end
			return
		end

		-- This code is run after the entity got a push from above “push away” code.
		-- It is responsible for making sure the entity is entirely outside the solid node
		-- (with its full collision box), not just its center.
		if self._forcetimer > 0 then
			local cbox = self.object:get_properties().collisionbox
			local ok = false
			if self._force.x > 0 and (p.x > (self._forcestart.x + 0.5 + (cbox[4] - cbox[1])/2)) then ok = true
			elseif self._force.x < 0 and (p.x < (self._forcestart.x + 0.5 - (cbox[4] - cbox[1])/2)) then ok = true
			elseif self._force.z > 0 and (p.z > (self._forcestart.z + 0.5 + (cbox[6] - cbox[3])/2)) then ok = true
			elseif self._force.z < 0 and (p.z < (self._forcestart.z + 0.5 - (cbox[6] - cbox[3])/2)) then ok = true end
			-- Item was successfully forced out. No more pushing
			if ok then
				self._forcetimer = -1
				self._force = nil
				enable_physics(self.object, self)
			else
				self._forcetimer = self._forcetimer - dtime
			end
			return
		elseif self._force then
			self._force = nil
			enable_physics(self.object, self)
			return
		end

		-- Move item around on flowing liquids
		if def and def.liquidtype == "flowing" then

			--[[ Get flowing direction (function call from flowlib), if there's a liquid.
			NOTE: According to Qwertymine, flowlib.quickflow is only reliable for liquids with a flowing distance of 7.
			Luckily, this is exactly what we need if we only care about water, which has this flowing distance. ]]
			local vec = flowlib.quick_flow(p, node)
			-- Just to make sure we don't manipulate the speed for no reason
			if vec.x ~= 0 or vec.y ~= 0 or vec.z ~= 0 then
				-- Minecraft Wiki: Flowing speed is "about 1.39 meters per second"
				local f = 1.39
				-- Set new item moving speed into the direciton of the liquid
				local newv = vector.multiply(vec, f)
				self.object:set_acceleration({x = 0, y = 0, z = 0})
				self.object:set_velocity({x = newv.x, y = -0.22, z = newv.z})

				self.physical_state = true
				self._flowing = true
				self.object:set_properties({
					physical = true
				})
				return
			end
		elseif self._flowing == true then
			-- Disable flowing physics if not on/in flowing liquid
			self._flowing = false
			enable_physics(self.object, self, true)
			return
		end

		-- If node is not registered or node is walkably solid and resting on nodebox
		local nn = minetest.get_node({x=p.x, y=p.y-0.5, z=p.z}).name
		local v = self.object:get_velocity()

		if not minetest.registered_nodes[nn] or minetest.registered_nodes[nn].walkable and v.y == 0 then
			if self.physical_state then
				local own_stack = ItemStack(self.object:get_luaentity().itemstring)
				-- Merge with close entities of the same item
				for _, object in ipairs(minetest.get_objects_inside_radius(p, 0.8)) do
					local obj = object:get_luaentity()
					if obj and obj.name == "__builtin:item"
							and obj.physical_state == false then
						if self:try_merge_with(own_stack, object, obj) then
							return
						end
					end
				end
				disable_physics(self.object, self)
			end
		else
			if self._magnet_active == false then
				enable_physics(self.object, self)
			end
		end
	end,

	-- Note: on_punch intentionally left out. The player should *not* be able to collect items by punching
})
