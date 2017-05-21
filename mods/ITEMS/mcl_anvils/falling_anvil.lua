-- Hurt players hit by an anvil

local falling_node = minetest.registered_entities["__builtin:falling_node"]
local on_step_old = falling_node.on_step
local on_step_add = function(self, dtime)
	if minetest.get_item_group(self.node.name, "anvil") == 0 then
		return
	end
	local kill
	local pos = self.object:getpos()
	if not self._startpos then
		self._startpos = pos
	end
	local objs = minetest.get_objects_inside_radius(pos, 1)
	for _,v in ipairs(objs) do
		local hp = v:get_hp()
		if v:is_player() and hp ~= 0 then
			if not self.hit_players then
				self.hit_players = {}
			end
			local name = v:get_player_name()
			local hit = false
			for _,v in ipairs(self.hit_players) do
				if name == v then
					hit = true
				end
			end
			if not hit then
				table.insert(self.hit_players, name)
				local way = self._startpos.y - pos.y
				local damage = (way - 1) * 2
				damage = math.min(40, math.max(0, damage))
				if damage >= 1 then
					hp = hp - damage
					if hp < 0 then
						hp = 0
					end
					v:set_hp(hp)
					if v:is_player() then
						mcl_hunger.exhaust(v:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
					end
					if hp == 0 then
						kill = true
					end
				end
			end
		end
	end
	if kill then
		local pos = self.object:getpos()
		local pos = {x = pos.x, y = pos.y + 0.3, z = pos.z}
		if minetest.registered_nodes[self.node.name] then
			minetest.add_node(pos, self.node)
		end
		self.object:remove()
		core.check_for_falling(pos)
	end
end
local on_step_table = {on_step_old, on_step_add}
local on_step_new = table.copy(on_step_table)
falling_node.on_step = function(self, dtime)
	for _,v in ipairs(on_step_new) do
		v(self, dtime)
	end
end
