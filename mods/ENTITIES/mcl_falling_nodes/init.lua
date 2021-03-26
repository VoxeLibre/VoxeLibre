local S = minetest.get_translator("mcl_falling_nodes")
local dmes = minetest.get_modpath("mcl_death_messages") ~= nil
local has_mcl_armor = minetest.get_modpath("mcl_armor")

local his_creative_enabled = minetest.is_creative_enabled

local get_falling_depth = function(self)
	if not self._startpos then
		-- Fallback
		self._startpos = self.object:get_pos()
	end
	return self._startpos.y - vector.round(self.object:get_pos()).y
end

local deal_falling_damage = function(self, dtime)
	if minetest.get_item_group(self.node.name, "falling_node_damage") == 0 then
		return
	end
	-- Cause damage to any entity it hits.
	-- Algorithm based on MC anvils.
	local pos = self.object:get_pos()
	if not self._startpos then
		-- Fallback
		self._startpos = pos
	end
	local objs = minetest.get_objects_inside_radius(pos, 1)
	for _,v in ipairs(objs) do
		if v:is_player() then
			local hp = v:get_hp()
			local name = v:get_player_name()
			if hp ~= 0 then
				if not self._hit_players then
					self._hit_players = {}
				end
				local hit = false
				for _,v in ipairs(self._hit_players) do
					if name == v then
						hit = true
					end
				end
				if not hit then
					table.insert(self._hit_players, name)
					local way = self._startpos.y - pos.y
					local damage = (way - 1) * 2
					damage = math.min(40, math.max(0, damage))
					if damage >= 1 then
						hp = hp - damage
						if hp < 0 then
							hp = 0
						end
						-- Reduce damage if wearing a helmet
						local inv = v:get_inventory()
						local helmet = inv:get_stack("armor", 2)
						if has_mcl_armor and not helmet:is_empty() then
							hp = hp/4*3
							if not his_creative_enabled(name) then
								helmet:add_wear(65535/helmet:get_definition().groups.mcl_armor_uses) --TODO: be sure damage is exactly like mc (informations are missing in the mc wiki)
								inv:set_stack("armor", 2, helmet)
							end
						end
						local msg
						if minetest.get_item_group(self.node.name, "anvil") ~= 0 then
							msg = S("@1 was smashed by a falling anvil.", v:get_player_name())
						else
							msg = S("@1 was smashed by a falling block.", v:get_player_name())
						end
						if dmes then
							mcl_death_messages.player_damage(v, msg)
						end
						v:set_hp(hp, { type = "punch", from = "mod" })
					end
				end
			end
		else
			local hp = v:get_luaentity().health
			if hp and hp ~= 0 then
				if not self._hit_mobs then
					self._hit_mobs = {}
				end
				local hit = false
				for _,mob in ipairs(self._hit_mobs) do
					if v == mob then
						hit = true
					end
				end
				--TODO: reduce damage for mobs then they will be able to wear armor
				if not hit then
					table.insert(self._hit_mobs, v)
					local way = self._startpos.y - pos.y
					local damage = (way - 1) * 2
					damage = math.min(40, math.max(0, damage))
					if damage >= 1 then
						hp = hp - damage
						if hp < 0 then
							hp = 0
						end
						v:get_luaentity().health = hp
					end
				end
			end
		end
	end
end

minetest.register_entity(":__builtin:falling_node", {
	initial_properties = {
		visual = "wielditem",
		visual_size = {x = 0.667, y = 0.667},
		textures = {},
		physical = true,
		is_visible = false,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},

	node = {},
	meta = {},

	set_node = function(self, node, meta)
		local def = minetest.registered_nodes[node.name]
		-- Change falling node if definition tells us to
		if def and def._mcl_falling_node_alternative then
			node.name = def._mcl_falling_node_alternative
		end
		local glow
		self.node = node
		self.meta = meta or {}
		-- Set correct entity yaw
		if def and node.param2 ~= 0 then
			if (def.paramtype2 == "facedir" or def.paramtype2 == "colorfacedir") then
				self.object:set_yaw(minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2)))
			elseif (def.paramtype2 == "wallmounted" or def.paramtype2 == "colorwallmounted") then
				self.object:set_yaw(minetest.dir_to_yaw(minetest.wallmounted_to_dir(node.param2)))
			end
			if def.light_source then
				glow = def.light_source
			end
		end
		self.object:set_properties({
			is_visible = true,
			textures = {node.name},
			glow = glow,
		})
	end,

	get_staticdata = function(self)
		local meta = self.meta
		-- Workaround: Save inventory seperately from metadata.
		-- Because Minetest crashes when a node with inventory gets deactivated
		-- (GitHub issue #7020).
		-- FIXME: Remove the _inv workaround when it is no longer needed
		local inv
		if meta then
			inv = meta.inv
			meta.inventory = nil
		end
		local ds = {
			node = self.node,
			meta = self.meta,
			_inv = inv,
			_startpos = self._startpos,
			_hit_players = self._hit_players,
		}
		return minetest.serialize(ds)
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		
		local ds = minetest.deserialize(staticdata)
		if ds then
			self._startpos = ds._startpos
			self._hit_players = ds._hit_players
			if ds.node then
				local meta = ds.meta
				meta.inventory = ds._inv
				self:set_node(ds.node, meta)
			else
				self:set_node(ds)
			end
		elseif staticdata ~= "" then
			self:set_node({name = staticdata})
		end
		if not self._startpos then
			self._startpos = self.object:get_pos()
		end
		self._startpos = vector.round(self._startpos)
	end,

	on_step = function(self, dtime)
		-- Set gravity
		local acceleration = self.object:get_acceleration()
		if not vector.equals(acceleration, {x = 0, y = -10, z = 0}) then
			self.object:set_acceleration({x = 0, y = -10, z = 0})
		end
		-- Turn to actual node when colliding with ground, or continue to move
		local pos = self.object:get_pos()

		-- Portal check
		local np = {x = pos.x, y = pos.y + 0.3, z = pos.z}
		local n2 = minetest.get_node(np)
		if n2.name == "mcl_portals:portal_end" then
			-- TODO: Teleport falling node. 
			self.object:remove()
			return
		end

		-- Position of bottom center point
		local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
		-- Avoid bugs caused by an unloaded node below
		local bcn = minetest.get_node_or_nil(bcp)
		local bcd = bcn and minetest.registered_nodes[bcn.name]

		-- TODO: At this point, we did 2 get_nodes in 1 tick.
		-- Figure out how to improve that (if it is a problem).

		if bcn and (not bcd or bcd.walkable or
				(minetest.get_item_group(self.node.name, "float") ~= 0 and
				bcd.liquidtype ~= "none")) then
			if bcd and bcd.leveled and
					bcn.name == self.node.name then
				local addlevel = self.node.level
				if not addlevel or addlevel <= 0 then
					addlevel = bcd.leveled
				end
				if minetest.add_node_level(bcp, addlevel) == 0 then
					if minetest.registered_nodes[self.node.name]._mcl_after_falling then
						minetest.registered_nodes[self.node.name]._mcl_after_falling(bcp, get_falling_depth(self))
					end
					deal_falling_damage(self, dtime)
					self.object:remove()
					return
				end
			elseif bcd and bcd.buildable_to and
					(minetest.get_item_group(self.node.name, "float") == 0 or
					bcd.liquidtype == "none") then
				minetest.remove_node(bcp)
				return
			end
			local nd = minetest.registered_nodes[n2.name]
			if n2.name == "mcl_portals:portal_end" then
				-- TODO: Teleport falling node. 

			elseif (nd and nd.buildable_to == true) or minetest.get_item_group(self.node.name, "crush_after_fall") ~= 0 then
				-- Replace destination node if it's buildable to
				minetest.remove_node(np)
				-- Run script hook
				for _, callback in pairs(minetest.registered_on_dignodes) do
					callback(np, n2)
				end
				local def = minetest.registered_nodes[self.node.name]
				if def then
					minetest.add_node(np, self.node)
					if def._mcl_after_falling then
						def._mcl_after_falling(np, get_falling_depth(self))
					end
					if self.meta then
						local meta = minetest.get_meta(np)
						meta:from_table(self.meta)
					end
					if def.sounds and def.sounds.place and def.sounds.place.name then
						minetest.sound_play(def.sounds.place, {pos = np}, true)
					end
				end
			else
				-- Drop the *falling node* as an item if the destination node is NOT buildable to
				local drops = minetest.get_node_drops(self.node.name, "")
				for _, dropped_item in pairs(drops) do
					minetest.add_item(np, dropped_item)
				end
			end
			deal_falling_damage(self, dtime)
			self.object:remove()
			minetest.check_for_falling(np)
			return
		end
		local vel = self.object:get_velocity()
		-- Fix position if entity does not move
		if vector.equals(vel, {x = 0, y = 0, z = 0}) then
			local npos = vector.round(self.object:get_pos())
			local npos2 = table.copy(npos)
			npos2.y = npos2.y - 2
			local lownode = minetest.get_node(npos2)
			-- Special check required for fences and walls, because of their overhigh collision box.
			if minetest.get_item_group(lownode.name, "fence") == 1 or minetest.get_item_group(lownode.name, "wall") == 1 then
				-- Instantly stop the node if it is above a fence/wall. This is needed
				-- because the falling node collides early with a fence/wall node.
				-- Hacky, because the falling node will teleport a short distance, instead
				-- of smoothly fall on the fence post.
				local npos3 = table.copy(npos)
				npos3.y = npos3.y - 1
				minetest.add_node(npos3, self.node)
				local def = minetest.registered_nodes[self.node.name]
				if def then
					if def._mcl_after_falling then
						def._mcl_after_falling(npos3, get_falling_depth(self))
					end
					if def.sounds and def.sounds.place and def.sounds.place.name then
						minetest.sound_play(def.sounds.place, {pos = np}, true)
					end
				end
				deal_falling_damage(self, dtime)
				self.object:remove()
				minetest.check_for_falling(npos3)
				return
			else
				-- Normal position fix (expected case)
				self.object:set_pos(npos)
			end
		end

		deal_falling_damage(self, dtime)
	end
})
