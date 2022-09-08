
local spread_to = {"mcl_core:stone","mcl_core:dirt","mcl_core:sand","mcl_core:dirt_with_grass","group:grass_block","mcl_core:andesite","mcl_core:diorite","mcl_core:granite"}

local range = 16
local function get_node_xp(pos)
	local meta = minetest.get_meta(pos)
	return meta:get_int("xp")
end
local function set_node_xp(pos,xp)
	local meta = minetest.get_meta(pos)
	return meta:set_int("xp",xp)
end

local function sculk_on_destruct(pos)
	local xp = get_node_xp(pos)
	local n = minetest.get_node(pos)
	if n.param2 == 1 then
		xp = 1
	end
	local obs = mcl_experience.throw_xp(pos,xp)
	for _,v in pairs(obs) do
		local l = v:get_luaentity()
		l._sculkdrop = true
	end
end

minetest.register_node("mcl_sculk:sculk", {
	description = ("Sculk"),
	tiles = {
		{ name = "mcl_sculk_sculk.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1,},
	place_param2 = 1,
--	sounds = ,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_sculk:catalyst", {
	description = ("Sculk Catalyst"),
	tiles = {
		"mcl_sculk_catalyst_top.png",
		"mcl_sculk_catalyst_bottom.png",
		"mcl_sculk_catalyst_side.png"
	},
	drop = "",
--	sounds = ,
	groups = {handy = 1, hoey = 1, building_block=1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_sculk:sensor", {
	description = ("Sculk Sensor"),
	tiles = {
		"mcl_sculk_sensor_top.png",
		"mcl_sculk_sensor_bottom.png",
		"mcl_sculk_sensor_side.png"
	},
	drop = "",
--	sounds = ,
	groups = {handy = 1, hoey = 1, building_block=1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})
minetest.register_node("mcl_sculk:shrieker", {
	description = ("Sculk Shrieker"),
	tiles = {
		"mcl_sculk_shrieker_top.png",
		"mcl_sculk_shrieker_bottom.png",
		"mcl_sculk_shrieker_side.png"
	},
	drop = "",
--	sounds = ,
	groups = {handy = 1, hoey = 1, building_block=1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name,"solid") <= 0 then return true end
	end
end

local old_on_step = minetest.registered_entities["mcl_experience:orb"].on_step

minetest.registered_entities["mcl_experience:orb"].on_step = function(self,dtime)
	local p = self.object:get_pos()
	local n = minetest.get_node(vector.offset(p,0,-1,0))
	local ret = old_on_step(self,dtime)
	if n.name == "mcl_sculk:sculk" and not self._sculkdrop then
		local c = minetest.find_node_near(p,range,{"mcl_sculk:catalyst"})
		if c then
			local nnn = minetest.find_nodes_in_area(vector.offset(p,-range,-range,-range),vector.offset(p,range,range,range),spread_to)
			local nn={}
			for _,v in pairs(nnn) do
				if has_air(v) then
					table.insert(nn,v)
				end
			end
			table.sort(nn,function(a, b)
				return vector.distance(p, a) < vector.distance(p, b)
			end)
			if nn and #nn > 0 and self._xp > 0 then
				local r = math.min(math.random(#nn),self._xp)
				for i=1,r do
					minetest.set_node(nn[i],{name = "mcl_sculk:sculk"})
					set_node_xp(nn[i],math.floor(self._xp / r))
				end
				set_node_xp(nn[1],get_node_xp(nn[1]) + self._xp % r)
				self.object:remove()
				return ret
			end
		end
	end
	return ret
end
