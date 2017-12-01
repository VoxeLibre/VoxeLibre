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
		self.node = node
		self.meta = meta or {}
		self.object:set_properties({
			is_visible = true,
			textures = {node.name},
		})
	end,

	get_staticdata = function(self)
		local ds = {
			node = self.node,
			meta = self.meta,
		}
		return minetest.serialize(ds)
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		
		local ds = minetest.deserialize(staticdata)
		if ds and ds.node then
			self:set_node(ds.node, ds.meta)
		elseif ds then
			self:set_node(ds)
		elseif staticdata ~= "" then
			self:set_node({name = staticdata})
		end
	end,

	on_step = function(self, dtime)
		-- Set gravity
		local acceleration = self.object:getacceleration()
		if not vector.equals(acceleration, {x = 0, y = -10, z = 0}) then
			self.object:setacceleration({x = 0, y = -10, z = 0})
		end
		-- Turn to actual node when colliding with ground, or continue to move
		local pos = self.object:getpos()

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
				if minetest.registered_nodes[self.node.name] then
					minetest.add_node(np, self.node)
					if self.meta then
						local meta = minetest.get_meta(np)
						meta:from_table(self.meta)
					end
				end
			else
				-- Drop the *falling node* as an item if the destination node is NOT buildable to
				local drops = minetest.get_node_drops(self.node.name, "")
				for _, dropped_item in pairs(drops) do
					minetest.add_item(np, dropped_item)
				end
			end
			self.object:remove()
			minetest.check_for_falling(np)
			return
		end
		local vel = self.object:getvelocity()
		-- Fix position if entity does not move
		if vector.equals(vel, {x = 0, y = 0, z = 0}) then
			local npos = vector.round(self.object:getpos())
			local npos2 = table.copy(npos)
			npos2.y = npos2.y - 2
			local lownode = minetest.get_node(npos2)
			-- Special check required for fences, because of their overhigh collision box.
			if minetest.get_item_group(lownode.name, "fence") == 1 then
				-- Instantly stop the node if it is above a fence. This is needed
				-- because the falling node collides early with a fence node.
				-- Hacky, because the falling node will teleport a short distance, instead
				-- of smoothly fall on the fence post.
				local npos3 = table.copy(npos)
				npos3.y = npos3.y - 1
				minetest.add_node(npos3, self.node)
				self.object:remove()
				minetest.check_for_falling(npos3)
				return
			else
				-- Normal position fix (expected case)
				self.object:setpos(npos)
			end
		end
	end
})
