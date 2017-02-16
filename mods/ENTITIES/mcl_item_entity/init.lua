--basic settings
item_drop_settings                       = {} --settings table
item_drop_settings.age                   = 1 --how old an item has to be before collecting
item_drop_settings.radius_magnet         = 2 --radius of item magnet
item_drop_settings.radius_collect        = 0.1 --radius of collection
item_drop_settings.player_collect_height = 1.5 --added to their pos y value
item_drop_settings.collection_safety     = false --do this to prevent items from flying away on laggy servers
item_drop_settings.collect_by_default    = true --make item entities automatically collect in the item entity code
                                                --versus setting it in the item drop code, setting true might interfere with
                                                --mods that use item entities (like pipeworks)
item_drop_settings.random_item_velocity  = true --this sets random item velocity if velocity is 0


minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 or not minetest.setting_getbool("enable_damage") then
			local pos = player:getpos()
			local inv = player:get_inventory()

			--collection

			for _,object in ipairs(minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y + item_drop_settings.player_collect_height,z=pos.z}, item_drop_settings.radius_collect)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					if object:get_luaentity().collect and object:get_luaentity().age > item_drop_settings.age then
						if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then

							if object:get_luaentity().itemstring ~= "" then
								inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
								minetest.sound_play("item_drop_pickup", {
									pos = pos,
									max_hear_distance = 100,
									gain = 10.0,
								})
								object:get_luaentity().itemstring = ""
								object:remove()
							end


						end
					end
				end
			end


			--magnet
			for _,object in ipairs(minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y + item_drop_settings.player_collect_height,z=pos.z}, item_drop_settings.radius_magnet)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					if object:get_luaentity().collect and object:get_luaentity().age > item_drop_settings.age then
						if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then

							--modified simplemobs api

							local pos1 = pos
							local pos2 = object:getpos()
							local vec = {x=pos1.x-pos2.x, y=(pos1.y+item_drop_settings.player_collect_height)-pos2.y, z=pos1.z-pos2.z}

							vec.x = pos2.x + (vec.x/3)
							vec.y = pos2.y + (vec.y/3)
							vec.z = pos2.z + (vec.z/3)
							object:moveto(vec)



							object:get_luaentity().physical_state = false
							object:get_luaentity().object:set_properties({
								physical = false
							})

							--fix eternally falling items
							minetest.after(0, function()
								object:setacceleration({x=0, y=0, z=0})
							end)


							--this is a safety to prevent items flying away on laggy servers
							if item_drop_settings.collection_safety == true then
								if object:get_luaentity().init ~= true then
									object:get_luaentity().init = true
									minetest.after(1, function(args)
										local lua = object:get_luaentity()
										if object == nil or lua == nil or lua.itemstring == nil then
											return
										end
										if inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
											inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
											if object:get_luaentity().itemstring ~= "" then
												minetest.sound_play("item_drop_pickup", {
													pos = pos,
													max_hear_distance = 100,
													gain = 10.0,
												})
											end
											object:get_luaentity().itemstring = ""
											object:remove()
										else
											object:setvelocity({x=0,y=0,z=0})
											object:get_luaentity().physical_state = true
											object:get_luaentity().object:set_properties({
												physical = true
											})
										end
									end, {player, object})
								end
							end
						end
					end
				end
			end
		end
	end
end)

function minetest.handle_node_drops(pos, drops, digger)
	local inv
	if minetest.setting_getbool("creative_mode") and digger and digger:is_player() then
		inv = digger:get_inventory()
	end
	for _,item in ipairs(drops) do
		local count, name
		if type(item) == "string" then
			count = 1
			name = item
		else
			count = item:get_count()
			name = item:get_name()
		end
		if not inv or not inv:contains_item("main", ItemStack(name)) then
			for i=1,count do
				local obj = minetest.env:add_item(pos, name)
				if obj ~= nil then
					obj:get_luaentity().collect = true
					local x = math.random(1, 5)
					if math.random(1,2) == 1 then
						x = -x
					end
					local z = math.random(1, 5)
					if math.random(1,2) == 1 then
						z = -z
					end
					obj:setvelocity({x=1/x, y=obj:getvelocity().y, z=1/z})
					obj:get_luaentity().age = 0.6
					-- FIXME this doesnt work for deactiveted objects
					if minetest.setting_get("remove_items") and tonumber(minetest.setting_get("remove_items")) then
						minetest.after(tonumber(minetest.setting_get("remove_items")), function(obj)
							obj:remove()
						end, obj)
					end
				end
			end
		end
	end
end

--throw single items by default
function minetest.item_drop(itemstack, dropper, pos)
	if dropper and dropper:is_player() then
		local v = dropper:get_look_dir()
		local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
		local cs = 1
		if dropper:get_player_control().sneak then
			cs = itemstack:get_count()
		end
		local item = itemstack:take_item(cs)
		local obj = core.add_item(p, item)
		if obj then
			v.x = v.x*4
			v.y = v.y*4 + 2
			v.z = v.z*4
			obj:setvelocity(v)
			obj:get_luaentity().collect = true
			return itemstack
		end
	end
end

--modify builtin:item

local time_to_live = tonumber(core.setting_get("item_entity_ttl"))
if not time_to_live then
	time_to_live = 900
end

core.register_entity(":__builtin:item", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		infotext = "",
	},

	itemstring = '',
	physical_state = true,
	age = 0,

	set_item = function(self, itemstring)
		self.itemstring = itemstring
		local stack = ItemStack(itemstring)
		local count = stack:get_count()
		local max_count = stack:get_stack_max()
		if count > max_count then
			count = max_count
			self.itemstring = stack:get_name().." "..max_count
		end
		local s = 0.2 + 0.1 * (count / max_count)
		local c = s
		local itemtable = stack:to_table()
		local itemname = nil
		local description = ""
		if itemtable then
			itemname = stack:to_table().name
		end
		local item_texture = nil
		local item_type = ""
		if core.registered_items[itemname] then
			item_texture = core.registered_items[itemname].inventory_image
			item_type = core.registered_items[itemname].type
			description = core.registered_items[itemname].description
		end
		local prop = {
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = s, y = s},
			collisionbox = {-c, -c, -c, c, c, c},
			automatic_rotate = math.pi * 0.5,
			infotext = description,
		}
		self.object:set_properties(prop)
		if item_drop_settings.collect_by_default then
			self.collect = true
		end
		if item_drop_settings.random_item_velocity == true then
			minetest.after(0, function()
				local vel = self.object:getvelocity()
				if vel.x == 0 and vel.z == 0 then
					local x = math.random(1, 5)
					if math.random(1,2) == 1 then
						x = -x
					end
					local z = math.random(1, 5)
					if math.random(1,2) == 1 then
						z = -z
					end
					local y = math.random(2,4)
					self.object:setvelocity({x=1/x, y=y, z=1/z})
				end
			end)
		end

	end,

	get_staticdata = function(self)
		return core.serialize({
			itemstring = self.itemstring,
			always_collect = self.always_collect,
			age = self.age,
			dropped_by = self.dropped_by,
			collect = self.collect
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = core.deserialize(staticdata)
			if data and type(data) == "table" then
				self.itemstring = data.itemstring
				self.always_collect = data.always_collect
				if data.age then
					self.age = data.age + dtime_s
				else
					self.age = dtime_s
				end
				--remember collection data
				if data.collect then
					self.collect = data.collect
				end
				self.dropped_by = data.dropped_by
			end
		else
			self.itemstring = staticdata
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:setvelocity({x = 0, y = 2, z = 0})
		self.object:setacceleration({x = 0, y = -10, z = 0})
		self:set_item(self.itemstring)
	end,

	try_merge_with = function(self, own_stack, object, obj)
		local stack = ItemStack(obj.itemstring)
		if own_stack:get_name() == stack:get_name() and stack:get_free_space() > 0 then
			local overflow = false
			local count = stack:get_count() + own_stack:get_count()
			local max_count = stack:get_stack_max()
			if count > max_count then
				overflow = true
				count = count - max_count
			else
				self.itemstring = ''
			end
			local pos = object:getpos()
			pos.y = pos.y + (count - stack:get_count()) / max_count * 0.15
			object:moveto(pos, false)
			local s, c
			local max_count = stack:get_stack_max()
			local name = stack:get_name()
			if not overflow then
				obj.itemstring = name .. " " .. count
				s = 0.2 + 0.1 * (count / max_count)
				c = s
				object:set_properties({
					visual_size = {x = s, y = s},
					collisionbox = {-c, -c, -c, c, c, c}
				})
				self.object:remove()
				-- merging succeeded
				return true
			else
				s = 0.4
				c = 0.3
				object:set_properties({
					visual_size = {x = s, y = s},
					collisionbox = {-c, -c, -c, c, c, c}
				})
				obj.itemstring = name .. " " .. max_count
				s = 0.2 + 0.1 * (count / max_count)
				c = s
				self.object:set_properties({
					visual_size = {x = s, y = s},
					collisionbox = {-c, -c, -c, c, c, c}
				})
				self.itemstring = name .. " " .. count
			end
		end
		-- merging didn't succeed
		return false
	end,

	on_step = function(self, dtime)
		self.age = self.age + dtime
		if time_to_live > 0 and self.age > time_to_live then
			self.itemstring = ''
			self.object:remove()
			return
		end
		local p = self.object:getpos()
		local node = core.get_node_or_nil(p)
		local in_unloaded = (node == nil)
		if in_unloaded then
			-- Don't infinetly fall into unloaded map
			self.object:setvelocity({x = 0, y = 0, z = 0})
			self.object:setacceleration({x = 0, y = 0, z = 0})
			self.physical_state = false
			self.object:set_properties({physical = false})
			return
		end

		-- Destroy item in lava and other igniters
		local nn = node.name
		if (minetest.registered_nodes[nn] and minetest.registered_nodes[nn].damage_per_second > 0) or nn == "maptools:igniter" then
			minetest.sound_play("builtin_item_lava", {pos = self.object:getpos(), gain = 0.5})
			self.object:remove()
			return
		end

		-- Move item around on flowing liquids
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].liquidtype == "flowing" then
			local get_flowing_dir = function(self)
				local pos = self.object:getpos()
				local param2 = minetest.get_node(pos).param2
				-- Search for a liquid source, or a flowing liquid node higher than
				-- the item's position in the 4 cardinal directions
				local posses = {
					{x=-1, y=0, z=0},
					{x=1, y=0, z=0},
					{x=0, y=0, z=-1},
					{x=0, y=0, z=1},
				}
				for _, p in pairs(posses) do
					local realpos = vector.add(pos, p)
					local name = minetest.get_node(realpos).name
					local par2 = minetest.get_node(realpos).param2
					if name == "mcl_core:water_source" or (name == "mcl_core:water_flowing" and par2 > param2) then
						-- Node found! Since we looked upwards, the flowing
						-- direction is the *opposite* of what we've found
						return vector.multiply(p, -1)
					end
				end
			end

			local vec = get_flowing_dir(self)
			if vec then
				local v = self.object:getvelocity()
				-- Minecraft Wiki: Flowing speed is "about 1.39 meters per second"
				local f = 1.39
				if vec.x > 0 then
					self.object:setacceleration({x = 0, y = 0, z = 0})
					self.object:setvelocity({x = f, y = -0.22, z = 0})
				elseif vec.x < 0 then
					self.object:setacceleration({x = 0, y = 0, z = 0})
					self.object:setvelocity({x = -f, y = -0.22, z = 0})
				elseif vec.z > 0 then
					self.object:setacceleration({x = 0, y = 0, z = 0})
					self.object:setvelocity({x = 0, y = -0.22, z = f})
				elseif vec.z < 0 then
					self.object:setacceleration({x = 0, y = 0, z = 0})
					self.object:setvelocity({x = 0, y = -0.22, z = -f})
				end

				self.object:setacceleration({x = 0, y = -10, z = 0})
				self.physical_state = true
				self.object:set_properties({
					physical = true
				})
				return
			end
		end

		-- If node is not registered or node is walkably solid and resting on nodebox
		p.y = p.y - 0.5
		local nn = minetest.get_node(p).name
		local v = self.object:getvelocity()

		if not core.registered_nodes[nn] or core.registered_nodes[nn].walkable and v.y == 0 then
			if self.physical_state then
				local own_stack = ItemStack(self.object:get_luaentity().itemstring)
				-- Merge with close entities of the same item
				for _, object in ipairs(core.get_objects_inside_radius(p, 0.8)) do
					local obj = object:get_luaentity()
					if obj and obj.name == "__builtin:item"
							and obj.physical_state == false then
						if self:try_merge_with(own_stack, object, obj) then
							return
						end
					end
				end
				self.object:setvelocity({x = 0, y = 0, z = 0})
				self.object:setacceleration({x = 0, y = 0, z = 0})
				self.physical_state = false
				self.object:set_properties({physical = false})
			end
		else
			if not self.physical_state then
				self.object:setvelocity({x = 0, y = 0, z = 0})
				self.object:setacceleration({x = 0, y = -10, z = 0})
				self.physical_state = true
				self.object:set_properties({physical = true})
			end
		end
	end,

	on_punch = function(self, hitter)
		local inv = hitter:get_inventory()
		if inv and self.itemstring ~= '' then
			local left = inv:add_item("main", self.itemstring)
			if left and not left:is_empty() then
				self.itemstring = left:to_string()
				return
			end
		end
		self.itemstring = ''
		self.object:remove()
	end,
})

if minetest.setting_get("log_mods") then
	minetest.log("action", "item drop reloaded loaded")
end
