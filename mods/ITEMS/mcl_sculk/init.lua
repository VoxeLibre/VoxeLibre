local S = minetest.get_translator(minetest.get_current_modname())

local spread_to = {"mcl_core:stone","mcl_core:dirt","mcl_core:sand","mcl_core:dirt_with_grass","group:grass_block","mcl_core:andesite","mcl_core:diorite","mcl_core:granite"}

local RANGE = 8

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

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

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name,"solid") <= 0 then return true end
	end
end

local function has_nonsculk(pos)
	for _,v in pairs(adjacents) do
		local p = vector.add(pos,v)
		if minetest.get_item_group(minetest.get_node(p).name,"sculk") <= 0 and minetest.get_item_group(minetest.get_node(p).name,"solid") > 0 then return p end
	end
end

local old_on_step = minetest.registered_entities["mcl_experience:orb"].on_step

minetest.registered_entities["mcl_experience:orb"].on_step = function(self,dtime)
	local p = self.object:get_pos()
	local n = minetest.find_node_near(p,2,{"mcl_sculk:sculk"})
	local nu = minetest.get_node(vector.offset(p,0,-1,0))
	local ret = old_on_step(self,dtime)
	if n and not self._sculkdrop then
		local c = minetest.find_node_near(p,RANGE,{"mcl_sculk:catalyst"})
		if c then
			local nnn = minetest.find_nodes_in_area(vector.offset(p,-RANGE,-RANGE,-RANGE),vector.offset(p,RANGE,RANGE,RANGE),spread_to)
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
				local d = math.random(100)
				--[[ --enable to generate shriekers and sensors
				if d <= 1 then
					minetest.set_node(nn[1],{name = "mcl_sculk:shrieker"})
					set_node_xp(nn[1],math.min(1,self._xp - 10))
					self.object:remove()
					return ret
				elseif d <= 9 then
					minetest.set_node(nn[1],{name = "mcl_sculk:sensor"})
					set_node_xp(nn[1],math.min(1,self._xp - 5))
					self.object:remove()
					return ret
				else --]]
					local r = math.min(math.random(#nn),self._xp)
					for i=1,r do
						minetest.set_node(nn[i],{name = "mcl_sculk:sculk" })
						set_node_xp(nn[i],math.floor(self._xp / r))
					end
					for i=1,r do
						local p = has_nonsculk(nn[i])
						if p and has_air(p) then
							minetest.set_node(vector.offset(p,0,1,0),{name = "mcl_sculk:vein", param2 = 1})
						end
					end
					set_node_xp(nn[1],get_node_xp(nn[1]) + self._xp % r)
					self.object:remove()
					return ret
				--end
			end
		end
	end
	return ret
end

minetest.register_node("mcl_sculk:sculk", {
	description = S("Sculk"),
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
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_sculk:vein", {
	description = S("Sculk Vein"),
	_doc_items_longdesc = S("Sculk vein."),
	drawtype = "signlike",
	tiles = {"mcl_sculk_vein.png"},
	inventory_image = "mcl_sculk_vein.png",
	wield_image = "mcl_sculk_vein.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	stack_max = 64,
	groups = {
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, destroy_by_lava_flow = 1, sculk = 1,
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	-- Restrict placement of vines
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_rotate = false,
})

minetest.register_node("mcl_sculk:catalyst", {
	description = S("Sculk Catalyst"),
	tiles = {
		"mcl_sculk_catalyst_top.png",
		"mcl_sculk_catalyst_bottom.png",
		"mcl_sculk_catalyst_side.png"
	},
	drop = "",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

--[[
minetest.register_node("mcl_sculk:sensor", {
	description = S("Sculk Sensor"),
	tiles = {
		"mcl_sculk_sensor_top.png",
		"mcl_sculk_sensor_bottom.png",
		"mcl_sculk_sensor_side.png"
	},
	drop = "",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})
minetest.register_node("mcl_sculk:shrieker", {
	description = S("Sculk Shrieker"),
	tiles = {
		"mcl_sculk_shrieker_top.png",
		"mcl_sculk_shrieker_bottom.png",
		"mcl_sculk_shrieker_side.png"
	},
	drop = "",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_mcl_blast_resistance = 3,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})
 --]]
